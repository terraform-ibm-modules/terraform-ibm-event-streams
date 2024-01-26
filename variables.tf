##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  description = "The resource group ID where the Event Streams instance will be created."
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
  description = "Throughput capacity in MB per second. For enterprise instance only. Options are: 150, 300, 450."
  default     = "150"
  validation {
    condition = anytrue([
      var.throughput == 150,
      var.throughput == 300,
      var.throughput == 450,
    ])
    error_message = "Supported throughput values are: 150, 300, 450."
  }
}

variable "storage_size" {
  type        = number
  description = "Storage size of the event streams in GB. For enterprise instance only. Options are: 2048, 4096, 6144, 8192, 10240, 12288,. Note: When throughput is 300, storage_size starts from 4096, when throughput is 450, storage_size starts from 6144. Storage capacity cannot be scaled down once instance is created."
  default     = "2048"
  validation {
    condition = anytrue([
      var.storage_size == 2048,
      var.storage_size == 4096,
      var.storage_size == 6144,
      var.storage_size == 8192,
      var.storage_size == 10240,
      var.storage_size == 12288,
    ])
    error_message = "Supported throughput values are: 2048, 4096, 6144, 8192, 10240, 12288."
  }
}

variable "service_endpoints" {
  type        = string
  description = "Specify whether you want to enable the public, private, or both service endpoints. Supported values are 'public', 'private', or 'public-and-private'."
  default     = "public"
  validation {
    condition     = contains(["public", "public-and-private", "private"], var.service_endpoints)
    error_message = "The specified service endpoint is not a valid selection! Supported options are: public, public-and-private or private."
  }
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
  default     = []
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of a Key Management Services like Key Protect or Hyper Protect Crypto Services (HPCS) that you want to use payload data encryption. Only used if var.kms_encryption_enabled is set to true. Note an authorization policy to allow the Event Streams service to access the key management service instance as a Reader MUST be configured in advance and should not be managed as part of the same terraform state as the event streams instance, see https://cloud.ibm.com/docs/account?topic=account-serviceauth"
  default     = null
  validation {
    condition = anytrue([
      var.kms_key_crn == null,
      can(regex(".*kms.*", var.kms_key_crn)),
      can(regex(".*hs-crypto.*", var.kms_key_crn)),
    ])
    error_message = "Value must be the root key CRN from either the Key Protect or Hyper Protect Crypto Service (HPCS)"
  }
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

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
  }))
  description = "(Optional, list) List of CBR rules to create"
  default     = []
  # Validation happens in the rule module
}
