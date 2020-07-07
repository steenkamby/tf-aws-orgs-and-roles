### GROUPS - START
module "administrators" {
  source                            = "./iam-groups"
  name                              = "administrators"
  enable-AdministratorAccess        = true
}

module "developers" {
  source                            = "./iam-groups"
  name                              = "developers"
  enable-DeveloperAccessNonProd     = true
}
### GROUPS - END

### USERS - START
module "admin_user_1" {
  source                            = "./iam-users"
  name                              = "test_admin_user_1"
  groups                            = ["administrators"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}

output "admin_user_1-aws_iam_user-credentials" {
  description = "The user's credentials"
  value       = module.admin_user_1.aws_iam_user-credentials
}

module "admin_santiago_lastname" {
  source                            = "./iam-users"
  name                              = "santiago_lastname"
  groups                            = ["administrators"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}

module "admin_felix_lastname" {
  source                            = "./iam-users"
  name                              = "felix_lastname"
  groups                            = ["administrators"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}

module "admin_morgan_lastname" {
  source                            = "./iam-users"
  name                              = "morgan_lastname"
  groups                            = ["administrators"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}

module "developer_eugene_lastname" {
  source                            = "./iam-users"
  name                              = "eugene_lastname"
  groups                            = ["developers"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}

module "developer_milo_lastname" {
  source                            = "./iam-users"
  name                              = "milo_lastname"
  groups                            = ["developers"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}

module "developer_abigail_lastname" {
  source                            = "./iam-users"
  name                              = "abigail_lastname"
  groups                            = ["developers"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}

module "developer_aidan_lastname" {
  source                            = "./iam-users"
  name                              = "aidan_lastname"
  groups                            = ["developers"]
  force_destroy                     = true
  pgp_key                           = file("exampleuser.asc")
}
### USERS - END
