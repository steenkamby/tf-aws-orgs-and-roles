### ORGANIZATION
# After the AWS docs: "An entity that you create to consolidate your AWS accounts so that you can administer them as a single unit."
module "root" {
  source               = "./organizations"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}
### ORGANIZATION - END
