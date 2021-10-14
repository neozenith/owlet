output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}
output "routes" {
  description = ""
  value       = [
    aws_apigatewayv2_route.get_route.route_key,
    aws_apigatewayv2_route.post_route.route_key
  ]
}
