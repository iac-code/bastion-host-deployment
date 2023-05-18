resource "aws_iam_role" "oxla-instance-role" {
  name               = "oxla_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.oxla-assume-role.json
}

resource "aws_iam_instance_profile" "oxla-instance-profile" {
  name = "test_profile"
  role = aws_iam_role.oxla-instance-role.name
}

data "aws_iam_policy_document" "oxla-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

