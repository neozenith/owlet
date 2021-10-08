# Output resolved values to assist in script automation
output "aws_profile" {
  description = "The name of the AWS profile used"
  value       = var.aws_profile
}
output "aws_region" {
  description = "The name of the AWS region used"
  value       = var.aws_region
}

output "data_model" {
  description = "Loaded data model"
  value       = local.data_model
}

# Lambda and API Gateway
output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.hello_world.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}


# Cognito
output "cognito_userpool_endpoint" {
  description = "The cognito userpool endpoint"
  value       = aws_cognito_user_pool.pool.endpoint
}
output "cognito_client_id" {
  description = "The cognito userpool client"
  value       = aws_cognito_user_pool_client.client.id
}
output "cognito_domain" {
  description = "The cognito userpool domain"
  value       = aws_cognito_user_pool_domain.identity_domain
}

output "login_url" {
  description = "Login URL for Cognito User Pool"
  value       = "https://${aws_cognito_user_pool_domain.identity_domain.domain}.auth.${var.aws_region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.client.id}&response_type=token&scope=${join("+", var.oauth_scopes)}&redirect_uri=${var.callback_urls[0]}"
}

output "signup_url" {
  description = "Signup URL for Cognito User Pool"
  value       = "https://${aws_cognito_user_pool_domain.identity_domain.domain}.auth.${var.aws_region}.amazoncognito.com/signup?client_id=${aws_cognito_user_pool_client.client.id}&response_type=token&scope=${join("+", var.oauth_scopes)}&redirect_uri=${var.callback_urls[0]}"
}
