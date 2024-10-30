module "event_streams" {
  source                     = "../../"
  resource_group_id          = var.resource_group_id
  es_name                    = var.es_name
  plan                       = "enterprise-3nodes-2tb"
  region                     = var.region
  kms_key_crn                = var.kms_key_crn
  existing_kms_instance_guid = var.existing_kms_instance_guid
  schemas                    = var.schemas
  tags                       = var.tags
  access_tags                = var.access_tags
  topics                     = var.topics
  service_endpoints          = "private"
  cbr_rules                  = var.cbr_rules
  service_credential_names   = var.service_credential_names
  kms_encryption_enabled     = true

}
