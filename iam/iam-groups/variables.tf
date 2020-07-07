### GROUPS - START
variable "name" {
  description = "The name of the IAM group"
  type        = string
}

variable "enable-AdministratorAccess" {
  description = "A flag for enabling the AWS Managed AdministratorAccess policy."
  default     = false
}

variable "enable-DeveloperAccessNonProd" {
  description = "A flag for allowing the developers to access non-prod."
  default     = false
}
### GROUPS - END
