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
  description = "Add user resource tags to the Event Streams instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Add access management tags to the Event Streams instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
  default     = []
}
