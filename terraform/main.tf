terraform {
  required_version = "~> 0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.3.0"
    }
  }
}

resource "aws_s3_bucket" "opa_demo_bucket" {
  bucket        = "opa-demo"
  acl           = "public-read"
  policy        = file("policy.json")
  force_destroy = true
}
