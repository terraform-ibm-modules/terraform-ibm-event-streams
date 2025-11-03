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

variable "plan" {
  type        = string
  description = "The plan for the Event Streams instance. Possible values: `lite` and `standard`."
  default     = "standard"
  validation {
    condition     = contains(["lite", "standard"], var.plan)
    error_message = "The specified plan is not a valid selection! Supported plans are: lite, standard."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "List of tags associated with the Event Streams instance"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "The list of access tags associated with the Event Streams instance."
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
  description = "The list of topics to apply to resources. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/security-enforced/DA-schemas-topics-cbr.md#options-with-topics)."
  default     = []
}


variable "resource_keys" {
  description = "The definition of the resource keys to generate. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/quickstart/DA-types.md#resource-keys)."
  type = list(object({
    name     = string
    role     = optional(string, "Reader")
    endpoint = optional(string, "public")
  }))
  default = []
}

variable "create_timeout" {
  type        = string
  description = "The timeout value for creating an Event Streams instance. Add 1 h for each level of non-default throughput. Add 30 min for each level of non-default storage size."
  default     = "30m"
}

variable "update_timeout" {
  type        = string
  description = "The timeout value for updating an Event Streams instance. Add 1 h for each level of non-default throughput. A 30 min for each level of non-default storage size."
  default     = "1h"
}

variable "delete_timeout" {
  type        = string
  description = "The timeout value for deleting an Event Streams instance."
  default     = "15m"
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
  description = "Service credential secrets configuration for Event Streams. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/security-enforced/DA-types.md#service-credential-secrets)."
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
