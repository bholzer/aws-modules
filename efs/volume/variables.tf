variable "name" {
  type = string
  description = "Name of the EFS volume."
}

variable "encrypted" {
  type = bool
  description = "Enables encryption for the volume."
  default = false
}

variable "kms_key_id" {
  type = string
  description = "ID of KMS key to use for volume encryption."
  default = null
}

variable "performance_mode" {
  type = string
  description = "Performance mode of the volume. Valid values are `generalPurpose` or `maxIO`."
  default = null
}

variable "lifecycle_policy" {
  type = any
  description = "Lifecycle policy configuration for volume contents."
  default = null
}

variable "vpc_id" {
  type = string
  description = "ID of VPC from which volume can be accessed."
}

variable "subnet_ids" {
  type = list(string)
  description = "list of subnet IDs where mount targets will be placed."
}

variable "tags" {
  type = map(string)
}
