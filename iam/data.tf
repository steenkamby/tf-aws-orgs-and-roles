data "aws_caller_identity" "master" {
  provider = aws.master
}

data "aws_caller_identity" "non_prod" {
  provider = aws.non_prod
}

data "aws_caller_identity" "prod" {
  provider = aws.prod
}

data "aws_caller_identity" "archive" {
  provider = aws.archive
}
