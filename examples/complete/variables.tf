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
  description = "The plan for the Event Streams instance. Possible values: `lite`, `standard`, `enterprise-3nodes-2tb`, `enterprise-gen2`."
  default     = "standard"
}

variable "service_endpoints" {
  type        = string
  description = "The type of service endpoints. Possible values: 'public', 'private', 'public-and-private'. The `enterprise-gen2` plan supports private endpoints only (enforced by the service); set this to 'private' when using the gen2 plan."
  default     = "public"
}

variable "vpe_vpc_id" {
  type        = string
  description = "ID of an existing VPC in which to create a VPE to the Event Streams instance. Required for the `enterprise-gen2` plan. When set, Terraform must run inside the VPC (e.g. on a Schematics agent). When null, no VPE is created."
  default     = null
}

variable "vpe_subnet_id" {
  type        = string
  description = "ID of the subnet in `vpe_vpc_id` in which to place the VPE. Required when `vpe_vpc_id` is set."
  default     = null
}

variable "vpe_security_group_id" {
  type        = string
  description = "ID of an existing security group in `vpe_vpc_id` to attach to the VPE. Required when `vpe_vpc_id` is set."
  default     = null
}
