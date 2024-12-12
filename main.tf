#######################################################################################
# This file creates an event streams resource instance, topics, partitions and schema.
#######################################################################################

locals {
  # Validation (approach based on https://github.com/hashicorp/terraform/issues/25609#issuecomment-1057614400)

  # tflint-ignore: terraform_unused_declarations
  validate_kms_plan = var.plan != "enterprise-3nodes-2tb" && var.kms_key_crn != null ? tobool("KMS encryption is only supported for enterprise plan.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_metrics = var.plan != "enterprise-3nodes-2tb" && length(var.metrics) > 0 ? tobool("Metrics are only supported for enterprise plan.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_quotas = var.plan != "enterprise-3nodes-2tb" && length(var.quotas) > 0 ? tobool("Quotas are only supported for enterprise plan.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_schema_global_rule = var.plan != "enterprise-3nodes-2tb" && var.schema_global_rule != null ? tobool("Schema global rule is only supported for enterprise plan.") : true

  # tflint-ignore: terraform_unused_declarations
  validate_kms_values = !var.kms_encryption_enabled && var.kms_key_crn != null ? tobool("When passing values for var.kms_key_crn, you must set var.kms_encryption_enabled to true. Otherwise unset them to use default encryption.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_kms_vars = var.kms_encryption_enabled && var.kms_key_crn == null ? tobool("When setting var.kms_encryption_enabled to true, a value must be passed for var.kms_key_crn and/or var.backup_encryption_key_crn.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_auth_policy = var.kms_encryption_enabled && var.skip_kms_iam_authorization_policy == false && var.existing_kms_instance_guid == null ? tobool("When var.skip_kms_iam_authorization_policy is set to false, and var.kms_encryption_enabled to true, a value must be passed for var.existing_kms_instance_guid in order to create the auth policy.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_throughput_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.throughput != 150) ? tobool("Throughput value cannot be changed in lite and standard plan. Default value is 150.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_storage_size_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.storage_size != 2048) ? tobool("Storage size value cannot be changed in lite and standard plan. Default value is 2048.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_service_end_points_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.service_endpoints != "public") ? tobool("Service endpoint cannot be changed in lite and standard plan. Default is public.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_mirroring_topics = var.mirroring == null && var.mirroring_topic_patterns != null ? tobool("When passing values for var.mirroring_topic_patterns, values must also be passed for var.mirroring.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_mirroring_config = var.mirroring != null && var.mirroring_topic_patterns == null ? tobool("When passing values for var.mirroring, values must also be passed for var.mirroring_topic_patterns.") : true

  # Determine what KMS service is being used for database encryption
  kms_service = var.kms_key_crn != null ? (
    can(regex(".*kms.*", var.kms_key_crn)) ? "kms" : (
      can(regex(".*hs-crypto.*", var.kms_key_crn)) ? "hs-crypto" : null
    )
  ) : null
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.kms_policy]

  create_duration = "30s"
}

resource "ibm_resource_instance" "es_instance" {
  depends_on        = [time_sleep.wait_for_kms_authorization_policy, time_sleep.wait_for_es_s2s_policy]
  name              = var.es_name
  service           = "messagehub"
  plan              = var.plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.tags
  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }

  parameters_json = var.plan != "enterprise-3nodes-2tb" ? null : (var.kms_key_crn != null || var.metrics != null || var.mirroring != null) ? jsonencode(
    {
      service-endpoints = var.service_endpoints
      throughput        = tostring(var.throughput)
      storage_size      = tostring(var.storage_size)
      metrics           = var.metrics
      kms_key_crn       = var.kms_key_crn
      mirroring         = var.mirroring
    }
    ) : jsonencode(
    {
      service-endpoints = var.service_endpoints
      throughput        = tostring(var.throughput)
      storage_size      = tostring(var.storage_size)
    }
  )
}

##############################################################################
# SCHEMA AND COMPATIBILITY RULE
##############################################################################

resource "ibm_event_streams_schema" "es_schema" {
  count                = length(var.schemas) * (var.plan == "enterprise-3nodes-2tb" ? 1 : 0)
  resource_instance_id = ibm_resource_instance.es_instance.id
  schema_id            = var.schemas[count.index].schema_id
  schema               = jsonencode(var.schemas[count.index].schema)
}

resource "ibm_event_streams_schema_global_rule" "es_globalrule" {
  count                = var.schema_global_rule != null ? 1 : 0
  resource_instance_id = ibm_resource_instance.es_instance.id
  config               = var.schema_global_rule
}

##############################################################################
# TOPIC
##############################################################################

resource "ibm_event_streams_topic" "es_topic" {
  for_each             = { for topic in var.topics : topic.name => topic }
  resource_instance_id = ibm_resource_instance.es_instance.id
  name                 = each.value.name
  partitions           = each.value.partitions
  config               = each.value.config
}

##############################################################################
# ACCESS TAGS - attaching existing access tags to the resource instance
##############################################################################
resource "ibm_resource_tag" "es_access_tag" {
  count       = length(var.access_tags) > 0 ? 1 : 0
  resource_id = ibm_resource_instance.es_instance.id
  tags        = var.access_tags
  tag_type    = "access"
}

##############################################################################
# QUOTAS - defining quotas for the resource instance
##############################################################################

resource "ibm_event_streams_quota" "eventstreams_quotas" {
  for_each             = { for quota in var.quotas : quota.entity => quota }
  resource_instance_id = ibm_resource_instance.es_instance.id
  entity               = each.value.entity
  producer_byte_rate   = each.value.producer_byte_rate
  consumer_byte_rate   = each.value.consumer_byte_rate
}

##############################################################################
# IAM Authorization Policies
##############################################################################

# Create IAM Authorization Policies to allow messagehub to access kms for the encryption key
resource "ibm_iam_authorization_policy" "kms_policy" {
  count                       = var.kms_encryption_enabled == false || var.skip_kms_iam_authorization_policy ? 0 : 1
  source_service_name         = "messagehub"
  source_resource_group_id    = var.resource_group_id
  target_service_name         = local.kms_service
  target_resource_instance_id = var.existing_kms_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow all Event Streams instances in the resource group ${var.resource_group_id} to read from the ${local.kms_service} instance GUID ${var.existing_kms_instance_guid}"
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_kms_authorization_policy" {
  count      = var.kms_encryption_enabled == false || var.skip_kms_iam_authorization_policy ? 0 : 1
  depends_on = [ibm_iam_authorization_policy.kms_policy]

  create_duration = "30s"
}

# Parse GUID from source ES instance
module "es_guid_crn_parser" {
  count   = var.mirroring != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.mirroring.source_crn
}

# Create s2s at service level for provisioning mirroring instance
resource "ibm_iam_authorization_policy" "es_s2s_policy" {
  count                       = var.mirroring == null || var.skip_es_s2s_iam_authorization_policy ? 0 : 1
  source_service_name         = "messagehub"
  source_resource_group_id    = var.resource_group_id
  target_service_name         = "messagehub"
  target_resource_instance_id = module.es_guid_crn_parser[0].service_instance
  roles                       = ["Reader"]
  description                 = "Allow all Event Streams instances in the resource group ${var.resource_group_id} to read from the source Event Streams instance ${module.es_guid_crn_parser[0].service_instance}."
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_es_s2s_policy" {
  count      = var.mirroring == null || var.skip_es_s2s_iam_authorization_policy ? 0 : 1
  depends_on = [ibm_iam_authorization_policy.es_s2s_policy]

  create_duration = "30s"
}

##############################################################################
# Context Based Restrictions
##############################################################################
module "cbr_rule" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.29.0"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = ibm_resource_instance.es_instance.guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "messagehub"
        operator = "stringEquals"
      }
    ]
  }]
}

resource "ibm_resource_key" "service_credentials" {
  for_each             = var.service_credential_names
  name                 = each.key
  role                 = each.value
  resource_instance_id = ibm_resource_instance.es_instance.id
}

locals {
  service_credentials_json = length(var.service_credential_names) > 0 ? {
    for service_credential in ibm_resource_key.service_credentials :
    service_credential["name"] => service_credential["credentials_json"]
  } : null

  service_credentials_object = length(var.service_credential_names) > 0 ? {
    credentials = {
      for service_credential in ibm_resource_key.service_credentials :
      service_credential["name"] => service_credential["credentials"]
    }
  } : null
}

resource "ibm_event_streams_mirroring_config" "es_mirroring_config" {
  count                    = var.mirroring != null ? 1 : 0
  resource_instance_id     = ibm_resource_instance.es_instance.id
  mirroring_topic_patterns = var.mirroring_topic_patterns
}
