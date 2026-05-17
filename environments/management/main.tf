# environments/management/main.tf
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_s3_bucket" "state" {
  bucket = "pomeloinfra-tf-state-backend"

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  organizational_units = [
    "Security",
    "Infrastructure",
    "Workloads",
    "Sandbox"
  ]
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each  = toset(local.organizational_units)
  name      = each.key
  parent_id = aws_organizations_organization.this.roots[0].id
}

module "sso_permission_sets" {
  source = "../../modules/sso-permission-sets"
}
