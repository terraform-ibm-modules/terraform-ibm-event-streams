

variable "resource_group_id" {
  description = "ID of resource group to use when creating the event stream instance"
  type        = string
}

variable "tags" {
  type        = list(string)
  description = "List of tags associated with the Event Steams instance"
  default     = []
}

variable "es_name" {
  description = "Name of the event streams instance"
  type        = string
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
  description = "The root key CRN of the Hyper Protect Crypto Service (HPCS) to use for disk encryption."
}

variable "existing_kms_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto Services instance."
  type        = string
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all event streams instances in the provided resource group reader access to the instance specified in the existing_kms_instance_guid variable."
  default     = false
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
