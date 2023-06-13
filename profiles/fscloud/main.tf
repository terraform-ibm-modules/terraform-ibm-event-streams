module "event_streams" {
  source                        = "../../"
  resource_group_id             = var.resource_group_id
  es_name                       = var.es_name
  plan                          = "enterprise-3nodes-2tb"
  kms_encryption_enabled        = true
  skip_iam_authorization_policy = var.skip_iam_authorization_policy
  kms_key_crn                   = var.kms_key_crn
  existing_kms_instance_guid    = var.existing_kms_instance_guid
  schemas                       = var.schemas
  tags                          = var.tags
  topics                        = var.topics
  service_endpoints             = "private"
  cbr_rules                     = var.cbr_rules
}
