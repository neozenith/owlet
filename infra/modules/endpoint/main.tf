###############################################################################
# SOURCE CODE ARCHIVE
###############################################################################
data "archive_file" "packaged_sourcecode" {
  type = "zip"

  source_dir  = "${path.module}/../../../backend/dist/${var.target}"
  output_path = "${path.module}/../../../backend/${var.target}.zip"

}

resource "aws_s3_bucket_object" "lambda_sourcecode_deployment_key" {
  bucket = var.s3_source_code_bucket
  key    = "${var.target}.zip"
  source = data.archive_file.packaged_sourcecode.output_path

  etag = filemd5(data.archive_file.packaged_sourcecode.output_path)
}


###############################################################################
# LAMBDA FUNCTION
###############################################################################
resource "aws_lambda_function" "this" {
  function_name = "${var.project_name}_${var.target}"

  s3_bucket = var.s3_source_code_bucket
  s3_key    = aws_s3_bucket_object.lambda_sourcecode_deployment_key.key

  runtime = "python3.9"
  handler = "handler.handler"

  source_code_hash = data.archive_file.packaged_sourcecode.output_base64sha256

  role = var.lambda_iam_exec_role_arn
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 3
}


###############################################################################
# API ROUTE
#   Create the Route definition on the gateway to create the API surface area.
#   The Route defines:
#     - Endpoint key
#     - Authorization
#     - Integration
###############################################################################
resource "aws_apigatewayv2_route" "get_route" {
  api_id = var.api_gateway.id

  route_key = "GET /${var.target}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"

  authorizer_id      = var.api_auth_id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id = var.api_gateway.id

  route_key = "POST /${var.target}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"

  authorizer_id      = var.api_auth_id
  authorization_type = "JWT"
}

###############################################################################
# API INTEGRATION
###############################################################################
resource "aws_apigatewayv2_integration" "this" {
  api_id = var.api_gateway.id
  integration_uri    = aws_lambda_function.this.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}


###############################################################################
# PERMISSION
#   This allows API Gateway to Invoke the Lambda Function
###############################################################################
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${var.api_gateway.execution_arn}/*/*"
}
