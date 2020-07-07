### SERVICE LEVEL (AND/OR TAG) POLICIES - START
module "cloudtrails-no-disable" {
  source      = "./organizations-policies"
  name        = "cloudtrail-no-disabler"
  description = "An SCP preventing cloudtrails from being disabled across the org."
  content     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudtrail:AddTags",
        "cloudtrail:CreateTrail",
        "cloudtrail:DeleteTrail",
        "cloudtrail:RemoveTags",
        "cloudtrail:StartLogging",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*",
      "Effect": "Deny"
    }
  ]
}
POLICY
  type        = "SERVICE_CONTROL_POLICY"
  target_id   = [module.ou-business_domains.id]
}

module "lock-down-root-user" {
  source      = "./organizations-policies"
  name        = "lock-down-root-user"
  description = "An SCP blocking the root user from taking any action, either via the console or programmatically"
  content     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Resource": "*",
      "Effect": "Deny",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": [
            "arn:aws:iam::*:root"
          ]
        }
      }
    }
  ]
}
POLICY
  type        = "SERVICE_CONTROL_POLICY"
  target_id   = [module.ou-business_domains.id]
}

module "ou-legal-allow-s3" {
  source      = "./organizations-policies"
  name        = "ou-legal-allow-s3"
  description = "An SCP allowing S3 to be used in the legal OU."
  content     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
POLICY
  type        = "SERVICE_CONTROL_POLICY"
  target_id   = [module.ou-legal.id]
}
### SERVICE LEVEL (AND/OR TAG) POLICIES - END
