resource "random_pet" "lambda_bucket_name" {
  prefix = var.project_name
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  acl           = "private"
  force_destroy = true
}

locals {
  data_model = yamldecode(file("${path.module}/${var.data_model}"))
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

module "api_lambda_endpoints" {
  source = "./modules/endpoint"

  for_each = local.data_model

  aws_profile = var.aws_profile
  aws_region  = var.aws_region

  target       = each.key
  project_name = var.project_name

  s3_source_code_bucket    = aws_s3_bucket.lambda_bucket.id
  lambda_iam_exec_role_arn = aws_iam_role.lambda_exec.arn

  api_gateway = aws_apigatewayv2_api.this
  api_auth_id = aws_apigatewayv2_authorizer.api_auth.id
}

