# Create admin roles to assume in the sub accounts

module "cross-account-role-non-prod" {
  source        = "./cross-account-role"
  providers     = {
    aws.target    = aws.non_prod
    aws.source    = aws.master
  }
}

module "cross-account-role-prod" {
  source        = "./cross-account-role"
  providers     = {
    aws.target    = aws.prod
    aws.source    = aws.master
  }
}

module "cross-account-role-archive" {
  source        = "./cross-account-role"
  providers     = {
    aws.target    = aws.archive
    aws.source    = aws.master
  }
}
