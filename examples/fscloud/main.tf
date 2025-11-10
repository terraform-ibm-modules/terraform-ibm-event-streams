##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.4.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################
resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# Create CBR Zone
##############################################################################
module "cbr_vpc_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.33.8"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

module "cbr_zone_schematics" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.33.8"
  name             = "${var.prefix}-schematics-zone"
  zone_description = "CBR Network zone containing Schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef",
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
}


# #############################################################################
# Events-streams-instance
# #############################################################################

module "event_streams" {
  source                   = "../../modules/fscloud"
  resource_group_id        = module.resource_group.resource_group_id
  es_name                  = "${var.prefix}-es-fs"
  kms_key_crn              = var.kms_key_crn
  schemas                  = var.schemas
  tags                     = var.resource_tags
  topics                   = var.topics
  create_timeout           = "6h"
  metrics                  = ["topic", "partition", "consumers"]
  mirroring_topic_patterns = ["topic-1", "topic-2"]
  mirroring = {
    source_crn   = var.event_streams_source_crn # Required for mirroring
    source_alias = "source-alias"               # Required for mirroring
    target_alias = "target-alias"               # Required for mirroring

    # 'options' are optional. Valid values for 'type' are 'rename', 'none', or 'use_alias'.
    # If 'type' is set to 'rename', then 'rename' object must include the following fields: 'add_prefix', 'add_suffix', 'remove_prefix', and 'remove_suffix'.
    options = {
      topic_name_transform = {
        type = "rename"
        rename = {
          add_prefix    = "add_prefix"
          add_suffix    = "add_suffix"
          remove_prefix = "remove_prefix"
          remove_suffix = "remove_suffix"
        }
      }
      group_id_transform = {
        type = "rename"
        rename = {
          add_prefix    = "add_prefix"
          add_suffix    = "add_suffix"
          remove_prefix = "remove_prefix"
          remove_suffix = "remove_suffix"
        }
      }
    }
    # 'schemas' is optional. Valid values are 'proxied', 'read-only', and 'inactive' (default).
    schemas = "inactive"
  }
  quotas = [
    {
      "entity"             = "iam-ServiceId-00000000-0000-0000-0000-000000000000",
      "producer_byte_rate" = 100000,
      "consumer_byte_rate" = 200000
    }
  ]
  schema_global_rule = "FORWARD"

  resource_keys = [
    {
      name = "${var.prefix}-writer-key"
      role = "Writer"
    },
    {
      name = "${var.prefix}-reader-key"
      role = "Reader"
    },
    {
      name = "${var.prefix}-manager-key"
      role = "Manager"
    }
  ]

  cbr_rules = [
    {
      description      = "${var.prefix}-event streams access from vpc and schematics"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_vpc_zone.zone_id
        }]
        }, {
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone_schematics.zone_id
        }]
      }]
    }
  ]
}
