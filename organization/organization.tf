### ORGANIZATION
# After the AWS docs: "An entity that you create to consolidate your AWS accounts so that you can administer them as a single unit."
module "root" {
  source               = "./organizations"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}
### ORGANIZATION - END

## ORGANIZATION UNITS - START
module "ou-business_domains" {
  source    = "./organizations-organizational_units"
  name      = "ou-business_domains"
  parent_id = module.root.roots.0.id
}
module "ou-legal" {
  source    = "./organizations-organizational_units"
  name      = "ou-legal"
  parent_id = module.ou-business_domains.id
}
module "ou-static_documents" {
  source    = "./organizations-organizational_units"
  name      = "ou-static_documents"
  parent_id = module.ou-legal.id
}
## ORGANIZATION UNITS - END

### ACCOUNTS - START
locals {
  role_name = "adminAssumeRole"
}

module "legal-static-doc-archive" {
  source    = "./organizations-accounts"
  name      = "legal-static-doc-archive"
  email     = "steenkamnby+legal-static-doc-archive@gmail.com"
  parent_id = module.ou-static_documents.id
  role_name = local.role_name
}

module "legal-static-non_prod_env" {
  source    = "./organizations-accounts"
  name      = "legal-static-non_prod_env"
  email     = "steenkamnby+legal-static-non_prod_env@gmail.com"
  parent_id = module.ou-static_documents.id
  role_name = local.role_name
}

module "legal-static-prod_env" {
  source    = "./organizations-accounts"
  name      = "legal-static-prod_env"
  email     = "steenkamby+legal-static-non_prod_env@gmail.com"
  parent_id = module.ou-static_documents.id
  role_name = local.role_name
}
### ACCOUNTS - END
