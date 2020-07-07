# non-alias provider added because of tf issue: https://github.com/terraform-providers/terraform-provider-aws/issues/9989
provider "aws" {
  version = "~> 2.69"
  profile = "kambydyne"
  region  = "eu-central-1"
}

provider "aws" {
  version = "~> 2.69"
  profile = "kambydyne"
  region  = "eu-central-1"
  alias   = "master"
}

provider "aws" {
  version = "~> 2.69"
  profile = "non_prod"
  region  = "eu-central-1"
  alias   = "non_prod"
}

provider "aws" {
  version = "~> 2.69"
  profile = "prod"
  region  = "eu-central-1"
  alias   = "prod"
}

provider "aws" {
  version = "~> 2.69"
  profile = "archive"
  region  = "eu-central-1"
  alias   = "archive"
}
