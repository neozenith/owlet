resource "random_pet" "lambda_bucket_name" {
  prefix = var.project_name
  length = 4
}

locals {
  data_model = yamldecode(file("${path.module}/${var.data_model}"))
}
