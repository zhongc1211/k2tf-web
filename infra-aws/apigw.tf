resource "aws_api_gateway_rest_api" "k2tf_back" {
  name        = "k2tf-back"
  description = "Terraform Serverless Application k2tf-back"
}

resource "aws_api_gateway_resource" "convert_path" {
   rest_api_id = aws_api_gateway_rest_api.k2tf_back.id
   parent_id   = aws_api_gateway_rest_api.k2tf_back.root_resource_id
   path_part   = "convert"
}

resource "aws_api_gateway_method" "post" {
   rest_api_id   = aws_api_gateway_rest_api.k2tf_back.id
   resource_id   = aws_api_gateway_resource.convert_path.id
   http_method   = "POST"
   authorization = "NONE"
}


resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.k2tf_back.id
   resource_id = aws_api_gateway_method.post.resource_id
   http_method = aws_api_gateway_method.post.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.k2tf-lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "dev" {
   depends_on = [
     aws_api_gateway_integration.lambda
   ]

   rest_api_id = aws_api_gateway_rest_api.k2tf_back.id
   stage_name  = "dev"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.k2tf-lambda.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.k2tf_back.execution_arn}/*/*"
}

module "cors" {
  source = "squidfunk/api-gateway-enable-cors/aws"

  api_id          = aws_api_gateway_rest_api.k2tf_back.id
  api_resource_id = aws_api_gateway_resource.convert_path.id
}

output "base_url" {
  value = aws_api_gateway_deployment.dev.invoke_url
}