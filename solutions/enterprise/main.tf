#######################################################################################################################
# Resource Group
#######################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.use_existing_resource_group == false ? ((var.prefix != null && var.prefix != "") ? "${var.prefix}-${var.resource_group_name}" : var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

#######################################################################################################################
# Event Streams Instance
#######################################################################################################################
module "event_streams" {
  source                               = "../../modules/fscloud"
  resource_group_id                    = module.resource_group.resource_group_id
  es_name                              = (var.prefix != null && var.prefix != "") ? "${var.prefix}-${var.event_streams_name}" : var.event_streams_name
  kms_key_crn                          = var.existing_kms_key_crn
  existing_kms_instance_guid           = var.existing_kms_instance_guid
  schemas                              = var.schemas
  region                               = var.region
  topics                               = var.topics
  tags                                 = var.resource_tags
  access_tags                          = var.access_tags
  service_credential_names             = var.service_credential_names
  metrics                              = var.metrics
  quotas                               = var.quotas
  mirroring_topic_patterns             = var.mirroring_topic_patterns
  mirroring                            = var.mirroring
  cbr_rules                            = var.cbr_rules
  schema_global_rule                   = var.schema_global_rule
  skip_kms_iam_authorization_policy    = var.skip_kms_iam_authorization_policy
  skip_es_s2s_iam_authorization_policy = var.skip_event_streams_s2s_iam_authorization_policy
}
