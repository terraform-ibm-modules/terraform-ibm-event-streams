variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key with access to create a root key and key ring in the key management service instance. If the KMS instance is in a different account, specify a key from that account. If not specified, the ibmcloud_api_key variable is used."
  sensitive   = true
  default     = null
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
}

variable "es_name" {
  description = "The name of the Event Streams instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  type        = string
}

variable "region" {
  type        = string
  description = "The region where the Event Streams are created."
  default     = "us-south"
}

variable "resource_tags" {
  type        = list(string)
  description = "The list of tags associated with the Event Steams instance."
  default     = []
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
  description = "The list of schema objects. Include the `schema_id` and the `type` and `name` of the schema in the `schema` object."
  default     = []
}

variable "topics" {
  type = list(object(
    {
      name       = string
      partitions = number
      config     = object({})
    }
  ))
  description = "The list of topics to apply to resources. Only one topic is allowed for Lite plan instances."
  default     = []
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
  }))
  description = "The list of context-based restriction rules to create."
  default     = []
  # Validation happens in the rule module
}

########################################################################################################################
# KMS variables
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = "crn:v1:bluemix:public:kms:us-south:a/abac0df06b644a9cabc6e44f55b3880e:d4559998-17ab-4ab8-ba9e-a0c9d2c4ef23::"
  description = "The CRN of the key management service (KMS). If you are not using an existing KMS instance, you must specify this CRN. To support cross account functionality you must also provide a value for `ibmcloud_kms_api_key`."
}

variable "existing_kms_key_crn" {
  type        = string
  default     = null
  description = "Optional. The CRN of an existing root key in key management service (KMS) to encrypt the payload data in event streams. To create a key ring and key, pass a value for the `existing_kms_instance_crn` input variable. To support cross account functionality you must also provide a value for `ibmcloud_kms_api_key`."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to use to communicate with the key management service (KMS). Specify one of the following values for the endpoint type: `public` or `private` (default). To support cross account functionality you must also provide a value for `ibmcloud_kms_api_key`."
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "Valid values for the `kms_endpoint_type_value` are `public` or `private`. "
  }
}

variable "es_key_ring_name" {
  type        = string
  default     = "es-key-ring"
  description = "The name of the key ring to create for the Event Streams instance. If an existing key is used, this variable is not required. If the prefix input variable is passed, the name of the key ring is prefixed to the value in the `prefix-value` format."
}

variable "es_key_name" {
  type        = string
  default     = "es-cos-key"
  description = "The name of the key to create for the Event Streams instance. If an existing key is used, this variable is not required. If the prefix input variable is passed, the name of the key is prefixed to the value in the `prefix-value` format."
}
