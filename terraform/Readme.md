# Terraform: infra/terraform

This folder contains Terraform code to create a small AWS infrastructure (VPC, security groups, EC2 and ALB resources). The README explains what each file does and how to run the Terraform code safely.

## What this does

- Creates networking resources (VPC, subnets, routing) defined in `vpc.tf`.
- Creates security groups defined in `security_groups.tf`.
- Creates EC2 and Application Load Balancer resources in `ec2_alb.tf`.
- Declares inputs in `variables.tf` and outputs in `outputs.tf`.

## Files

- `main.tf` - top-level composition and provider configuration.
- `vpc.tf` - VPC, subnets, routing, and related network resources.
- `security_groups.tf` - security group rules for instances/load balancer.
- `ec2_alb.tf` - EC2 instances and ALB configuration.
- `variables.tf` - input variables with defaults and descriptions.
- `outputs.tf` - outputs produced after apply.
- `.terraform.lock.hcl` & `.terraform/` - provider plugins and lock file.
- `terraform.tfstate` - local state file (present in this folder). See the State note below.

## Prerequisites

- Terraform v1.5+ (or a version compatible with the AWS provider in the lockfile).
- AWS account and credentials configured (environment variables, shared credentials file, or AWS CLI profile).
- AWS CLI or other tools are optional but useful for inspection.

Set credentials in your shell (example for bash on Windows / WSL):

```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
# or set AWS_PROFILE and remove access key env vars
```

## Important state note

There is a `terraform.tfstate` file checked into this folder. This file contains the current state and may include sensitive information. It is strongly recommended to:

- Do not commit state to version control. Consider moving to a remote backend (S3 + DynamoDB lock) before collaborative use.
- If you intend to start fresh, move or delete the `terraform.tfstate` and `terraform.tfstate.backup` files (or backup somewhere secure) before running `terraform init`/`apply`.

Example to move the current state out of the folder:

```bash
mv terraform.tfstate terraform.tfstate.bak
mv terraform.tfstate.backup terraform.tfstate.backup.bak
```

## Quick start (single-machine, local state)

1. Inspect variables in `variables.tf` and update them as needed or create a `terraform.tfvars` file.
2. Initialize providers and modules:

```bash
cd infra/terraform
terraform init
```

3. See what Terraform will do (recommended):

```bash
terraform plan -out=tfplan
```

4. Apply the plan:

```bash
terraform apply "tfplan"
```

Or apply directly (interactive):

```bash
terraform apply
```

5. After completion, view outputs:

```bash
terraform output
terraform output -json  # for automation
```

## Example `terraform.tfvars` (optional)

# Create `terraform.tfvars` to set non-default variables. Example:

# aws_region = "us-east-1"

# instance_type = "t3.micro"

Adjust variables to match your account quotas and preferences.

## Destroy / cleanup

When you no longer need the resources, run:

```bash
terraform destroy
```

Confirm the resources to be destroyed and proceed.

## Troubleshooting

- Provider/plugin errors: run `terraform init -upgrade` to refresh plugins.
- Permissions errors: ensure the AWS credentials have permissions to create VPCs, EC2, ALB, and related resources.
- Port or security issues: verify `security_groups.tf` rules match your expected ports.

## Recommendations

- Move state to a remote backend (S3 + DynamoDB) for team usage.
- Remove `terraform.tfstate` and `.tfstate.backup` from source control and add them to `.gitignore`.
- Review `variables.tf` and set conservative defaults for production.

## Contact / Next steps

If you want, I can:

- Convert this setup to use an S3 backend and locking with DynamoDB.
- Add a `terraform.tfvars.example` with recommended values.
- Add a `.gitignore` entry and remove the committed `terraform.tfstate` safely.

---

Generated README for the Terraform configuration in this folder.
