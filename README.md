# Learn Terraform - Lambda functions and API Gateway

1. AWS Lambda functions and API gateway are often used to create serverlesss
applications.
1. Follow along with this [tutorial on HashiCorp Learn](https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws).
1. Added Cognito Authorizer inspired by this video:
[https://www.youtube.com/watch?v=o7OHogUcRmI](https://www.youtube.com/watch?v=o7OHogUcRmI)
1. Added React static site based on this tutorial: [https://learn.hashicorp.com/tutorials/terraform/cloudflare-static-website?in=terraform/aws](https://learn.hashicorp.com/tutorials/terraform/cloudflare-static-website?in=terraform/aws)

```bash
./tasks.py tf-up

cd infra
# Invoke Lambda
aws lambda invoke \
 --region="$(terraform output -raw aws_region)" \
 --profile="$(terraform output -raw aws_profile)" \
 --function-name="$(terraform output -raw function_name)" response.json

# Debugging
aws lambda invoke \
 --region="$(terraform output -raw aws_region)" \
 --profile="$(terraform output -raw aws_profile)" \
 --function-name="$(terraform output -raw function_name)" response.json \
 --log-type Tail --query 'LogResult' --output text | base64 -D

# Request API
curl "$(terraform output -raw base_url)/hello?Name=ME"

{"message":"Unauthorized"}

# Securely request API
# Navigate to Hosted UI for signup
open "$(terraform output -raw signup_url)"

# grab access_token value from signup redirect
TOKEN=<value you just grabbed>

curl -H "Authorization: Bearer $TOKEN" "$(terraform output -raw base_url)/hello?Name=ME"

cd..

# Build and deploy static site
./tasks.py ui-build
./tasks.py ui-deploy

# Clean up
./tasks.py tf-down

# Housekeeping
./tasks.py tf-fmt
terraform -chdir=infra graph | dot -Tsvg > graph.svg
```

## Diagram

![architecture diagram](graph.svg)

# Learning Resources:

 - https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway
 - Terraform crash course: https://www.youtube.com/watch?v=SLB_c_ayRMo
 - Terraform tutorials: https://www.youtube.com/playlist?list=PL8HowI-L-3_9bkocmR3JahQ4Y-Pbqs2Nt
 - Terraform in Action Book: https://www.manning.com/books/terraform-in-action
 - Terraform static site tutorial: https://learn.hashicorp.com/tutorials/terraform/cloudflare-static-website?in=terraform/aws
