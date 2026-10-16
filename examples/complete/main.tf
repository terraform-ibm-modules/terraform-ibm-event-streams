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
# Topics
##############################################################################

locals {
  topics = [
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
  # Event Streams `enterprise-gen2` is only reachable through a VPE.
  create_vpe = var.vpe_vpc_name != null
  # Gen2 supports only 100 MB/s and 2000 GB (2 TB) in this example
  is_gen2      = var.plan == "enterprise-gen2"
  throughput   = local.is_gen2 ? 100 : 150
  storage_size = local.is_gen2 ? 2000 : 2048
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
  throughput        = local.throughput
  storage_size      = local.storage_size
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  # VPE to the instance. The `enterprise-gen2` plan is only reachable through a VPE.
  vpe_vpc_id             = local.create_vpe ? data.ibm_is_vpc.vpc[0].id : null
  vpe_subnet_ids         = local.create_vpe ? [data.ibm_is_subnet.vpe_subnet[0].id] : []
  vpe_security_group_ids = local.create_vpe ? [data.ibm_is_security_group.vpe[0].id] : []
  topics                 = local.topics
  metrics                = []
  quotas                 = []

  resource_keys = [
    {
      name     = "${var.prefix}-writer-key"
      role     = "Writer"
      endpoint = "private"
    },
    {
      name     = "${var.prefix}-reader-key"
      role     = "Reader"
      endpoint = "private"
    },
    {
      name     = "${var.prefix}-manager-key"
      role     = "Manager"
      endpoint = "private"
    }
  ]
}

##############################################################################
# Look up the IDs of the existing VPC, subnet and security group used by the VPE
##############################################################################

data "ibm_is_vpc" "vpc" {
  count = local.create_vpe ? 1 : 0
  name  = var.vpe_vpc_name
}

data "ibm_is_subnet" "vpe_subnet" {
  count = local.create_vpe ? 1 : 0
  name  = var.vpe_subnet_name
}

data "ibm_is_security_group" "vpe" {
  count = local.create_vpe ? 1 : 0
  name  = var.vpe_security_group_name
  vpc   = data.ibm_is_vpc.vpc[0].id
}
