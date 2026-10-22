########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources. [Learn more](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui#create_rgs) about how to create a resource group."
  default     = "Default"
}

variable "region" {
  type        = string
  description = "The region in which the Event Streams resources are provisioned. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/region) about how to select different regions for different services."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to null or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

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

variable "resource_tags" {
  type        = list(string)
  description = "Add user resource tags to the Event Streams instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Add access management tags to the Event Streams instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
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
  description = "The list of topics to apply to resources. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/security-enforced-gen2/DA-schemas-topics-cbr.md#options-with-topics)."
  default     = []
}

variable "quotas" {
  type = list(object({
    entity             = string
    producer_byte_rate = optional(number, -1)
    consumer_byte_rate = optional(number, -1)
  }))
  description = "Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/security-enforced-gen2/DA-types.md#quotas)"
  default     = []
}

variable "resource_keys" {
  description = "A list of service credential resource keys to be created for the Event Streams instance. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/security-enforced-gen2/DA-types.md#resource-keys)."
  type = list(object({
    name     = string
    role     = optional(string, "Reader")
    endpoint = optional(string, "private")
  }))
  default = []
}

variable "iam_token_only" {
  type        = bool
  description = "If set to true, disables Kafka's SASL PLAIN authentication method, only allowing clients to authenticate with SASL OAUTHBEARER via IAM access token. For more information, see: https://cloud.ibm.com/docs/EventStreams-gen2?topic=EventStreams-gen2-security."
  default     = false
}

variable "create_timeout" {
  type        = string
  description = "The timeout value for creating an Event Streams instance. The `enterprise-gen2` plan typically provisions in minutes, but the default allows extra time for the instance and the virtual private endpoint (VPE) to become available."
  default     = "3h"
}

variable "update_timeout" {
  type        = string
  description = "The timeout value for updating an Event Streams instance."
  default     = "1h"
}

variable "delete_timeout" {
  type        = string
  description = "The timeout value for deleting an Event Streams instance."
  default     = "15m"
}

variable "storage_size" {
  type        = number
  description = "Storage size of the Event Streams in GB. Possible values are `2000` (2TB), `4000` (4TB), `6000` (6TB). Self-service scaling after provisioning is not yet available on the `enterprise-gen2` plan, so choose the size before you create the instance."
  default     = 2000
}

variable "throughput" {
  type        = number
  description = "Throughput capacity in MB per second. The only supported value is `100` (50 MB/s produce + 50 MB/s consume). Self-service scaling after provisioning is not yet available on the `enterprise-gen2` plan."
  default     = 100
}

########################################################################################################################
# Key Protect
########################################################################################################################

variable "skip_event_streams_kms_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of IAM authorization policies that permit Event Streams to access the Key Protect key. The policy is account-scoped and grants the `Reader` and `Authorization Delegator` roles. This policy is required in order to enable KMS encryption, so only skip creation if there is one already present in your account."
  default     = false
  nullable    = false
}

variable "existing_kms_key_crn" {
  type        = string
  description = "The CRN of a Key Protect key to use for Event Streams. If not specified, a key ring and key are created."
  default     = null
}

########################################################################################################################
# KMS properties required when creating an encryption key, rather than passing an existing key CRN.
########################################################################################################################


variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of a Key Protect instance. Required only when creating a new encryption key and key ring which will be used to encrypt event streams. To use an existing key, pass values for `existing_kms_key_crn`."
  default     = null
  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}(kms|hs-crypto):(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS instance CRN in the input 'existing_kms_instance_crn' is not valid."
  }
}

variable "kms_key_ring_name" {
  type        = string
  default     = "event-streams-key-ring"
  description = "The name for the new key ring to store the key. Applies only if `existing_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format. ."
}

variable "kms_key_name" {
  type        = string
  default     = "event-streams-key"
  description = "The name for the new root key. Applies only if existing_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud_api_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Event Streams instance. Leave this input empty if the same account owns both instances."
  sensitive   = true
  default     = null
}

##############################################################
# VPC / Virtual Private Endpoint (VPE)
##############################################################

variable "ibmcloud_vpe_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a virtual private endpoint (VPE) in the VPC in `vpe_vpc_id`. If not specified, the `ibmcloud_api_key` variable is used. Specify this key if the VPC is in an account that's different from the Event Streams instance. Leave this input empty if the same account owns both. When set, an authorization policy that allows VPEs from the VPC account to access Event Streams is created, unless `skip_vpe_auth_policy` is `true`."
  sensitive   = true
  default     = null
}

variable "skip_vpe_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of the IAM authorization policy that allows virtual private endpoints (VPE) from the account that owns the VPC to access the Event Streams instance. Only applies when `ibmcloud_vpe_api_key` is set (VPC in a different account). Skip only if the policy already exists in your account."
  default     = false
  nullable    = false
}

variable "vpe_resource_group_id" {
  type        = string
  description = "The ID of the resource group in which to create the VPE. Resource group IDs are specific to an account, so set this if the VPC is in a different account (`ibmcloud_vpe_api_key` is set). If not set, the ID of the resource group of the Event Streams instance is used."
  default     = null
}

variable "vpe_vpc_id" {
  type        = string
  description = "The ID of an existing VPC in which to create a virtual private endpoint (VPE) to the Event Streams instance. Required, because the `enterprise-gen2` plan is reachable through a VPE only. Terraform must run from inside the VPC (for example on a Schematics agent) so that topics can be reached."
  validation {
    condition     = var.vpe_vpc_id != null && trimspace(var.vpe_vpc_id) != ""
    error_message = "A VPC ID must be passed in `vpe_vpc_id`. The `enterprise-gen2` plan is reachable through a virtual private endpoint (VPE) only."
  }
}

variable "vpe_subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets in `vpe_vpc_id` in which to place the VPE. Required."
  validation {
    condition     = length(var.vpe_subnet_ids) > 0
    error_message = "At least one subnet ID must be passed in `vpe_subnet_ids`."
  }
}

variable "vpe_security_group_ids" {
  type        = list(string)
  description = "The IDs of the security groups in `vpe_vpc_id` to attach to the VPE. Required, because the VPE must be reachable for the topics to be created."
  validation {
    condition     = length(var.vpe_security_group_ids) > 0
    error_message = "At least one security group ID must be passed in `vpe_security_group_ids`."
  }
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
  description = "A single context-based restriction rule to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/security-enforced-gen2/DA-schemas-topics-cbr.md#options-with-cbr)."
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
  description = "Service credential secrets configuration for Event Streams. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/security-enforced-gen2/DA-types.md#service-credential-secrets)."
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
