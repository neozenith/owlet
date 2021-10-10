# Learn Terraform - Lambda functions and API Gateway

AWS Lambda functions and API gateway are often used to create serverlesss
applications.

Follow along with this [tutorial on HashiCorp Learn](https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws).

Adding Cognito Authorizer inspired by this video:
[https://www.youtube.com/watch?v=o7OHogUcRmI](https://www.youtube.com/watch?v=o7OHogUcRmI)

```bash
./tasks.py tf-up

cd infrastructure
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

# Clean up
./tasks.py tf-down

# Housekeeping
./tasks.py tf-fmt
terraform -chdir=infrastructure graph | dot -Tsvg > graph.svg
```

## Diagram

![architecture diagram](graph.svg)
