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
# KMS encryption key
#######################################################################################################################

locals {
  create_new_kms_key          = var.existing_kms_key_crn == null ? 1 : 0 # no need to create any KMS resources if passing an existing key
  event_streams_key_name      = var.prefix != null ? "${var.prefix}-${var.event_streams_key_name}" : var.event_streams_key_name
  event_streams_key_ring_name = var.prefix != null ? "${var.prefix}-${var.event_streams_key_ring_name}" : var.event_streams_key_ring_name

  # tflint-ignore: terraform_unused_declarations
  validate_kms = var.existing_kms_instance_crn == null && var.existing_kms_key_crn == null ? tobool("Both 'existing_kms_instance_crn' and 'existing_kms_key_crn' input variables can not be null. Set 'existing_kms_instance_crn' to create a new KMS key or 'existing_kms_key_crn' to use an existing KMS key.") : true
}

module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = local.create_new_kms_key
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.19.2"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name     = local.event_streams_key_ring_name
      existing_key_ring = false
      keys = [
        {
          key_name                 = local.event_streams_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}

########################################################################################################################
# Parse KMS info from given CRNs
########################################################################################################################

module "kms_instance_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_instance_crn
}

module "kms_key_crn_parser" {
  count   = var.existing_kms_key_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_key_crn
}

#######################################################################################################################
# KMS IAM Authorization Policies
#   - only created if user passes a value for 'ibmcloud_kms_api_key' (used when KMS is in different account to Event Streams)
#   - if no value passed for 'ibmcloud_kms_api_key', the auth policy is created by the Event Streams module
#######################################################################################################################

# Lookup account ID
data "ibm_iam_account_settings" "iam_account_settings" {
}

locals {
  account_id                           = data.ibm_iam_account_settings.iam_account_settings.account_id
  create_cross_account_kms_auth_policy = !var.skip_event_streams_kms_auth_policy && var.ibmcloud_kms_api_key != null

  # If KMS encryption enabled, parse details from the existing key if being passed, otherwise get it from the key that the DA creates
  kms_account_id    = var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].account_id : module.kms_instance_crn_parser[0].account_id
  kms_service       = var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].service_name : module.kms_instance_crn_parser[0].service_name
  kms_instance_guid = var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].service_instance : module.kms_instance_crn_parser[0].service_instance
  kms_key_crn       = var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", local.event_streams_key_ring_name, local.event_streams_key_name)].crn
  kms_key_id        = var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].resource : module.kms[0].keys[format("%s.%s", local.event_streams_key_ring_name, local.event_streams_key_name)].key_id
  kms_region        = var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].region : module.kms_instance_crn_parser[0].region
}

# Create auth policy (scoped to exact KMS key)
resource "ibm_iam_authorization_policy" "kms_policy" {
  count                    = local.create_cross_account_kms_auth_policy ? 1 : 0
  provider                 = ibm.kms
  source_service_account   = local.account_id
  source_service_name      = "event_streams"
  source_resource_group_id = module.resource_group.resource_group_id
  roles                    = ["Reader"]
  description              = "Allow all Event Streams instances in the resource group ${module.resource_group.resource_group_id} in the account ${local.account_id} to read the ${local.kms_service} key ${local.kms_key_id} from the instance GUID ${local.kms_instance_guid}"
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
resource "time_sleep" "wait_for_authorization_policy" {
  count           = local.create_cross_account_kms_auth_policy ? 1 : 0
  depends_on      = [ibm_iam_authorization_policy.kms_policy]
  create_duration = "30s"
}

#######################################################################################################################
# Event Streams Instance
#######################################################################################################################
module "event_streams" {
  source                               = "../../modules/fscloud"
  resource_group_id                    = module.resource_group.resource_group_id
  es_name                              = (var.prefix != null && var.prefix != "") ? "${var.prefix}-${var.event_streams_name}" : var.event_streams_name
  kms_key_crn                          = local.kms_key_crn
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
  skip_kms_iam_authorization_policy    = var.skip_event_streams_kms_auth_policy
  skip_es_s2s_iam_authorization_policy = var.skip_event_streams_s2s_iam_auth_policy
}
