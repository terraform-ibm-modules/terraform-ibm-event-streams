variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or the existing resource group in which to provision the Event Streams instance."
}

variable "es_name" {
  description = "The name to give the Event Streams instance created by this solution."
  type        = string
}

variable "region" {
  type        = string
  description = "The region where the Event Streams are created."
  default     = "us-south"
}

variable "resource_tags" {
  type        = list(string)
  description = "The list of tags associated with the Event Steams instance."
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
