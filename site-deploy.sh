aws s3 cp frontend/build/ "s3://$(terraform -chdir=infra output -raw website_bucket)/" --recursive --profile="$(terraform -chdir=infra output -raw aws_profile)"
