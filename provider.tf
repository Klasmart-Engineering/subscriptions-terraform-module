provider "aws" {
  assume_role {
    role_arn     = var.aws_target_role_arn
    session_name = var.aws_session_name
    external_id  = var.aws_target_external_id
  }
}
