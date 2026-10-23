output "id" {
  description = "Name (ID) of the bucket. Null when create is false."
  value       = var.create ? module.this.s3_bucket_id : null
}

output "name" {
  description = "Name of the bucket. Null when create is false."
  value       = var.create ? var.name : null
}

output "arn" {
  description = "ARN of the bucket. Null when create is false."
  value       = var.create ? module.this.s3_bucket_arn : null
}

output "bucket_regional_domain_name" {
  description = "Region-specific domain name of the bucket. Null when create is false."
  value       = var.create ? module.this.s3_bucket_bucket_regional_domain_name : null
}

output "tags" {
  description = "Tags applied to the bucket, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.tags : null
}
