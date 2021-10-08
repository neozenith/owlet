resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-functions"
  length = 4
}

locals {
  data_model = yamldecode(file("${path.module}/${var.data_model}"))
}


# TODO:
# refactor to parametrised modules
