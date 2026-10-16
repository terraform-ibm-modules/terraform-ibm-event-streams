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
  topics            = local.create_vpe ? [] : local.topics
  metrics           = []
  quotas            = []

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

##############################################################################
# VPE to the Event Streams instance
##############################################################################

data "ibm_is_vpc" "vpc" {
  count = local.create_vpe ? 1 : 0
  name  = var.vpe_vpc_name
}

# The VPC data source does not return the subnet CIDR blocks, so look up each subnet
data "ibm_is_subnet" "subnet" {
  for_each   = local.create_vpe ? { for subnet in data.ibm_is_vpc.vpc[0].subnets : subnet.name => subnet.id } : {}
  identifier = each.value
}

resource "ibm_is_security_group" "vpe" {
  count          = local.create_vpe ? 1 : 0
  name           = "${var.prefix}-vpe-sg"
  vpc            = data.ibm_is_vpc.vpc[0].id
  resource_group = module.resource_group.resource_group_id
}

# Allow every subnet of the VPC (including the agent cluster workers) to reach the VPE
resource "ibm_is_security_group_rule" "vpe_inbound" {
  for_each  = data.ibm_is_subnet.subnet
  group     = ibm_is_security_group.vpe[0].id
  direction = "inbound"
  remote    = each.value.ipv4_cidr_block
}

module "vpe" {
  count              = local.create_vpe ? 1 : 0
  source             = "terraform-ibm-modules/vpe-gateway/ibm"
  version            = "5.3.5"
  region             = var.region
  prefix             = var.prefix
  vpc_name           = var.vpe_vpc_name
  vpc_id             = data.ibm_is_vpc.vpc[0].id
  resource_group_id  = module.resource_group.resource_group_id
  security_group_ids = [ibm_is_security_group.vpe[0].id]
  subnet_zone_list = [
    for subnet in data.ibm_is_subnet.subnet : {
      name = subnet.name
      id   = subnet.id
      zone = subnet.zone
      cidr = subnet.ipv4_cidr_block
    }
  ]
  cloud_service_by_crn = [
    {
      crn          = module.event_streams.crn
      service_name = "event-streams"
    }
  ]
  depends_on = [ibm_is_security_group_rule.vpe_inbound]
}

# Give the VPE time to be bound before using it, and time between the VPE and security group
# destruction on deletion.
resource "time_sleep" "wait_for_vpe" {
  count            = local.create_vpe ? 1 : 0
  depends_on       = [module.vpe]
  create_duration  = "120s"
  destroy_duration = "60s"
}

resource "ibm_event_streams_topic" "topic" {
  for_each             = local.create_vpe ? { for topic in local.topics : topic.name => topic } : {}
  resource_instance_id = module.event_streams.id
  name                 = each.value.name
  partitions           = each.value.partitions
  config               = each.value.config
  depends_on           = [time_sleep.wait_for_vpe]
}
