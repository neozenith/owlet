variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS credentials profile"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "name of project to use in tags"
  type        = string
  default     = "helloworld"
}

variable "target" {
  type = string
  description = "name of the endpoint target"
}

variable "s3_source_code_bucket" {
  description = "Name of the S3 bucket to use for uploading lambda deployment code"
  type = string
}

variable "lambda_iam_exec_role_arn" {
  description = "Lambda IAM Execution Role ARN"
  type = string
}

variable "api_gateway" {
  description = "API Gateway"
}

variable "api_auth_id" {
  description = "API Gateway Authorizer entity ID"
  type = string
}
