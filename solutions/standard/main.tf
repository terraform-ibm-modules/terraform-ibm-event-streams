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
}

# KMS root key for event streams
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = (var.existing_kms_key_crn != null) ? 0 : 1 # no need to create any KMS resources if an existing key is passed
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
