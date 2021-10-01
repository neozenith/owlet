# Output value definitions

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.hello_world.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."
  value = aws_apigatewayv2_stage.lambda.invoke_url
}

# Output resolved values to assist in script automation
output "aws_profile" {
  description = "The name of the AWS profile used"
  value = var.aws_profile
}
output "aws_region" {
  description = "The name of the AWS region used"
  value = var.aws_region
}

