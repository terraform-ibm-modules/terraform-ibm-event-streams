#######################################################################################
# This file creates an event streams resource instance, topics, partitions and schema.
#######################################################################################

locals {
  parsed_kms_key_crn = var.kms_key_crn != null ? split(":", var.kms_key_crn) : []
  kms_service        = length(local.parsed_kms_key_crn) > 0 ? local.parsed_kms_key_crn[4] : null
  kms_scope          = length(local.parsed_kms_key_crn) > 0 ? local.parsed_kms_key_crn[6] : null
  kms_account_id     = length(local.parsed_kms_key_crn) > 0 ? split("/", local.kms_scope)[1] : null
  kms_key_id         = length(local.parsed_kms_key_crn) > 0 ? local.parsed_kms_key_crn[9] : null
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
      iam_token_only    = var.iam_token_only
      metrics           = var.metrics
      kms_key_crn       = var.kms_key_crn
      mirroring         = var.mirroring
    }
    ) : jsonencode(
    {
      service-endpoints = var.service_endpoints
      throughput        = tostring(var.throughput)
      storage_size      = tostring(var.storage_size)
      iam_token_only    = var.iam_token_only
    }
  )
}

########################################################################################################################
# Parse KMS info from given CRNs
########################################################################################################################

module "kms_key_crn_parser" {
  count   = var.kms_encryption_enabled == true ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.7"
  crn     = var.kms_key_crn
}

locals {
  kms_instance_guid = var.kms_key_crn != null ? module.kms_key_crn_parser[0].service_instance : null
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
  count                    = var.kms_encryption_enabled == false || var.skip_kms_iam_authorization_policy ? 0 : 1
  source_service_name      = "messagehub"
  source_resource_group_id = var.resource_group_id
  roles                    = ["Reader"]
  description              = "Allow the Event Streams instances in the resource group ${var.resource_group_id} to read the ${local.kms_service} key ${local.kms_key_id} from the instance ${local.kms_instance_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.kms_instance_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
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
  version = "1.3.7"
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
  version          = "1.35.6"
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
  for_each             = { for key in var.resource_keys : key.name => key }
  name                 = each.value.key_name == null ? each.key : each.value.key_name
  role                 = each.value.role
  resource_instance_id = ibm_resource_instance.es_instance.id
  parameters = {
    service-endpoints = each.value.endpoint
  }
}

resource "ibm_event_streams_mirroring_config" "es_mirroring_config" {
  count                    = var.mirroring != null ? 1 : 0
  resource_instance_id     = ibm_resource_instance.es_instance.id
  mirroring_topic_patterns = var.mirroring_topic_patterns
}
