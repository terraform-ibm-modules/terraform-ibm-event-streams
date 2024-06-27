##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  description = "The resource group ID where the Event Streams instance is created."
  type        = string
}

variable "es_name" {
  type        = string
  description = "The name to give the Event Streams instance created by this module."
}

variable "plan" {
  type        = string
  description = "The plan for the Event Streams instance. Possible values: `lite`, `standard`, `enterprise-3nodes-2tb`."
  default     = "standard"
  validation {
    condition     = contains(["lite", "standard", "enterprise-3nodes-2tb"], var.plan)
    error_message = "The specified plan is not a valid selection! Supported plans are: lite, standard or enterprise-3nodes-2tb."
  }
}

variable "tags" {
  type        = list(string)
  description = "The list of tags associated with the Event Steams instance."
  default     = []
}

variable "region" {
  type        = string
  description = "The region where the Event Streams are created."
  default     = "us-south"
}

variable "throughput" {
  type        = number
  description = "Throughput capacity in MB per second. Applies only to Enterprise plan instances. Possible values: `150`, `300`, `450`."
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
  description = "Storage size of the Event Streams in GB. Applies only to Enterprise plan instances. Possible values: `2048`, `4096`, `6144`, `8192`, `10240`, `12288`. Storage capacity cannot be reduced after the instance is created. When the `throughput` input variable is set to `300`, storage size starts at 4096. When `throughput` is `450`, storage size starts starts at `6144`."
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
  description = "The type of service endpoints. Possible values: 'public', 'private', 'public-and-private'."
  default     = "public"
  validation {
    condition     = contains(["public", "public-and-private", "private"], var.service_endpoints)
    error_message = "The specified service endpoint is not valid. Supported options are public, public-and-private, or private."
  }
}

variable "schemas" {
  type = list(object(
    {
      schema_id = string
      schema = object({
        type = string
        name = string
        fields = optional(list(object({
          name = string
          type = string
        })))
      })
    }
  ))
  description = "The list of schema objects. Include the `schema_id` and the `type` and `name` of the schema in the `schema` object."
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
  description = "The list of topics to apply to resources. Only one topic is allowed for Lite plan instances."
  default     = []
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of the key management service (Key Protect or Hyper Protect Crypto Services) to use to encrypt the payload data. [Learn more](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-managing_encryption) about integrating Hyper Protect Crypto Services with Event Streams. Configure an authorization policy to allow the Event Streams service to access the key management service instance with the reader role ([Learn more](https://cloud.ibm.com/docs/account?topic=account-serviceauth)). You can't manage the policy in the same Terraform state file as the Event Streams service instance ([Learn more](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-managing_encryption#using_encryption))."
  default     = null
  validation {
    condition = anytrue([
      var.kms_key_crn == null,
      can(regex(".*kms.*", var.kms_key_crn)),
      can(regex(".*hs-crypto.*", var.kms_key_crn)),
    ])
    error_message = "Must be the root key CRN from either the Key Protect or Hyper Protect Crypto Service."
  }
}

variable "create_timeout" {
  type        = string
  description = "The timeout value for creating an Event Streams instance. Specify `3h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. Add 30 min for each level of non-default storage size."
  default     = "3h"
}

variable "update_timeout" {
  type        = string
  description = "The timeout value for updating an Event Streams instance. Specify `1h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. A 30 min for each level of non-default storage size."
  default     = "1h"
}

variable "delete_timeout" {
  type        = string
  description = "The timeout value for deleting an Event Streams instance."
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
  description = "The list of context-based restriction rules to create."
  default     = []
  # Validation happens in the rule module
}
