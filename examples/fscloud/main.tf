##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.1.6"
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
module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.29.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}


# #############################################################################
# Events-streams-instance
# #############################################################################

module "event_streams" {
  source                     = "../../modules/fscloud"
  resource_group_id          = module.resource_group.resource_group_id
  es_name                    = "${var.prefix}-es-fs"
  kms_key_crn                = var.kms_key_crn
  schemas                    = var.schemas
  tags                       = var.resource_tags
  topics                     = var.topics
  existing_kms_instance_guid = var.existing_kms_instance_guid
  metrics                    = ["topic", "partition", "consumers"]
  mirroring_enabled          = var.mirroring_enabled
  mirroring_topic_patterns   = var.mirroring_topic_patterns
  mirroring                  = var.mirroring
  quotas = [
    {
      "entity"             = "iam-ServiceId-00000000-0000-0000-0000-000000000000",
      "producer_byte_rate" = 100000,
      "consumer_byte_rate" = 200000
    }
  ]
  schema_global_rule = "FORWARD"
  service_credential_names = {
    "es_writer" : "Writer",
    "es_reader" : "Reader",
    "es_manager" : "Manager"
  }
  cbr_rules = [
    {
      description      = "${var.prefix}-event stream access only from vpc"
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
            value = module.cbr_zone.zone_id
        }]
      }]
    }
  ]
}
