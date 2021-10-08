resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-functions"
  length = 4
}




# TODO:
# Read this to integrate cognito with api gateway
# https://github.com/voquis/terraform-aws-cognito-user-pool-http-api
#
# API GatewayV2 Route Authorizer
#   - Create JWT Authorizer
#     - name: cognito-auth
#     - identity-source: $request.header.Authorization
#     - issuer url: https://cognito-idp.{region}.amazonaws.com/{userPoolId}
#     - audience: appClientId
#
