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
  source            = "../../modules/fscloud"
  resource_group_id = module.resource_group.resource_group_id
  es_name           = var.prefix != null ? "${var.prefix}-${var.es_name}" : var.es_name
  region            = var.region
  kms_key_crn       = local.kms_key_crn
  schemas           = var.schemas
  topics            = var.topics
  tags              = var.resource_tags
  cbr_rules         = var.cbr_rules
}

#######################################################################################################################
# KMS Key
#######################################################################################################################

locals {
  parsed_existing_kms_instance_crn = var.existing_kms_instance_crn != null ? split(":", var.existing_kms_instance_crn) : []
  kms_region                       = length(local.parsed_existing_kms_instance_crn) > 0 ? local.parsed_existing_kms_instance_crn[5] : null
  existing_kms_guid                = length(local.parsed_existing_kms_instance_crn) > 0 ? local.parsed_existing_kms_instance_crn[7] : null

  es_key_ring_name = var.prefix != null ? "${var.prefix}-${var.es_key_ring_name}" : var.es_key_ring_name
  es_key_name      = var.prefix != null ? "${var.prefix}-${var.es_key_name}" : var.es_key_name
  kms_key_crn      = var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", local.es_key_ring_name, local.es_key_name)].crn

  create_cross_account_auth_policy = (!var.skip_es_kms_auth_policy && var.ibmcloud_kms_api_key != null) ? 1 : 0
  kms_service = var.existing_kms_instance_crn != null ? (
    can(regex(".*kms.*", var.existing_kms_instance_crn)) ? "kms" : (
      can(regex(".*hs-crypto.*", var.existing_kms_instance_crn)) ? "hs-crypto" : null
    )
  ) : null
}

# Data source for retrieving cross account details
data "ibm_iam_account_settings" "iam_account_settings" {
  count = local.create_cross_account_auth_policy
}

resource "ibm_iam_authorization_policy" "kms_policy" {
  count                       = local.create_cross_account_auth_policy
  provider                    = ibm.kms
  source_service_account      = data.ibm_iam_account_settings.iam_account_settings[0].account_id
  source_service_name         = "messagehub"
  source_resource_group_id    = module.resource_group.resource_group_id
  target_service_name         = local.kms_service
  target_resource_instance_id = local.existing_kms_guid
  roles                       = ["Reader"]
  description                 = "Allow all Event Streams instances in the resource group ${module.resource_group.resource_group_id} to read from the ${local.kms_service} instance GUID ${local.existing_kms_guid}"
}

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.kms_policy]
  create_duration = "30s"
}

# KMS root key for event streams
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = (var.existing_kms_key_crn != null) ? 0 : 1 # no need to create any KMS resources if an existing key is passed
  depends_on                  = [ibm_iam_authorization_policy.kms_policy]
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.13.2"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_guid  = local.existing_kms_guid
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name         = local.es_key_ring_name
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = local.es_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}
