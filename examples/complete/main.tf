locals {
  validate_sm_region_cnd = var.existing_sm_instance_guid != null && var.existing_sm_instance_region == null
  validate_sm_region_msg = "existing_sm_instance_region must also be set when value given for existing_sm_instance_guid."
  # tflint-ignore: terraform_unused_declarations
  validate_sm_region_chk = regex(
    "^${local.validate_sm_region_msg}$",
    (!local.validate_sm_region_cnd
      ? local.validate_sm_region_msg
  : ""))
}


##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}


##############################################################################
# Key Protect All Inclusive
##############################################################################


module "key_protect_all_inclusive" {
  providers = {
    restapi = restapi.kp
  }
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v3.1.2"
  key_protect_instance_name = "${var.prefix}-kp"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  key_map                   = { "es" = ["${var.prefix}-es"] }
  enable_metrics            = false
}

resource "ibm_iam_authorization_policy" "policy" {
  source_service_name         = "messagehub"
  source_resource_group_id    = module.resource_group.resource_group_id
  target_service_name         = "kms"
  target_resource_instance_id = module.key_protect_all_inclusive.key_protect_guid
  roles                       = ["Reader"]
}


##############################################################################
# Create Secrets Manager layer
##############################################################################

# Create Secrets Manager Instance
resource "ibm_resource_instance" "secrets_manager" {
  count             = var.existing_sm_instance_guid == null ? 1 : 0
  name              = "${var.prefix}-sm" #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static value
  service           = "secrets-manager"
  service_endpoints = "public-and-private"
  plan              = var.sm_service_plan
  location          = var.region
  resource_group_id = module.resource_group.resource_group_id

  timeouts {
    create = "30m" # Extending provisioning time to 30 minutes
  }
}

##############################################################################
# Events-streams-instance
##############################################################################

module "event_streams" {
  source               = "../../"
  resource_group_id    = module.resource_group.resource_group_id
  es_name              = "${var.prefix}-es"
  plan                 = var.plan
  kms_key_crn          = module.key_protect_all_inclusive.keys["es.${var.prefix}-es"].crn
  tags                 = var.resource_tags
  service_endpoints    = var.service_endpoints
  private_ip_allowlist = var.private_ip_allowlist
  throughput           = var.throughput
  storage_size         = var.storage_size
  topic_names          = var.topic_names
  partitions           = var.partitions
  cleanup_policy       = var.cleanup_policy
  retention_ms         = var.retention_ms
  retention_bytes      = var.retention_bytes
  segment_bytes        = var.segment_bytes
  schemas              = var.schemas
}

##############################################################################
# Service Credentials
##############################################################################

resource "ibm_resource_key" "service_credentials" {
  count                = length(var.service_credentials)
  name                 = var.service_credentials[count.index]
  resource_instance_id = module.event_streams.id
  tags                 = var.resource_tags
}
