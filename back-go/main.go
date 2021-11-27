package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/hashicorp/hcl/hcl/printer"
	"github.com/hashicorp/hcl2/hclwrite"
	"github.com/rs/zerolog/log"
	"github.com/sl1pm4t/k2tf/pkg/tfkschema"
)

// Build time variables
var (
	version = "dev"
)

// Command line flags
var (
	debug              bool
	input              string
	output             string
	includeUnsupported bool
	noColor            bool
	overwriteExisting  bool
	tf12format         bool
	printVersion       bool
)

type RequestBody struct {
	OverwriteExisting bool   `json:"OverwriteExisting"`
	Debug             bool   `json:"Debug"`
	Input             string `json:"Input"`
	Output            string `json:"Output"`
	InputUnsupported  bool 	 `json:"InputUnsupported"`
	TF12Format        bool   `json:"TF12Format"`
	PrintVersion      bool   `json:"PrintVersion"`
}

type Event events.APIGatewayProxyRequest

type Response events.APIGatewayProxyResponse

func init() {
	setupLogOutput()
}

func main() {
	lambda.Start(HandleLambdaEvent)
}

func HandleLambdaEvent(event Event) (Response, error) {
	var payloadJson RequestBody
	err := json.Unmarshal([]byte(event.Body), &payloadJson)
	if err != nil {
		return Response{}, err
	}
	overwriteExisting = payloadJson.OverwriteExisting
	debug = payloadJson.Debug
	input = payloadJson.Input
	output = payloadJson.Output
	includeUnsupported = payloadJson.InputUnsupported
	tf12format = payloadJson.TF12Format
	printVersion = payloadJson.PrintVersion
	if printVersion {
		fmt.Printf("k2tf version: %s\n", version)
		resp := Response{
			StatusCode:      200,
			IsBase64Encoded: false,
			Body: 	fmt.Sprintf("k2tf version: %s\n", version),
			Headers: map[string]string{
				"Content-Type":           "application/json",
				"Access-Control-Allow-Headers": "Content-Type",
				"Access-Control-Allow-Origin": "*",
				"Access-Control-Allow-Methods": "OPTIONS,POST",
			},
		}
		return resp, nil
	}

	//log.Debug().
	//	Str("version", version).
	//	Str("commit", commit).
	//	Str("builddate", date).
	//	Msg("starting k2tf")
	fmt.Printf("Reading input yaml...\n")
	objs := readInput()

	//log.Debug().Msgf("read %d objects from input", len(objs))

	//w, closer := setupOutput()
	//defer closer()
	fmt.Printf("Writing objects...\n")
	var results []byte
	for i, obj := range objs {
		if tfkschema.IsKubernetesKindSupported(obj) {
			f := hclwrite.NewEmptyFile()
			_, err := WriteObject(obj, f.Body())
			if err != nil {
				log.Error().Int("obj#", i).Err(err).Msg("error writing object")
			}

			formatted := formatObject(f.Bytes())
			fmt.Printf("%s\n", formatted)
			results = append(results, formatted...)
			//fmt.Fprint(w, string(formatted))
			//fmt.Fprintln(w)
		} else {
			log.Warn().Str("kind", obj.GetObjectKind().GroupVersionKind().Kind).Msg("skipping API object, kind not supported by Terraform provider.")
		}
	}
	fmt.Printf("Writing objects...ok\n")
	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Body: 	string(results),
		Headers: map[string]string{
			"Content-Type":           "application/json",
			"Access-Control-Allow-Headers": "Content-Type",
			"Access-Control-Allow-Origin": "*",
			"Access-Control-Allow-Methods": "OPTIONS,POST",
		},
	}
	return resp, nil
}

func formatObject(in []byte) []byte {
	var result []byte
	var err error

	if tf12format {
		result = hclwrite.Format(in)
	} else {
		result, err = printer.Format(in)
		if err != nil {
			log.Error().Err(err).Msg("could not format object")
			return in
		}
	}

	return result
}
