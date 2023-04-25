variable "resource_group_id" {
  description = "ID of resource group to use when creating the event stream instance"
  type        = string
}

variable "es_name" {
  type        = string
  description = "The name to give the IBM Event Streams instance created by this module."
}

variable "plan" {
  type        = string
  description = "Plan for the event streams instance : lite, standard or enterprise-3nodes-2tb"
  default     = "standard"
  validation {
    condition     = contains(["lite", "standard", "enterprise-3nodes-2tb"], var.plan)
    error_message = "The specified plan is not a valid selection! Supported plans are: lite, standard or enterprise-3nodes-2tb."
  }
}

variable "tags" {
  type        = list(string)
  description = "List of tags associated with the Event Steams instance"
  default     = []
}

variable "region" {
  type        = string
  description = "IBM Cloud region where event streams will be created"
  default     = "us-south"
}

variable "throughput" {
  type        = number
  description = "Throughput capacity in MB per second. For lite and standard plan, the allowed value of throughput is 150 MB per second. For enterprise plan it can take any value."
  default     = "150"
}

variable "storage_size" {
  type        = number
  description = "Storage size of the event streams in GB."
  # For lite and standard plan, the allowed value is 2048 GB. For enterprise plan refer (https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-ES_scaling_capacity#ES_storage_capacity) for allowed values.
  # Storage capacity cannot be scaled down once instance is created.
  # Storage capacity cannot be scaled up in lite and standard plan.
  default = "2048"
}

variable "service_endpoints" {
  type        = string
  description = "The type of service endpoint(public,private or public-and-private) to be used for connection."
  default     = "private"
  validation {
    condition     = contains(["public", "public-and-private", "private"], var.service_endpoints)
    error_message = "The specified service endpoint is not a valid selection! Supported options are: public, public-and-private or private."
  }
}

variable "private_ip_allowlist" {
  type        = string
  description = "Range of IPs that have the access."
  default     = null
}

variable "schemas" {
  type = list(object(
    {
      schema_id = string
      schema = object({
        type = string
        name = string
      })
    }
  ))
  description = "The list of schema object which contains schema id and format of the schema"
  default     = []
}

variable "topic_names" {
  type        = list(string)
  description = "The name of the topic instance"
  default     = ["topic_1", "topic_2", "topic_3"] # For lite plan only one topic is allowed
  validation {
    condition = alltrue([
      for name in var.topic_names : length(name) <= 200
    ])
    error_message = "Topic name should not be more than 200 characters long"
  }
}

variable "partitions" {
  type        = list(number)
  description = "The number of partitions in which the topics are to be divided"
  default     = [1, 1, 1] # For lite plan only one partition per topic is allowed. For the standard plan partition value should not exceed 100 per topic. For enterprise plan it can be set to any value depending upon the capacity.
}

variable "segment_bytes" {
  type        = list(number)
  description = "The maximum size of a partition in bytes"
  default     = null # For standard plan the range of allowed value is [100 KiB,500 MiB] and for enterprise plan the range of allowed value is [100KiB, 2 TiB]
}

variable "cleanup_policy" {
  type        = list(string)
  description = "Supported types - delete, compact. delete - deletes segments after the retention time. compact - retains the latest value"
  default     = null
  validation {
    condition = alltrue([
      for policy in var.cleanup_policy : contains(["delete", "compact", "compact,delete"], policy)
    ])
    error_message = "Cleanup policy can only take ['delete','compact','compact,delete'] as values"
  }
}

variable "retention_ms" {
  type        = list(number)
  description = "Time in ms for which the messages will be retained"
  default     = null
}

variable "retention_bytes" {
  type        = list(number)
  description = "Length of messages to be retained in bytes"
  default     = null # for standard plan retention bytes should be in the range [100 KiB, 1 GiB] and for enterprise plan it should be in the range [100 KiB, 2 TiB]
}

variable "kms_key_crn" {
  type        = string
  description = "(Optional) The root key CRN of a Key Management Service like Key Protect or Hyper Protect Crypto Service (HPCS) that you want to use for disk encryption. If null, database is encrypted by using randomly generated keys. See https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok for current list of supported regions for BYOK"
  default     = null
}

variable "backup_encryption_key_crn" {
  type        = string
  description = "(Optional) The CRN of a Key Protect Key to use for encrypting backups. If left null, the value passed for the 'kms_key_crn' variable will be used. Take note that Hyper Protect Crypto Services for IBM Cloud® Databases backups is not currently supported."
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "Creation timeout value of the Event Streams module." # use 3h when creating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage_size
  default     = "3h"
}

variable "update_timeout" {
  type        = string
  description = "Updating timeout value of the Event Streams module." # use 1h when updating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage_size
  default     = "1h"
}

variable "delete_timeout" {
  type        = string
  description = "Deleting timeout value of the Event Streams module"
  default     = "15m"
}
