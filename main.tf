provider "aws" {
  version = "~> 3.0"
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}