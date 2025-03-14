module "event_streams" {
  source                               = "../../"
  resource_group_id                    = var.resource_group_id
  es_name                              = var.es_name
  plan                                 = "enterprise-3nodes-2tb"
  region                               = var.region
  kms_key_crn                          = var.kms_key_crn
  skip_kms_iam_authorization_policy    = var.skip_kms_iam_authorization_policy
  skip_es_s2s_iam_authorization_policy = var.skip_es_s2s_iam_authorization_policy
  schemas                              = var.schemas
  schema_global_rule                   = var.schema_global_rule
  tags                                 = var.tags
  access_tags                          = var.access_tags
  topics                               = var.topics
  service_endpoints                    = "private"
  cbr_rules                            = var.cbr_rules
  service_credential_names             = var.service_credential_names
  metrics                              = var.metrics
  quotas                               = var.quotas
  kms_encryption_enabled               = true
  mirroring_topic_patterns             = var.mirroring_topic_patterns
  mirroring                            = var.mirroring
  iam_token_only                       = var.iam_token_only
  create_timeout                       = var.create_timeout
  update_timeout                       = var.update_timeout
  delete_timeout                       = var.delete_timeout
}
