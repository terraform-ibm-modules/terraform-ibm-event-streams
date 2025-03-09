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

variable "access_tags" {
  type        = list(string)
  description = "The list of access tags associated with the Event Streams instance."
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

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Event Streams database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `kms_key_crn` variable. In addition, no policy is created if var.kms_encryption_enabled is set to false."
  default     = false
}

variable "skip_es_s2s_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that will allow all Event Streams instances in the given resource group access to read from the mirror source instance. This policy is required when creating a mirroring instance, and will only be created if a value is passed in the mirroring input."
  default     = false
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
  validation {
    condition     = var.schema_global_rule == null || contains(["NONE", "FULL", "FULL_TRANSITIVE", "FORWARD", "FORWARD_TRANSITIVE", "BACKWARD", "BACKWARD_TRANSITIVE"], coalesce(var.schema_global_rule, "NONE"))
    error_message = "The schema_global_rule must be null or one of 'NONE', 'FULL', 'FULL_TRANSITIVE', 'FORWARD', 'FORWARD_TRANSITIVE', 'BACKWARD', 'BACKWARD_TRANSITIVE'."
  }
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

variable "kms_encryption_enabled" {
  type        = bool
  description = "Set this to true to control the encryption keys used to encrypt the data that you store in IBM Cloud® Databases. If set to false, the data is encrypted by using randomly generated keys. For more info on Key Protect integration, see https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect. For more info on HPCS integration, see https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs"
  default     = false
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of the key management service (Key Protect or Hyper Protect Crypto Services) to use to encrypt the payload data. [Learn more](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-managing_encryption) about integrating Hyper Protect Crypto Services with Event Streams."
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

variable "service_credential_names" {
  description = "The mapping of names and roles for service credentials that you want to create for the Event streams."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for name, role in var.service_credential_names : contains(["Writer", "Reader", "Manager"], role)])
    error_message = "The specified service credential role is not valid. The following values are valid for service credential roles: 'Writer', 'Reader', 'Manager'"
  }
}

variable "metrics" {
  type        = list(string)
  description = "Enhanced metrics to activate, as list of strings. Only allowed for enterprise plans. Allowed values: 'topic', 'partition', 'consumers'."
  validation {
    condition     = alltrue([for name in var.metrics : contains(["topic", "partition", "consumers"], name)])
    error_message = "The specified metrics are not valid. The following values are valid for metrics: 'topic', 'partition', 'consumers'."
  }
  default = []
}

variable "quotas" {
  type = list(object({
    entity             = string
    producer_byte_rate = optional(number, -1)
    consumer_byte_rate = optional(number, -1)
  }))
  description = "Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota."
  default     = []
  validation {
    condition     = alltrue([for v in var.quotas : v.entity != "" && (v.producer_byte_rate >= 0 || v.consumer_byte_rate >= 0)])
    error_message = "The quota entity must be defined, and at least one of producer_byte_rate or consumer_byte_rate must be set to a non-negative value"
  }
}

variable "mirroring_topic_patterns" {
  type        = list(string)
  description = "The list of the topics to set in instance. Required only if creating mirroring instance."
  default     = null
}

variable "mirroring" {
  description = "Event Streams mirroring configuration. Required only if creating mirroring instance. For more information on mirroring, see https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring."
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

variable "iam_token_only" {
  type        = bool
  description = "If set to true, disables Kafka's SASL PLAIN authentication method, only allowing clients to authenticate with SASL OAUTHBEARER via IAM access token. For more information, see: https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-security. Only allowed for enterprise plans."
  default     = false
}
