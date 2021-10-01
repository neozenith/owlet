# Learn Terraform - Lambda functions and API Gateway

AWS Lambda functions and API gateway are often used to create serverlesss
applications.

Follow along with this [tutorial on HashiCorp
Learn](https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws).

```bash
terraform init
terraform apply --auto-approve

# Invoke Lambda
aws invoke --region=ap-southeast-2 --profile=play --function-name=HelloWorld response.json

# Request API
curl "$(terraform output -raw base_url)/hello?Name=ME"
```
