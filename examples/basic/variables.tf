variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
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
  default     = "event-streams"
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

variable "plan" {
  type        = string
  description = "The plan for the Event Streams instance. Possible values: `lite`, `standard`, `enterprise-3nodes-2tb`, `enterprise-gen2`."
  default     = "standard"
}

variable "service_endpoints" {
  type        = string
  description = "The type of service endpoints. Possible values: 'public', 'private', 'public-and-private'. Ignored for the `enterprise-gen2` plan (private-only by default)."
  default     = "public"
}

variable "throughput" {
  type        = number
  description = "Throughput capacity in MB per second. For `enterprise-3nodes-2tb`, possible values are `150`, `300`, `450`. For `enterprise-gen2`, the only supported value is `100`."
  default     = 150
}

variable "storage_size" {
  type        = number
  description = "Storage size of the Event Streams in GB. For `enterprise-3nodes-2tb`, possible values are `2048`–`12288`. For `enterprise-gen2`, any value between `1000` and `4000` is accepted."
  default     = 2048
}
