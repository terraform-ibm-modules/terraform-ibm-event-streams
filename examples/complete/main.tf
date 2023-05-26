##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v4.2.0"
  key_protect_instance_name = "${var.prefix}-kp"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  key_map                   = { "es" = ["${var.prefix}-es"] }
  enable_metrics            = false
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

##############################################################################
# Create CBR Zone
##############################################################################
module "cbr_zone" {
  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-zone-module?ref=v1.2.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}


##############################################################################
# Events-streams-instance
##############################################################################

module "event_streams" {
  source                     = "../../"
  resource_group_id          = module.resource_group.resource_group_id
  es_name                    = "${var.prefix}-es"
  kms_encryption_enabled     = true
  kms_key_crn                = module.key_protect_all_inclusive.keys["es.${var.prefix}-es"].crn
  existing_kms_instance_guid = module.key_protect_all_inclusive.key_protect_guid
  schemas                    = var.schemas
  tags                       = var.resource_tags
  topics                     = var.topics
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
