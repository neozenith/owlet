aws s3 rm "s3://$(terraform -chdir=infra output -raw website_bucket)/" --recursive --profile="$(terraform -chdir=infra output -raw aws_profile)"
