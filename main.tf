# Thin wrapper over terraform-aws-modules/s3-bucket/aws. The upstream call is named `this`.

locals {
  # Merge onto every taggable resource, with var.tags applied last.
  tags = merge(var.context.extra_tags, var.tags)

  versioning_enabled = coalesce(var.versioning_enabled, var.context.environment == "prod")
}

module "this" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.17.0"

  create_bucket = var.create
  bucket        = var.name
  force_destroy = var.force_destroy

  # Opinions: never public, owner-enforced, TLS only.
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true
  control_object_ownership              = true
  object_ownership                      = "BucketOwnerEnforced"
  attach_deny_insecure_transport_policy = true

  # Upstream merges this document with the deny-insecure-transport statement.
  attach_policy = var.bucket_policy_json != null
  policy        = var.bucket_policy_json

  versioning = { enabled = local.versioning_enabled }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
        kms_master_key_id = var.kms_key_arn
      }
    }
  }

  lifecycle_rule = [
    for r in var.lifecycle_rules : {
      id      = r.id
      enabled = true
      filter  = { prefix = r.prefix }

      abort_incomplete_multipart_upload_days = r.abort_incomplete_multipart_days
      expiration                             = r.expiration_days == null ? null : { days = r.expiration_days }
      noncurrent_version_expiration          = r.noncurrent_expiration_days == null ? null : { noncurrent_days = r.noncurrent_expiration_days }
    }
  ]

  cors_rule = var.cors_rules
  tags      = local.tags
}
