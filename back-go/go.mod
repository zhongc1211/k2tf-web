module github.com/sl1pm4t/k2tf

go 1.17

require (
	github.com/hashicorp/go-multierror v1.1.1
	github.com/hashicorp/hcl v1.0.0
	github.com/hashicorp/hcl2 v0.0.0-20190821123243-0c888d1241f6
	github.com/hashicorp/terraform-plugin-sdk/v2 v2.7.0
	github.com/hashicorp/terraform-provider-kubernetes v1.13.4-0.20211022152516-9497a7bbb22b
	github.com/iancoleman/strcase v0.0.0-20191112232945-16388991a334
	github.com/jinzhu/inflection v1.0.0
	github.com/mitchellh/reflectwalk v1.0.2
	github.com/rs/zerolog v1.19.0
	github.com/sirupsen/logrus v1.7.0
	github.com/spf13/pflag v1.0.5
	github.com/stretchr/testify v1.7.0
	github.com/zclconf/go-cty v1.8.4
	k8s.io/api v0.21.2
	k8s.io/apimachinery v0.21.2
	k8s.io/client-go v11.0.0+incompatible
	k8s.io/kube-aggregator v0.21.0
)

require (
	github.com/aws/aws-lambda-go v1.27.0
	github.com/gregjones/httpcache v0.0.0-20190611155906-901d90724c79 // indirect
	github.com/hashicorp/golang-lru v0.5.4 // indirect
)

// kustomize needs to be kept in sync with the cli-runtime.
// go-openapi needs to be locked at v0.19.5 for kustomize.
replace (
	github.com/go-openapi/spec => github.com/go-openapi/spec v0.19.9
	k8s.io/cli-runtime => k8s.io/cli-runtime v0.21.0
	k8s.io/client-go => k8s.io/client-go v0.21.0
	sigs.k8s.io/kustomize/pkg/transformers => ./vendor/k8s.io/cli-runtime/pkg/kustomize/k8sdeps/transformer
	sigs.k8s.io/kustomize/pkg/transformers/config => ./vendor/k8s.io/cli-runtime/pkg/kustomize/k8sdeps/transformer/config
)
