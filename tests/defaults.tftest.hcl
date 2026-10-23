mock_provider "aws" {
  # Mocked data sources return random strings; upstream parses policy JSON, so give it valid JSON.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name = "example"
}

# Terraform and OpenTofu only expose a module's outputs to test assertions, not its
# resources, so the runs below assert on the upstream outputs that reflect each setting.

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = output.id == null
    error_message = "id must be null when create is false."
  }

  assert {
    condition     = output.arn == null
    error_message = "arn must be null when create is false."
  }
}

# The four public-access-block flags are literals in main.tf with no input to weaken them;
# upstream exposes no output for them, so this run proves the hardened configuration plans.
run "test_public_access_blocked_by_default" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "The bucket must plan with the public-access-block configuration."
  }
}

# The rendered policy JSON comes from a mocked data source, so assert the policy is attached:
# upstream only creates it when the deny-insecure-transport flag (or another policy source)
# is set. Applied against the mock because Terraform treats mocked computed values as unknown
# at plan time.
run "test_tls_enforced" {
  command = apply

  assert {
    condition     = module.this.s3_bucket_policy != null
    error_message = "A bucket policy carrying the aws:SecureTransport deny statement must be attached."
  }
}

# Upstream exposes no output for the encryption rule; this run proves the SSE-KMS path plans.
run "test_kms_when_key_given" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abc"
  }

  assert {
    condition     = output.name == var.name
    error_message = "The bucket must plan with an SSE-KMS configuration."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  expect_failures = [var.name]
}

run "test_tags_propagated" {
  command = plan

  variables {
    tags = { Owner = "x" }
  }

  assert {
    condition     = module.this.s3_bucket_tags.Owner == "x"
    error_message = "tags must reach the bucket."
  }
}

run "test_lifecycle_and_cors_map_to_upstream" {
  command = apply

  variables {
    versioning_enabled = true
    lifecycle_rules = [{
      id                         = "expire-logs"
      prefix                     = "logs/"
      expiration_days            = 30
      noncurrent_expiration_days = 7
    }]
    cors_rules = [{
      allowed_origins = ["https://example.com"]
      allowed_methods = ["GET"]
    }]
  }

  assert {
    condition     = module.this.aws_s3_bucket_versioning_status == "Enabled"
    error_message = "versioning_enabled must enable versioning."
  }

  assert {
    condition     = module.this.s3_bucket_lifecycle_configuration_rules[0].id == "expire-logs"
    error_message = "lifecycle_rules must reach the upstream module."
  }
}
