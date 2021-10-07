# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS credentials profile"

  type    = string
  default = "default"
}

variable "project_name" {
  description = "name of project to use in tags"
  type        = string
  default     = "hello world"
}
