# Owlet: Modest Data Project Template

This project aims to create a template for "modest data" projects (as opposed to _big data_).
But this project also aims to use technology to make the transition to a big data projects easier.

Why **Owlet**? Well baby owls are called Owlets. These projects start small and should sleep most of the time and wake a couple of times of day like owls at dawn and dusk. With the idea these projects can leave the nest and fly on their own later.

## Project values

 - Minimise financial costs, and total project running costs to be less than $10 / month (ideally $1/month)
 - Designed for infrequent (once a day or once a week usage) use and scale to zero
 - Use least amount of technology components, components used should have wide adoption and community support
 - Technology should gateway enable big data projects
 - Getting started should be my data model, my credentials and project name and 2-3 commands.
 - Avoid technologies that mean lock-in (like AWS SAM)

## Architecture in a nutshell

 - Infra-as-Code: Terraform
 - Frontend: React static hosting on S3 (Costs: S3 + CloudFront if using CDN)
 - Backend: API Gateway + Python Lambda + JWT Auth
 - Auth: Cognito using OAuth2 spec
 - Data storage:
   - Aurora Serverless?
   - Athena + S3 + Parquet?
   - Python Lambda + S3 + Deltalake?

Ideally object storage and parquet like storage seems to offer good compression, good metadata and the ability to easily ingest from other sources later like:
 - SageMaker
 - Databricks
 - Snowflake


# Speed run

The following commands are my code snippet scratch pad do perform a full run through.

It also keeps the onboarding cognitive load front and center. 

**I aim to keep this small.**

```bash
./tasks.py init
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

# TODO List

 - Create React app with logged out and logged in component state
 - Redirect to cognito login and callback with auth information
 - Have React app securely query Lambda API with Auth credentials
 - Refactor terraform config into logical modules
 - parametrise API endpoints based on modules and data_model.yml
 - All data concepts should have an automatic HTML form to submit data one entry at a time.
 - All data concepts should have a drag and drop file upload for mass data entry
 - Research data storage options:
  - Aurora Serverless?
  - Athena?
  - Python Lambda + S3 + Parquet?
  - Python Lambda + S3 + deltalake?
 - What would a developer portal look like for direct API access? API Gateway does support Swagger exports


# Learning Resources:

Key resources:

 - Follow along with this [tutorial on HashiCorp Learn](https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws).
 - Added Cognito Authorizer inspired by this video: [https://www.youtube.com/watch?v=o7OHogUcRmI](https://www.youtube.com/watch?v=o7OHogUcRmI)
 - Added React static site based on this tutorial: [https://learn.hashicorp.com/tutorials/terraform/cloudflare-static-website?in=terraform/aws](https://learn.hashicorp.com/tutorials/terraform/cloudflare-static-website?in=terraform/aws)

More resources:

 - Terraform crash course: https://www.youtube.com/watch?v=SLB_c_ayRMo
 - Terraform tutorials: https://www.youtube.com/playlist?list=PL8HowI-L-3_9bkocmR3JahQ4Y-Pbqs2Nt
 - Terraform in Action Book: https://www.manning.com/books/terraform-in-action
