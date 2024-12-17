variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The region where the Event Streams are created."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "The prefix to apply to all resources created by this example."
  default     = "event-streams-com"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example. If not specified, a new resource group is created."
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "The list of tags associated with the Event Steams instance."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "The list of access tags associated with the Event Steams instance."
  default     = []
}
