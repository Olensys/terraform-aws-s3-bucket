# terraform-aws-s3-bucket

Private, encrypted, TLS-only S3 bucket with optional versioning, lifecycle and CORS

## Opinions

- All four public-access-block flags (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`) are always `true`.
- A bucket policy denying requests without `aws:SecureTransport` is always attached; a policy passed in `bucket_policy_json` is merged with it.
- Object ownership is `BucketOwnerEnforced`, so ACLs are disabled.
- Encryption is SSE-S3 (`AES256`) by default and SSE-KMS (`aws:kms`) when `kms_key_arn` is given.
- Versioning defaults to on in prod and off elsewhere (override with `versioning_enabled`), `force_destroy` is off, and each lifecycle rule aborts incomplete multipart uploads after 7 days unless `abort_incomplete_multipart_days` says otherwise.

## Usage

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "s3_bucket" {
  source  = "git::https://github.com/Olensys/terraform-aws-s3-bucket.git?ref=v1.1.0"
  name    = module.naming.name
  context = var.context

  tags = module.naming.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this"></a> [this](#module\_this) | terraform-aws-modules/s3-bucket/aws | 5.17.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Resource name. Lowercase letters, digits and hyphens. | `string` | n/a | yes |
| <a name="input_bucket_policy_json"></a> [bucket\_policy\_json](#input\_bucket\_policy\_json) | Additional bucket policy as JSON. It is merged with the deny-insecure-transport policy. | `string` | `null` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | CORS rules for the bucket. | <pre>list(object({<br/>    allowed_origins = list(string)<br/>    allowed_methods = list(string)<br/>    allowed_headers = optional(list(string), [])<br/>    max_age_seconds = optional(number, 3600)<br/>  }))</pre> | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to plan nothing. | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether the bucket can be destroyed while it still holds objects. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of a KMS key for SSE-KMS. When null, the bucket uses SSE-S3 (AES256). | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle rules. expiration\_days expires current versions; noncurrent\_expiration\_days expires noncurrent versions; prefix limits a rule to a key prefix. | <pre>list(object({<br/>    id                              = string<br/>    prefix                          = optional(string)<br/>    expiration_days                 = optional(number)<br/>    noncurrent_expiration_days      = optional(number)<br/>    abort_incomplete_multipart_days = optional(number, 7)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags merged onto every taggable resource, applied last. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Whether object versioning is enabled. Null (the default) means enabled in prod and disabled elsewhere; set true or false to override. | `bool` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the bucket. Null when create is false. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | Region-specific domain name of the bucket. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Name (ID) of the bucket. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Name of the bucket. Null when create is false. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the bucket, with context.extra\_tags merged in. Null when create is false. |
<!-- END_TF_DOCS -->
