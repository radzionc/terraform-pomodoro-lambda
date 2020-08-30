resource "aws_s3_bucket" "artifacts" {
  count = "${var.ci_container_name != "" ? 1 : 0}"

  bucket = "tf-${var.name}-pipeline-artifacts"
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  count = "${var.ci_container_name != "" ? 1 : 0}"

  name = "tf-${var.name}-pipeline"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  count = "${var.ci_container_name != "" ? 1 : 0}"

  name = "tf-${var.name}-pipeline"
  role = "${aws_iam_role.codepipeline_role[0].id}"
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

resource "aws_iam_role" "codebuild_role" {
  count = "${var.ci_container_name != "" ? 1 : 0}"

  name = "tf-${var.name}-codebuild-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  count = "${var.ci_container_name != "" ? 1 : 0}"

  role   = "${aws_iam_role.codebuild_role[0].name}"
  policy = <<POLICY
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
POLICY
}

resource "aws_codebuild_project" "codebuild" {
  count = "${var.ci_container_name != "" ? 1 : 0}"

  name         = "tf-codebuild-${var.name}"
  service_role = "${aws_iam_role.codebuild_role[0].arn}"
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ci_containers_storage_name}:${var.ci_container_name}"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name = "BUCKET"
      value = "${aws_s3_bucket.lambda_storage.bucket}"
    }
  }
  source {
    type      = "CODEPIPELINE"
  }
}

resource "aws_codepipeline" "pipeline" {
  count = "${var.ci_container_name != "" ? 1 : 0}"

  name     = "tf-${var.name}-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role[0].arn}"

  // solution from https://github.com/terraform-providers/terraform-provider-aws/issues/2854
  lifecycle {
    ignore_changes = [stage[0].action[0].configuration]
  }

  artifact_store {
    location = "${aws_s3_bucket.artifacts[0].bucket}"
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]
      configuration = {
        Owner      = "${var.repo_owner}"
        Repo       = "${var.repo_name}"
        Branch     = "${var.branch}"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source"]
      version         = "1"
      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild[0].name}"
      }
    }
  }
}

