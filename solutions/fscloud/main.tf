module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.resource_group == null ? "${var.es_name}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "event_streams" {
  source                        = "../../modules/fscloud"
  resource_group_id             = module.resource_group.resource_group_id
  es_name                       = var.es_name
  kms_key_crn                   = var.kms_key_crn
  existing_kms_instance_guid    = var.existing_kms_instance_guid
  schemas                       = var.schemas
  topics                        = var.topics
  tags                          = var.resource_tags
  cbr_rules                     = var.cbr_rules
  skip_iam_authorization_policy = var.skip_iam_authorization_policy
}
