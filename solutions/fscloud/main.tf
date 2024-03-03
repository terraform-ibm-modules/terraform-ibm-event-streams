module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

module "event_streams" {
  source            = "../../modules/fscloud"
  resource_group_id = module.resource_group.resource_group_id
  es_name           = var.es_name
  kms_key_crn       = var.kms_key_crn
  schemas           = var.schemas
  topics            = var.topics
  tags              = var.resource_tags
  cbr_rules         = var.cbr_rules
}
