variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "IBM Cloud region where event streams will be created"
  default     = "jp-tok"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "event_streams"
}

variable "resource_tags" {
  type        = list(string)
  description = "List of tags associated with the Event Steams instance"
  default     = []
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "service_endpoints" {
  type        = string
  description = "The type of service endpoint(public,private or public-and-private) to be used for connection."
  default     = "public"
}
