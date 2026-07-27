

variable "resource_group_id" {
  description = "The resource group ID where the Event Streams instance is created."
  type        = string
}

variable "resource_tags" {
  type        = list(string)
  description = "Add user resource tags to the Event Streams instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "The list of access tags associated with the Event Streams instance."
  default     = []
}

variable "es_name" {
  description = "The name of the Event Streams instance."
  type        = string
}

variable "plan" {
  type        = string
  description = "The plan for the Event Streams instance. Possible values: `enterprise-3nodes-2tb`, `enterprise-gen2`."
  default     = "enterprise-3nodes-2tb"
  validation {
    condition     = contains(["enterprise-3nodes-2tb", "enterprise-gen2"], var.plan)
    error_message = "The specified plan is not a valid selection! Supported plans are: enterprise-3nodes-2tb or enterprise-gen2."
  }
}

variable "region" {
  type        = string
  description = "The region where the Event Streams instance is created."
  default     = "us-south"
}

variable "schemas" {
  type        = any
  description = "List of schema objects. Each schema must include `schema_id` and `schema` definition. Supports full Apache Avro specification with nested structures. Not supported on the `enterprise-gen2` plan. [Learn more](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-ES_schema_registry#ES_apache_avro_data_format)."
  default     = []
}
variable "schema_global_rule" {
  type        = string
  description = "Schema global compatibility rule. Allowed values are 'NONE', 'FULL', 'FULL_TRANSITIVE', 'FORWARD', 'FORWARD_TRANSITIVE', 'BACKWARD', 'BACKWARD_TRANSITIVE'. Not supported on the `enterprise-gen2` plan."
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
  description = "Set to true to skip the creation of an IAM authorization policy that permits Event Streams instances to read the encryption key from the KMS instance. For the classic `enterprise-3nodes-2tb` plan, the policy is scoped to the resource group with the `Reader` role. For the `enterprise-gen2` plan, the policy is account-scoped and includes the `Reader` and `Authorization Delegator` roles required for Block Storage for VPC key delegation. If set to false, pass in a value for the KMS instance in the kms_key_crn variable. In addition, no policy is created if var.kms_encryption_enabled is set to false."
  default     = false
}

variable "skip_es_s2s_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an Event Streams s2s IAM authorization policy to provision an Event Streams mirroring instance. This is required to read from the source cluster. This policy is required when creating mirroring instance."
  default     = false
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

variable "resource_keys" {
  description = "A list of service credential resource keys to be created for the Event Streams instance."
  type = list(object({
    name     = string
    role     = optional(string, "Reader")
    endpoint = optional(string, "private")
  }))
  default = []
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

variable "mirroring_topic_patterns" {
  type        = list(string)
  description = "The list of the topics to set in instance. Required only if creating mirroring instance. Not supported on the `enterprise-gen2` plan."
  default     = null
}

variable "mirroring" {
  description = "Event Streams mirroring configuration. Required only if creating mirroring instance. Not supported on the `enterprise-gen2` plan. For more information on mirroring, see https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring."
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
    schemas = optional(string)
  })
  default = null
}

variable "iam_token_only" {
  type        = bool
  description = "If set to true, disables Kafka's SASL PLAIN authentication method, only allowing clients to authenticate with SASL OAUTHBEARER via IAM access token. For more information, see: https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-security. Only allowed for enterprise plans."
  default     = false
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

variable "storage_size" {
  type        = number
  description = "Storage size of the Event Streams in GB. For `enterprise-3nodes-2tb`, possible values are `2048`, `4096`, `6144`, `8192`, `10240`, `12288`. For `enterprise-gen2`, possible values are `2000` (2TB), `4000` (4TB), `6000` (6TB). Storage capacity cannot be reduced after the instance is created."
  default     = 2048
}

variable "throughput" {
  type        = number
  description = "Throughput capacity in MB per second. For `enterprise-3nodes-2tb`, possible values are `150`, `300`, `450`. For `enterprise-gen2`, the only supported value is `100`."
  default     = 150
}
