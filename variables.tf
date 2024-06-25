variable "bucket_name" {
  type        = string
  description = "The name of the bucket. Conflicts with bucket_prefix."
  default     = null
}

variable "bucket_name_prefix" {
  type        = string
  description = "The prefix of the bucket name. Conflicts with bucket_name."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the bucket and related resources."
  default     = {}
}

variable "abort_incomplete_multipart_upload" {
  type = object({
    days_after_initiation = number
  })

  description = "Abort incomplete multipart upload after a certain number of days."
  default = {
    days_after_initiation = 3
  }
}

variable "custom_kms_key_arn" {
  type        = string
  description = "The ARN of the custom KMS key to use for server-side encryption."
  default     = null
}

variable "enable_versioning" {
  type        = bool
  description = "Enables versioning for this bucket."
  default     = true
}

variable "public_access_block" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })

  description = "Configuration block to enable public access prevention."
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "object_lock" {
  type = object({
    enabled = bool
    default_retention = optional(object({
      mode  = string
      days  = optional(number)
      years = optional(number)
    }))
  })
  description = "Configuration block to enable object lock."

  default = {
    enabled           = true
    default_retention = null
  }
}


variable "enable_eventbridge_notification" {
  type        = bool
  description = "Enables eventbridge notification for this bucket."
  default     = true
}
