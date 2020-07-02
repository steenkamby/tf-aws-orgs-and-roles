### GROUPS - START
module "administrators" {
  source                     = "./iam-groups"
  name                       = "administrators"
  enable-AdministratorAccess = true
}

module "developers" {
  source                             = "./iam-groups"
  name                               = "developers"
  enable-AWSCodeBuildDeveloperAccess = true
}
### GROUPS - END

### USERS - START
module "admin_user_1" {
  source                            = "./iam-users"
  name                              = "test_admin_user_1"
  groups                            = ["administrators"]
  force_destroy                     = true
  pgp_key                           = ""
}

output "admin_user_1-aws_iam_user-credentials" {
  description = "The user's credentials"
  value       = module.admin_user_1.aws_iam_user-credentials
}
### USERS - END
