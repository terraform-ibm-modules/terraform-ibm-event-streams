

variable "resource_group_id" {
  description = "The resource group ID where the Event Streams instance is created."
  type        = string
}

variable "tags" {
  type        = list(string)
  description = "The list of tags associated with the Event Steams instance."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "The list of access tags associated with the Event Steams instance."
  default     = []
}

variable "es_name" {
  description = "The name of the Event Streams instance."
  type        = string
}

variable "region" {
  type        = string
  description = "The region where the Event Streams are created."
  default     = "us-south"
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

variable "schema_global_rule" {
  type        = string
  description = "Schema global compatibility rule. Allowed values are 'NONE', 'FULL', 'FULL_TRANSITIVE', 'FORWARD', 'FORWARD_TRANSITIVE', 'BACKWARD', 'BACKWARD_TRANSITIVE'."
  default     = null
}

variable "topics" {
  type = list(object(
    {
      name       = string
      partitions = number
      config     = map(string)
    }
  ))
  description = "The list of topics to apply to resources. Only one topic is allowed for Lite plan instances."
  default     = []
}

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Event Streams database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing_kms_instance_guid variable. In addition, no policy is created if var.kms_encryption_enabled is set to false."
  default     = false
}

variable "skip_es_s2s_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an Event Streams s2s IAM authorization policy to provision an Event Streams mirroring instance. This is required to read from the source cluster. This policy is required when mirroring_enabled is set to true."
  default     = false
}

variable "existing_kms_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto service in which the key specified in var.kms_key_crn is coming from"
  type        = string
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of the key management service (Key Protect or Hyper Protect Crypto Services) to use to encrypt the payload data."
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

variable "service_credential_names" {
  description = "The mapping of names and roles for service credentials that you want to create for the Event streams."
  type        = map(string)
  default     = {}
}

variable "metrics" {
  type        = list(string)
  description = "Enhanced metrics to activate, as list of strings. Allowed values: 'topic', 'partition', 'consumers'."
  default     = []
}

variable "quotas" {
  type = list(object({
    entity             = string
    producer_byte_rate = optional(number, -1)
    consumer_byte_rate = optional(number, -1)
  }))
  description = "Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota."
  default     = []
}

##############################################################
# Mirroring
##############################################################

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
  description = "Mirror configuration."
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
