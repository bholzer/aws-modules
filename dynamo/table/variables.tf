variable "name" {
  type = string
  description = "Name of the table"
}

variable "billing_mode" {
  type = string
  description = "Billing mode for the table. Valid values are `PROVISIONED` and `PAY_PER_REQUEST`"
  default = "PROVISIONED"
}

variable "hash_key" {
  type = string
  description = "Table hash key"
}

variable "range_key" {
  type = string
  description = "Table range key"
  default = null
}

variable "write_capacity" {
  type = number
  description = "Number of write units for the table"
  default = null
}

variable "read_capacity" {
  type = number
  description = "Number of read units for the table"
  default = null
}

variable "restore_source_name" {
  type = string
  description = "Existing table to restore from"
  default = null
}

variable "restore_to_latest_time" {
  type = bool
  description = "Restore table to most recent recover point"
  default = false
}

variable "restore_date_time" {
  type = string
  description = "Point-in-time recovery value to recover from"
  default = null
}

variable "stream_enabled" {
  type = bool
  description = "Enables Streams for the table"
  default = false
}

variable "stream_view_type" {
  type = string
  description = "The type of information to write to the table stream. Valid values are `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE`, `NEW_AND_OLD_IMAGES`"
  default = null
}

variable "table_class" {
  type = string
  description = "Storage class of the table. Valid values are `STANDARD` and `STANDARD_INFREQUENT_ACCESS`"
  default = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "List of table attributes. Valid values for type are `S`, `N` and `B`"
}

variable "ttl_enabled" {
  type = bool
  desciption = "Enables TTL"
  default = false
}

variable "ttl_attribute_name" {
  type = string
  description = "Name of the table attribute to store the TTL timestamp in"
  default = null
}

variable "local_secondary_indexes" {
  type = list(any)
  description = "List of local secondary index definitions. Definition structure documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#local_secondary_index"
  default = []
}

variable "global_secondary_indexes" {
  type = list(any)
  description = "List of global secondary index definitions. Definition structure documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#global_secondary_index"
  default = []
}

variable "point_in_time_recovery_enabled" {
  type = bool
  description = "Enables point-in-time recovery for the table"
  default = false
}

variable "replicas" {
  type = list(any)
  description = "List of replica definitions for the table. Definition structure: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#replica"
  default = []
}

variable "encryption_enabled" {
  type = bool
  description = "Enables encryption for the table"
  default = true
}

variable "kms_key_arn" {
  type = string
  description = "KMS key ARN. Defaults to `alias/aws/dynamodb`"
  default = null
}

variable "create_timeout" {
  type = string
  description = "Table create timeout"
  default = null
}

variable "update_timeout" {
  type = string
  description = "Table update timeout"
  default = null
}

variable "delete_timeout" {
  type = string
  description = "Table delete timeout"
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}