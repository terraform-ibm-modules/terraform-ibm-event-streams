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
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v4.1.0"
  key_protect_instance_name = "${var.prefix}-kp"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  key_map                   = { "es" = ["${var.prefix}-es"] }
  enable_metrics            = false
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
}
