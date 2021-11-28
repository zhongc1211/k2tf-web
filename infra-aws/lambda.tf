resource "aws_lambda_function" "k2tf-lambda" {
   function_name = "k2tf-lambda"

   filename      = "../back-go/main.zip"

   # "main" is the filename within the zip file (main.js) and "handler"
   # is the name of the property under which the handler function was
   # exported in that file.
   handler = "main"
   runtime = "go1.x"
   memory_size = "512"
   timeout = "15"

   role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "k2tf-web-log" {
  name              = "/aws/lambda/${aws_lambda_function.k2tf-lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role" "lambda_exec" {
   name = "k2tf_lambda_role"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
