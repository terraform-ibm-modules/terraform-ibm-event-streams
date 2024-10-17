#######################################################################################################################
# Resource Group
#######################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.use_existing_resource_group == false ? (var.prefix != null ? "${var.prefix}-${var.resource_group_name}" : var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

#######################################################################################################################
# Event Streams Instance
#######################################################################################################################
module "event_streams" {
  source                     = "../../modules/fscloud"
  resource_group_id          = module.resource_group.resource_group_id
  es_name                    = var.prefix != null ? "${var.prefix}-${var.es_name}" : var.es_name
  kms_key_crn                = var.kms_key_crn
  existing_kms_instance_guid = var.existing_kms_instance_guid
  schemas                    = var.schemas
  region                     = var.region
  topics                     = var.topics
  tags                       = var.resource_tags
}
