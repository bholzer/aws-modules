variable "name" {
  type = string
  description = "Name of the bucket"
}

variable "force_destroy" {
  type = bool
  description = "Forces deletion of all bucket objects during bucket deletion"
  default = false
}

variable "object_lock_enabled" {
  type = bool
  description = "Enables object locking"
  default = false
}

variable "acl" {
  type = string
  description = "The ACL to apply to the bucket. Valid values are `private`, `public-read`, `public-read-write`, `aws-exec-read`, `authenticated-read`, and `log-delivery-write`"
  default = "private"
}

variable "log_bucket_name" {
  type = string
  description = "Name of bucket to use as logging for this bucket"
  default = null
}

variable "sse_enabled" {
  type = bool
  description = "Enable encryption on the bucket"
  default = false
}

variable "sse_algorithm" {
  type = string
  description = "The algorithm for SSE to encrypt bucket. Valid values are `AES256` and `aws:kms`"
  default = "AES256"
}

variable "sse_kms_key_id" {
  type = string
  description = "KMS key to use for bucket encryption. Only used when `sse_algorithm` set to `aws:kms`"
  default = null
}

variable "versioning_enabled" {
  type = bool
  description = "Enable bucket versioning"
  default = false
}

variable "versioning_suspended" {
  type = bool
  description = "Suspend bucket versioning"
  default = false
}

variable "block_access" {
  type = bool
  description = "Block all public access to the bucket"
  default = true
}

variable "bucket_policy_json" {
  type = string
  description = "Bucket policy for the bucket"
  default = null
}

variable "lambda_notifications" {
  type = list(any)
  description = "List of lambda notification configurations. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification#lambda_function"
  default = []
}

variable "sns_notifications" {
  type = list(any)
  description = "List of SNS topic notification configurations. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification#topic"
  default = []
}

variable "sqs_notifications" {
  type = list(any)
  description = "List of SQS queue notification configurations. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification#queue"
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}