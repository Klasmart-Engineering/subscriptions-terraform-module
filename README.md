# Terraform AWS Subscriptions module

## Description

This terraform module contains all of the resources required to run the Kidsloop Subscriptions product offering module on AWS. This includes:

- RDS database (postgres)
- KMS keys for encryption (Database)
- IAM roles for Kubernetes service account

## Usage

This service module is designed to be launched via the terraform operator in ArgoCD.
It is called from the subcsriptions-gitops-env repo.

* [Environment module (deployment module) link](git@github.com:KL-Engineering/subscriptions-gitops-env.git)

## Caveats

- The avatars feature is deprecated but the resources are still included in this repo for now.


[comment]: # (BEGIN_TF_DOCS)

## Terraform auto-docs

This is managed by Github Actions now. Just commit your code and let the pipeline do the rest.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 3.75.0, < 5.0.0 |
| kubernetes | >= 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.75.0, < 5.0.0 |
| kubernetes | >= 2.6.1 |
| random | n/a |
| time | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| user\_service\_cluster | app.terraform.io/kidsloop-infrastructure/rds-cluster/aws | 1.0.1 |
| user\_service\_kms | app.terraform.io/kidsloop-infrastructure/kms/aws | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.user_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.user_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.user_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.user_assets_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.user_assets_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.user_assets_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_logging.user_assets_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.user_assets_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.user_assets_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.postgresql_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.postgresql_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [kubernetes_secret.user_db](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.user_service_api_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.user_service_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_uuid.user_api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [time_static.timestamp](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) | resource |
| [aws_iam_policy_document.user_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backup\_retention | Database backup retention days | `number` | `5` | no |
| database\_subnet\_group | Database subnet group | `string` | n/a | yes |
| deletion\_protection | The database can't be deleted when this value is set to true | `bool` | `true` | no |
| domain | The name of the domain which will be used to host the Kidsloop environment (not including any microservice-specific parts). | `string` | n/a | yes |
| eks\_oidc\_provider\_arn | ARN of AWS EKS OIDC IAM provider (for IAM policies) | `string` | n/a | yes |
| eks\_oidc\_provider\_id | ID of AWS EKS OIDC IAM provider (for IAM policies) | `string` | n/a | yes |
| enabled\_cloudwatch\_logs\_exports | Object containing the cloudwatch log types to be exported | ```object({ mysql = list(string) postgresql = list(string) docdb = list(string) })``` | ```{ "docdb": [ "audit", "profiler" ], "mysql": [ "audit", "error", "general", "slowquery" ], "postgresql": [ "postgresql" ] }``` | no |
| enhanced\_monitoring\_role\_enabled | A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring | `bool` | `true` | no |
| logs\_bucket\_id | ID of logs bucket | `string` | n/a | yes |
| master\_username | Master username for the database clusters | `string` | `"kidsloop"` | no |
| monitoring\_interval | Monitoring interval (in seconds) | `number` | `60` | no |
| preferred\_backup\_window | The default preferred backup window for the database clusters | `string` | `"00:00-00:30"` | no |
| preferred\_maintenance\_window | The default preferred maintenance window for the database clusters | `string` | `"mon:22:20-mon:22:50"` | no |
| private\_ip\_range | Range of private IP addresses (used to grant access to the database with an IP CIDR range based security group rule) | `set(string)` | n/a | yes |
| project | The Project name | `string` | `"kidskube"` | no |
| project\_environment | Business name of Kidsloop environment (e.g. test) | `string` | n/a | yes |
| project\_region | Business name of Kidsloop region (e.g. uk/in/id/vn etc) | `string` | n/a | yes |
| region | Cloud provider region name | `string` | n/a | yes |
| s3\_enable\_versioning | Do we want to enable versioning in S3? | `bool` | `true` | no |
| service\_owner | Owner of deployment (which team manages?) | `string` | n/a | yes |
| skip\_final\_snapshot | If you want terraform to make a final snapshot of the db before deleting the cluster | `bool` | `true` | no |
| tags | Any additional tags to add to resources deployed by this stack. | `map(any)` | `{}` | no |
| user\_service\_database\_name | Database name for the User Service | `string` | `"user_service_db"` | no |
| user\_service\_db\_service | The RDS service e.g cms, user | `string` | `"user"` | no |
| user\_service\_engine | RDS Database Engine type (without aurora-) | `string` | `"postgresql"` | no |
| user\_service\_engine\_version | RDS Database Engine version | `string` | `"12.8"` | no |
| user\_service\_instance\_class | The db instance type | `string` | `"db.t3.medium"` | no |
| user\_service\_namespace | The kubernetes namespace which the XAPI service will be deployed to | `string` | `"kl-apps"` | no |
| user\_service\_port | User service PostgreSQL port | `string` | `"5432"` | no |
| user\_service\_sa\_name | User service account name in Kubernetes | `string` | `"kidsloop-user-service-sa"` | no |
| vpc\_id | The ID of your VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_iam\_role\_user\_service\_arn | The ARN of the IAM role for the user service role |
| aws\_iam\_role\_user\_service\_id | The id of the IAM role for the user service role |
| aws\_iam\_role\_user\_service\_name | The name of the IAM role for the user service role |
| user\_assets\_s3\_bucket\_arn | the resources bucket ARN |
| user\_assets\_s3\_bucket\_id | the resources bucket identifier (name) |
| user\_assets\_s3\_bucket\_origin\_domain | the resources bucket origin domain to use in cloudfront |
| user\_service\_db\_name | The User Service database name |
| user\_service\_db\_password | The randomly generated password for User Service database |
| user\_service\_db\_port | The User Service database port |
| user\_service\_endpoint | The User Service RDS Cluster endpoint |
| user\_service\_kms\_arn | The ARN of the KMS key to use to encrypt the user service Postgres database |
| user\_service\_master\_username | The cluster master username |

[comment]: # (END_TF_DOCS)