##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

# #############################################################################
# Events-streams-instance
# #############################################################################

module "event_streams" {
  source                     = "../../profiles/fscloud"
  resource_group_id          = module.resource_group.resource_group_id
  es_name                    = "${var.prefix}-es"
  plan                       = var.plan
  kms_key_crn                = var.kms_key_crn
  existing_kms_instance_guid = var.existing_kms_instance_guid
  schemas                    = var.schemas
  tags                       = var.resource_tags
  topics                     = var.topics
}
