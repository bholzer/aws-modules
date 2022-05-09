variable "name" {
  type = string
  description = "Name of the queue"
}

variable "visibility_timeout_seconds" {
  type = number
  description = "Number of seconds for visibility timeout"
  default = null
}

variable "message_retention_seconds" {
  type = number
  description = "Number of seconds to retain messages"
  default = null
}

variable "max_message_size" {
  type = number
  description = "Maximum message size in bytes"
  default = null
}

variable "delay_seconds" {
  type = number
  description = "Number of seconds to delay message delivery"
  default = null
}

variable "receive_wait_time_seconds" {
  type = number
  description = "Number of seconds to wait for messages to be received"
  default = null
}

variable "fifo" {
  type = bool
  description = "Enable FIFO for the queue"
  default = null
}

variable "fifo_throughput_limit" {
  type = string
  description = "Specify how fifo throughput is is applied. Allowed values are `perQueue` and `perMessageGroupId`"
  default = null
}

variable "content_based_deduplication" {
  type = bool
  description = "Enables dedup for FIFO queue"
  default = null
}

variable "deduplication_scope" {
  type = string
  description = "Specify how message dedup is applied. Allowed values are `messageGroup` and `queue`"
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}