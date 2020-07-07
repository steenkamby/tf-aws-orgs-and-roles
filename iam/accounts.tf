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

# Create master account policies for the different user groups to assume the x-acc roles

resource "aws_iam_policy" "assume_non_prod" {
  name        = "assume_non_prod"
  description = "allow assuming non_prod admin role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${data.aws_caller_identity.non_prod.account_id}:role/cross_account_admin_role"
    }]
  })
}

resource "aws_iam_policy" "assume_prod" {
  name        = "assume_prod"
  description = "allow assuming prod admin role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${data.aws_caller_identity.prod.account_id}:role/cross_account_admin_role"
    }]
  })
}

resource "aws_iam_policy" "assume_archive" {
  name        = "assume_archive"
  description = "allow assuming archive admin role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${data.aws_caller_identity.archive.account_id}:role/cross_account_admin_role"
    }]
  })
}

# Create group policy attachments orchestrating the difference in the roles

## Ops - full access across the accounts
resource "aws_iam_group_policy_attachment" "ops_admin_non_prod" {
  group      = "ops"
  policy_arn = aws_iam_policy.assume_non_prod.arn
}
resource "aws_iam_group_policy_attachment" "ops_admin_prod" {
  group      = "ops"
  policy_arn = aws_iam_policy.assume_prod.arn
}
resource "aws_iam_group_policy_attachment" "ops_admin_archive" {
  group      = "ops"
  policy_arn = aws_iam_policy.assume_archive.arn
}

## Devs - full access to non-prod and archives
resource "aws_iam_group_policy_attachment" "dev_admin_non_prod" {
  group      = "developers"
  policy_arn = aws_iam_policy.assume_non_prod.arn
}
resource "aws_iam_group_policy_attachment" "dev_admin_archive" {
  group      = "developers"
  policy_arn = aws_iam_policy.assume_archive.arn
}
