resource "aws_iam_role" "cross_account_admin_role" {
  name = "cross_account_admin_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${data.aws_caller_identity.source.account_id}:root" }
    }]
  })

  provider = aws.target
}

data "aws_iam_policy_document" "admin" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }

  provider = aws.target
}

resource "aws_iam_policy" "assume_admin" {
  name        = "assume_admin"
  description = "assume admin on account"
  policy      = data.aws_iam_policy_document.admin.json

  provider = aws.target
}

resource "aws_iam_policy_attachment" "assume_admin" {
  name       = "assume admin role"
  roles      = ["${aws_iam_role.cross_account_admin_role.name}"]
  policy_arn = aws_iam_policy.assume_admin.arn

  provider = aws.target
}
