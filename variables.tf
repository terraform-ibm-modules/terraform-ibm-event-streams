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
  description = "Throughput capacity in MB per second. for enterprise instance only. Options are: 150, 300, 450. Default is 150."
  default     = "150"
}

variable "storage_size" {
  type        = number
  description = "Storage size of the event streams in GB. for enterprise instance only. Options are: 2048, 4096, 6144, 8192, 10240, 12288. Default is 2048.      Note: When throughput is 300, storage_size starts from 4096,  when throughput is 450, storage_size starts from 6144."
  default     = "2048"
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
  description = "Range of IPs that have the access. For enterprise instance only. Specify 1 or more IP range in CIDR format."
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether or not you want to skip applying an authorization policy to your kms instance."
  default     = true
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

variable "topics" {
  type = list(object(
    {
      name       = string
      partitions = number
      config     = object({})
    }
  ))
  description = "List of topics. For lite plan only one topic is allowed."
  default = [
    {
      name       = "topic-1"
      partitions = 1
      config = {
        "cleanup.policy"  = "delete"
        "retention.ms"    = "86400000"
        "retention.bytes" = "10485760"
        "segment.bytes"   = "10485760"
      }
    },
    {
      name       = "topic-2"
      partitions = 1
      config = {
        "cleanup.policy"  = "delete"
        "retention.ms"    = "86400000"
        "retention.bytes" = "10485760"
        "segment.bytes"   = "10485760"
      }
    }
  ]
}

variable "kms_key_crn" {
  type        = string
  description = "(Optional) The root key CRN of a Key Management Service like Key Protect or Hyper Protect Crypto Service (HPCS) that you want to use for disk encryption. If null, database is encrypted by using randomly generated keys. See https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok for current list of supported regions for BYOK"
  default     = null
}

variable "existing_kms_instance_guid" {
  description = "(Optional) The GUID of the Hyper Protect or Key Protect instance in which the key specified in var.kms_key_crn is coming from. Only required if skip_iam_authorization_policy is false"
  type        = string
  default     = null
}

variable "backup_encryption_key_crn" {
  type        = string
  description = "(Optional) The CRN of a Key Protect Key to use for encrypting backups. If left null, the value passed for the 'kms_key_crn' variable will be used. Take note that Hyper Protect Crypto Services for IBM Cloud® Databases backups is not currently supported."
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "Creation timeout value of the Event Streams module. Use 3h when creating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage_size"
  default     = "3h"
}

variable "update_timeout" {
  type        = string
  description = "Updating timeout value of the Event Streams module. Use 1h when updating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage_size."
  default     = "1h"
}

variable "delete_timeout" {
  type        = string
  description = "Deleting timeout value of the Event Streams module"
  default     = "15m"
}
