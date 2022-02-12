###############################################################################
# COGNITO USER POOL
###############################################################################
resource "aws_cognito_user_pool" "pool" {
  name                = "${var.project_name}-user-pool"
  username_attributes = ["email"]
  mfa_configuration   = "OFF"

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
  auto_verified_attributes = ["email"]
  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

}

###############################################################################
# COGNITO APP CLIENT
###############################################################################
resource "aws_cognito_user_pool_client" "client" {
  name = "${var.project_name}-userpool-client"

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


###############################################################################
# COGNITO DOMAIN
###############################################################################
resource "aws_cognito_user_pool_domain" "identity_domain" {
  domain       = var.project_name
  user_pool_id = aws_cognito_user_pool.pool.id
}

###############################################################################
# USER POOL CONFIG
#   This emits userpool id's needed for frontend/src/UserPool.ts
###############################################################################
resource "local_file" "website_userpool_config" {
  content = templatefile("${path.module}/userpool-config.json.tftpl", {
    poolId   = aws_cognito_user_pool.pool.id,
    clientId = aws_cognito_user_pool_client.client.id,
  })
  filename = "${path.module}/../frontend/src/userpool-config.json"
}
