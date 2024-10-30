variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Optional. The prefix to append to all resources that this solution creates."
  default     = null
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or the existing resource group to provision the Event Streams instance. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  default     = null
}

variable "es_name" {
  description = "The name of the Event Streams instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  type        = string
  default     = "event-streams"
}

variable "region" {
  type        = string
  description = "The region where the Event Streams are created."
  default     = "us-south"
}

variable "resource_tags" {
  type        = list(string)
  description = "The list of tags associated with the Event Streams instance."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "The list of access tags associated with the Event Streams instance."
  default     = []
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

variable "topics" {
  type = list(object(
    {
      name       = string
      partitions = number
      config     = object({})
    }
  ))
  description = "The list of topics to apply to resources. Only one topic is allowed for Lite plan instances. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/quickstart/DA-schemas-topics-cbr.md)."
  default     = []
}

variable "service_credential_names" {
  description = "The mapping of names and roles for service credentials that you want to create for the Event streams.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/quickstart/DA-types.md#svc-credential-name)"
  type        = map(string)
  default     = {}
}

variable "metrics" {
  type        = list(string)
  description = "Enhanced metrics to activate, as list of strings. Allowed values: 'topic', 'partition', 'consumers'."
  default     = []
}
