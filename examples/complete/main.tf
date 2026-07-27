##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Events-streams-instance
##############################################################################

module "event_streams" {
  source            = "../../"
  resource_group_id = module.resource_group.resource_group_id
  es_name           = "${var.prefix}-es"
  plan              = var.plan
  region            = var.region
  service_endpoints = var.service_endpoints
  throughput        = var.throughput
  storage_size      = var.storage_size
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  # Topics are not supported on enterprise-gen2 (provider bug: createSaramaAdminClient
  topics = var.plan == "enterprise-gen2" ? [] : [
    {
      name       = "topic-1"
      partitions = 1
      config = {
        "cleanup.policy"  = "delete"
        "retention.ms"    = "86400000"
        "retention.bytes" = "10485760"
        "segment.bytes"   = "10485760"
      }
    },
    {
      name       = "topic-2"
      partitions = 1
      config = {
        "cleanup.policy"  = "compact,delete"
        "retention.ms"    = "86400000"
        "retention.bytes" = "1073741824"
        "segment.bytes"   = "536870912"
      }
    }
  ]
  metrics = []
  quotas  = []

  resource_keys = [
    {
      name     = "${var.prefix}-writer-key"
      role     = "Writer"
      endpoint = var.service_endpoints == "private" ? "private" : "public"
    },
    {
      name     = "${var.prefix}-reader-key"
      role     = "Reader"
      endpoint = var.service_endpoints == "private" ? "private" : "public"
    },
    {
      name     = "${var.prefix}-manager-key"
      role     = "Manager"
      endpoint = var.service_endpoints == "private" ? "private" : "public"
    }
  ]
}
