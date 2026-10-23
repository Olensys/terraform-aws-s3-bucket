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

# SMOKE: asserts only that the bucket plans and output.name matches; the four public-access-block
# flags are literals in main.tf and upstream exposes no output for them. The real check lives in
# complete.tftest.hcl (apply) and trivy.
run "test_public_access_blocked_by_default" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "The bucket must plan and expose its name."
  }
}

# SMOKE: asserts only that a bucket policy is attached, not that it contains aws:SecureTransport
# (the rendered JSON comes from a mocked data source). The real check lives in complete.tftest.hcl
# and trivy. Upstream only creates the policy when the deny-insecure-transport flag (or another
# policy source) is set. Applied against the mock because Terraform treats mocked computed values as unknown
# at plan time.
run "test_tls_enforced" {
  command = apply

  assert {
    condition     = module.this.s3_bucket_policy != null
    error_message = "A bucket policy must be attached."
  }
}

# SMOKE: asserts only that the bucket plans with kms_key_arn set and output.name matches; upstream
# exposes no output for the encryption rule. The real check lives in complete.tftest.hcl and trivy.
run "test_kms_when_key_given" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abc"
  }

  assert {
    condition     = output.name == var.name
    error_message = "The bucket must plan with kms_key_arn set and expose its name."
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

run "test_tags_contract" {
  command = plan

  variables {
    tags = { Owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { Owner = "y", Team = "z" }
    }
  }

  assert {
    condition     = output.tags.Owner == "x"
    error_message = "var.tags must win over context.extra_tags."
  }

  assert {
    condition     = output.tags.Team == "z"
    error_message = "context.extra_tags must be merged into tags."
  }
}

run "test_versioning_and_lifecycle_map_to_upstream" {
  command = apply

  variables {
    versioning_enabled = true
    lifecycle_rules = [{
      id                         = "expire-logs"
      prefix                     = "logs/"
      expiration_days            = 30
      noncurrent_expiration_days = 7
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
