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
  source                   = "../../"
  resource_group_id        = module.resource_group.resource_group_id
  es_name                  = var.prefix != null ? "${var.prefix}-${var.es_name}" : var.es_name
  plan                     = var.plan
  region                   = var.region
  topics                   = var.topics
  tags                     = var.resource_tags
  service_credential_names = var.service_credential_names
}
