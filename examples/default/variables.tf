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

variable "plan" {
  type        = string
  description = "Plan for the event streams instance. lite, standard or enterprise-3nodes-2tb"
  default     = "standard"
}

variable "throughput" {
  type        = number
  description = "Throughput capacity in MB per second."
  default     = "150" # For lite and standard plan, the allowed value of throughput is 150 MB per second. For enterprise plan it can take any value.
}

variable "storage_size" {
  type        = number
  description = "Storage size of the event streams in GB."
  default     = "2048"
}

variable "service_endpoints" {
  type        = string
  description = "The type of service endpoint(public,private or public-and-private) to be used for connection."
  default     = "public"
}

variable "private_ip_allowlist" {
  type        = string
  description = "Range of IPs that have the access."
  default     = null
}

variable "schemas" {
  type = list(object(
    {
      schema_id = string
      schema = object({
        type = string
        name = string
      })
    }
  ))
  description = "The list of schema object which contains schema id and format of the schema"
  default     = []
}
