########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision resource in."
  default     = "Default"
  nullable    = false
}

variable "region" {
  type        = string
  description = "The region to provision resources to."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-0205-es. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA.prefix.md)."

  validation {
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }
  validation {
    condition     = length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

########################################################################################################################
# Event Streams
########################################################################################################################

variable "event_streams_name" {
  description = "The name of the Event Streams instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  type        = string
  default     = "event-streams"
}

variable "event_stream_instance_resource_tags" {
  type        = list(string)
  description = "List of tags associated with the Event Steams instance"
  default     = []
}

variable "event_stream_instance_access_tags" {
  type        = list(string)
  description = "The list of access tags associated with the Event Steams instance."
  default     = []
}

variable "schemas" {
  type = list(object({
    schema_id = string
    schema = object({
      type = string
      name = string
      fields = optional(list(object({
        name = string
        type = string
      })))
    })
  }))
  description = "The list of schema objects. Include the `schema_id`, `type` and `name` of the schema in the `schema` object. Learn more: https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-schemas-topics-cbr.md#options-with-schemas."
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
      config     = object({})
    }
  ))
  description = "The list of topics to apply to resources. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-schemas-topics-cbr.md#options-with-topics)."
  default     = []
}

variable "metrics" {
  type        = list(string)
  description = "Enhanced metrics to activate, as list of strings. Allowed values: 'topic', 'partition', 'consumers'."
  default     = []

  validation {
    condition     = alltrue([for name in var.metrics : contains(["topic", "partition", "consumers"], name)])
    error_message = "The specified metrics are not valid. The following values are valid for metrics: 'topic', 'partition', 'consumers'."
  }
}

variable "quotas" {
  type = list(object({
    entity             = string
    producer_byte_rate = optional(number, -1)
    consumer_byte_rate = optional(number, -1)
  }))
  description = "Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#quotas)"
  default     = []
}

variable "service_credential_names" {
  description = "The mapping of names and roles for service credentials that you want to create for the Event streams.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#svc-credential-name)"
  type        = map(string)
  default     = {}
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

##############################################################
# Mirroring
##############################################################

variable "mirroring_topic_patterns" {
  type        = list(string)
  description = "The list of the topics to set in instance. Required only if creating mirroring instance."
  default     = []
}

variable "mirroring" {
  description = "Event Streams mirroring configuration. Required only if creating mirroring instance. For more information on mirroring, see https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#mirroring and https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring."
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

variable "skip_event_streams_s2s_iam_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of an Event Streams s2s IAM authorization policy to provision an Event Streams mirroring instance. This is required to read from the source cluster. This policy is required when creating mirroring instance."
  default     = false
  nullable    = false
}

########################################################################################################################
# Key Protect
########################################################################################################################

variable "skip_event_streams_kms_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of IAM authorization policies that permits all Event Streams instances in the given resource group 'Reader' access to the Key Protect or Hyper Protect Crypto Services key. This policy is required in order to enable KMS encryption, so only skip creation if there is one already present in your account."
  default     = false
  nullable    = false
}

variable "existing_event_streams_kms_key_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services key to use for Event Streams. If not specified, a key ring and key are created."
  default     = null
}

########################################################################################################################
# KMS properties required when creating an encryption key, rather than passing an existing key CRN.
########################################################################################################################


variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services instance. Required only when creating a new encryption key and key ring which will be used to encrypt event streams. To use an existing key, pass values for `existing_event_streams_kms_key_crn`."
  default     = null
  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}(kms|hs-crypto):(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS instance CRN in the input 'existing_kms_instance_crn' in not valid."
  }
}

variable "kms_key_ring_name" {
  type        = string
  default     = "event-streams-key-ring"
  description = "The name for the new key ring to store the key. Applies only if `existing_event_streams_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format. ."
}

variable "kms_key_name" {
  type        = string
  default     = "event-streams-key"
  description = "The name for the new root key. Applies only if existing_event_streams_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud_api_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Event Streams instance. Leave this input empty if the same account owns both instances."
  sensitive   = true
  default     = null
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
  description = "A single context-based restriction rule to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-schemas-topics-cbr.md#options-with-cbr)."
  default     = []
  nullable    = false
  # Additional validation happens in the rule module
  validation {
    condition     = !(length(var.cbr_rules) > 1)
    error_message = "Only one context-based restriction rule is allowed."
  }
}

#############################################################################
# Secrets Manager Service Credentials
#############################################################################
variable "existing_secrets_manager_instance_crn" {
  type        = string
  description = "The CRN of existing secrets manager to use to create service credential secrets for Event Streams instance."
  default     = null
}

variable "existing_secrets_manager_endpoint_type" {
  type        = string
  description = "The endpoint type to use if `existing_secrets_manager_instance_crn` is specified. Possible values: public, private."
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.existing_secrets_manager_endpoint_type)
    error_message = "Only \"public\" and \"private\" are allowed values for 'existing_secrets_endpoint_type'."
  }
}
variable "service_credential_secrets" {
  type = list(object({
    secret_group_name        = string # pragma: allowlist secret
    secret_group_description = optional(string)
    existing_secret_group    = optional(bool)
    service_credentials = list(object({
      secret_name                                 = string
      service_credentials_source_service_role_crn = string
      secret_labels                               = optional(list(string))
      secret_auto_rotation                        = optional(bool)
      secret_auto_rotation_unit                   = optional(string)
      secret_auto_rotation_interval               = optional(number)
      service_credentials_ttl                     = optional(string)
      service_credential_secret_description       = optional(string)
    }))
  }))
  default     = []
  nullable    = false
  description = "Service credential secrets configuration for Event Streams. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#service-credential-secrets)."
  validation {
    # Service roles CRNs can be found at https://cloud.ibm.com/iam/roles, select Event Streams and select the role
    condition = alltrue([
      for group in var.service_credential_secrets : alltrue([
        # crn:v?:bluemix; two non-empty segments; three possibly empty segments; :serviceRole or role: non-empty segment
        for credential in group.service_credentials : can(regex("^crn:v[0-9]:bluemix(:..*){2}(:.*){3}:(serviceRole|role):..*$", credential.service_credentials_source_service_role_crn))
      ])
    ])
    error_message = "service_credentials_source_service_role_crn input variable must be a serviceRole CRN. See https://cloud.ibm.com/iam/roles"
  }
  validation {
    condition     = !(length(var.service_credential_secrets) > 0 && var.existing_secrets_manager_instance_crn == null)
    error_message = "'existing_secrets_manager_instance_crn' is required when adding service credentials with the 'service_credential_secrets' input."
  }
}

variable "skip_event_streams_secrets_manager_auth_policy" {
  type        = bool
  default     = false
  nullable    = false
  description = "Whether an IAM authorization policy is created for Secrets Manager instance to create a service credential secrets for Event Streams.If set to false, the Secrets Manager instance passed by the user is granted the Key Manager access to the Event Streams instance created by the Deployable Architecture. Set to `true` to use an existing policy. The value of this is ignored if any value for 'existing_secrets_manager_instance_crn' is not passed."
}
