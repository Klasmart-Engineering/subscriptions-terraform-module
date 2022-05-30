variable "region" {
  description = "Cloud provider region name"
  type        = string
  default     = "eu-west-2"
}
variable "aws_target_role_arn" {
  description = "The role arn terraform requires to assume to create resources in AWS"
  type        = string
}
variable "aws_session_name" {
  description = "The session_name terraform requires to assume a role to create resources in AWS"
  type        = string
}
variable "aws_target_external_id" {
  description = "The external id terraform requires to assume a role to create resources in AWS"
  type        = string
}