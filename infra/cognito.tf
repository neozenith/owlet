resource "aws_cognito_user_pool" "pool" {
  name              = "userpool-${var.project_name}"
  mfa_configuration = "OFF"

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

}


resource "aws_cognito_user_pool_client" "client" {
  name = "userpool-client-${var.project_name}"

  user_pool_id                 = aws_cognito_user_pool.pool.id
  supported_identity_providers = ["COGNITO"]
  generate_secret              = false
  explicit_auth_flows          = ["ALLOW_CUSTOM_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = var.oauth_scopes

  callback_urls = var.callback_urls
  logout_urls   = var.callback_urls
}

resource "aws_cognito_user_pool_domain" "identity_domain" {
  domain       = var.project_name
  user_pool_id = aws_cognito_user_pool.pool.id
}