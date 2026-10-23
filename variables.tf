variable "name" {
  description = "Resource name. Lowercase letters, digits and hyphens."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.name))
    error_message = "name must match ^[a-z0-9-]{1,63}$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "create" {
  description = "Whether to create any resources. Set false to plan nothing."
  type        = bool
  default     = true
}

variable "versioning_enabled" {
  description = "Whether object versioning is enabled."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "ARN of a KMS key for SSE-KMS. When null, the bucket uses SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules. expiration_days expires current versions; noncurrent_expiration_days expires noncurrent versions; prefix limits a rule to a key prefix."
  type = list(object({
    id                              = string
    prefix                          = optional(string)
    expiration_days                 = optional(number)
    noncurrent_expiration_days      = optional(number)
    abort_incomplete_multipart_days = optional(number, 7)
  }))
  default = []
}

variable "force_destroy" {
  description = "Whether the bucket can be destroyed while it still holds objects."
  type        = bool
  default     = false
}

variable "cors_rules" {
  description = "CORS rules for the bucket."
  type = list(object({
    allowed_origins = list(string)
    allowed_methods = list(string)
    allowed_headers = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default = []
}

variable "bucket_policy_json" {
  description = "Additional bucket policy as JSON. It is merged with the deny-insecure-transport policy."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags merged onto every taggable resource, applied last."
  type        = map(string)
  default     = {}
}
