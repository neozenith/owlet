provider "local" {}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Hardcoded region for AWS Certificate Manager (ACM) to create SSL Certs
provider "aws" {
  alias   = "aws_useast1"
  region  = "us-east-1"
  profile = var.aws_profile
}
