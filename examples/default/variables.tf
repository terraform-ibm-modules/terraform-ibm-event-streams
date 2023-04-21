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

variable "topic_names" {
  type        = list(string)
  description = "The name of the topic instance"
  default     = ["topic_1", "topic_2", "topic_3"] # For lite plan only one topic is allowed
}

variable "partitions" {
  type        = list(number)
  description = "The number of partitions in which the topics are to be divided"
  default     = [1, 1, 1] # For lite plan only one partition per topic is allowed. For the standard plan partition value should not exceed 100 per topic. For enterprise plan it can be set to any value depending upon the capacity.
}

variable "segment_bytes" {
  type        = list(number)
  description = "The maximum size of a partition in bytes"
  default     = [10485760, 10485760, 10485760] # For standard plan the range of allowed value is [100 KiB,500 MiB] and for enterprise plan the range of allowed value is [100KiB, 2 TiB]
}

variable "cleanup_policy" {
  type        = list(string)
  description = "Supported types - delete, compact. delete - deletes segments after the retention time. compact - retains the latest value"
  default     = ["delete", "delete", "delete"]
}

variable "retention_ms" {
  type        = list(number)
  description = "Time in ms for which the messages will be retained"
  default     = [86400000, 86400000, 86400000] # for standard plan retention ms should be in the range [1 hour, 30 days] and for enterprise plan it can be set to any value.
}

variable "retention_bytes" {
  type        = list(number)
  description = "Length of messages to be retained in bytes"
  default     = [10485760, 10485760, 10485760] # for standard plan retention bytes should be in the range [100 KiB, 1 GiB] and for enterprise plan it should be in the range [100 KiB, 2 TiB]
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
