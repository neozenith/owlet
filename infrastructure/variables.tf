# Input variable definitions

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
  default     = "hello world"
}

variable "data_model" {
  description = "Path to data model YAML file"
  type        = string
  default     = "data_model.yml"
}

variable "callback_urls" {
  description = "Callback URLs for Signup, Login and Signout"
  type        = list(string)
  default     = ["https://127.0.0.1:3000"]
}

variable "oauth_scopes" {
  description = "OAuth scopes"
  type        = list(string)
  default     = ["openid", "email", "aws.cognito.signin.user.admin"]
}
