variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "plan" {
  type        = string
  description = "Plan for the event stream instance. lite, standard or enterprise-3nodes-2tb"
  default     = "enterprise-3nodes-2tb"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "event_streams"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "List of tags associated with the Event Steams instance"
  default     = []
}

variable "existing_sm_instance_guid" {
  type        = string
  description = "Existing Secrets Manager GUID. If not provided an new instance will be provisioned"
  default     = null
}

variable "sm_service_plan" {
  type        = string
  description = "Service plan to be used to provision Secrets Manager"
  default     = "trial"
}

variable "service_credentials" {
  type        = list(string)
  description = "A list of service credentials that you want to create for the database"
  default     = ["event-streams_credential_microservices", "event-streams_credential_dev_1", "event-streams_credential_dev_2"]
}

variable "existing_sm_instance_region" {
  type        = string
  description = "Required if value is passed into var.existing_sm_instance_guid"
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
  default = [{
    schema_id = "my-es-schema_1"
    schema = {
      type = "string"
      name = "name_1"
    }
    },
    {
      schema_id = "my-es-schema_2"
      schema = {
        type = "string"
        name = "name_2"
      }
    },
    {
      schema_id = "my-es-schema_3"
      schema = {
        type = "string"
        name = "name_3"
      }
    }
  ]
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
  default     = "private"
}

variable "private_ip_allowlist" {
  type        = string
  description = "Range of IPs that have the access."
  default     = null
}
