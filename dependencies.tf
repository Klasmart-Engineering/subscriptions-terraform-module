data "tfe_outputs" "meta" {
  organization = local.terraform_organization
  workspace    = "meta-${local.project_region}-${local.project_environment}"
}

data "tfe_outputs" "account" {
  organization = local.terraform_organization
  workspace    = "account-${local.project_region}-${local.project_environment}"
}

data "tfe_outputs" "network" {
  organization = local.terraform_organization
  workspace    = "network-${local.project_region}-${local.project_environment}"
}

data "tfe_outputs" "cluster" {
  organization = local.terraform_organization
  workspace    = "cluster-${local.project_region}-${local.project_environment}"
}
