provider "aws" {
  alias = "default"
}


resource "aws_s3_bucket" "lambda_storage" {
  provider = "${var.function_provider != "" ? var.function_provider : aws.default}"

  bucket = "tf-${var.name}-storage"
}

data "archive_file" "local_zipped_lambda" {
  type        = "zip"
  source_dir = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket_object" "zipped_lambda" {
  provider = "${var.function_provider != "" ? var.function_provider : aws.default}"

  bucket = "${aws_s3_bucket.lambda_storage.bucket}"
  key    = "lambda.zip"
  source = "${data.archive_file.local_zipped_lambda.output_path}"
}

resource "aws_lambda_function" "service" {
  provider = "${var.function_provider != "" ? var.function_provider : aws.default}"

  function_name = "tf-${var.name}"

  s3_bucket = "${aws_s3_bucket.lambda_storage.bucket}"
  s3_key    = "${aws_s3_bucket_object.zipped_lambda.key}"

  handler     = "src/lambda.handler"
  runtime     = "nodejs10.x"
  timeout     = "50"
  memory_size = "${var.memory_size}"
  role        = "${aws_iam_role.service.arn}"
  environment {
    variables = "${var.env_vars}"
  }
}

resource "aws_iam_policy" "service" {
  provider = "${var.function_provider != "" ? var.function_provider : aws.default}"

  name = "tf-${var.name}"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "service" {
  provider = "${var.function_provider != "" ? var.function_provider : aws.default}"

  name = "tf-${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "service" {
  provider = "${var.function_provider != "" ? var.function_provider : aws.default}"

  name = "tf-${var.name}"
  role = "${aws_iam_role.service.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "service" {
  provider = "${var.function_provider != "" ? var.function_provider : aws.default}"

  role       = "${aws_iam_role.service.name}"
  policy_arn = "${aws_iam_policy.service.arn}"
}
