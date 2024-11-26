variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "fs-cloud"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "List of tags associated with the Event Steams instance"
  default     = []
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
      config     = map(string)
    }
  ))
  description = "List of topics. For lite plan only one topic is allowed."
  default     = []
}

variable "existing_kms_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto service in which the key specified in var.kms_key_crn is coming from"
  type        = string
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of a Hyper Protect Crypto Service (HPCS) that you want to use for disk encryption. See https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs&interface=ui for more information on integrating HPCS with Event Streams instance."
}

variable "mirroring_enabled" {
  type        = bool
  description = "Set this to true to enable mirroring. Mirroring enables messages in one Event Streams service instance to be continuously copied to a second instance to increase resiliency. See https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring."
  default     = false
}

variable "mirroring_topic_patterns" {
  type        = list(string)
  description = "The list of the topics to set in instance. Required only if var.mirroring_enabled is set to true."
  default     = null
}

variable "mirroring" {
  description = "Configuration for the mirroring setup. (Optional) Valid values for 'type' are 'rename', 'none', or 'use_alias'. If 'type' is set to 'rename', then 'rename' object must include the following fields: 'add_prefix', 'add_suffix', 'remove_prefix', and 'remove_suffix'."
  type = object({
    source_crn   = string
    source_alias = string
    target_alias = string
    options = optional(object({
      topic_name_transform = object({
        type = string
        rename = optional(object({
          add_prefix    = optional(string)
          add_suffix    = optional(string)
          remove_prefix = optional(string)
          remove_suffix = optional(string)
        }))
      })
      group_id_transform = object({
        type = string
        rename = optional(object({
          add_prefix    = optional(string)
          add_suffix    = optional(string)
          remove_prefix = optional(string)
          remove_suffix = optional(string)
        }))
      })
    }))
  })
  default = null
}
