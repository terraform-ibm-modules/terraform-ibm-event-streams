#######################################################################################
# This file creates an event streams resource instance, topics, partitions and schema.
#######################################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  kms_service = var.kms_key_crn != null ? (
    can(regex(".*kms.*", var.kms_key_crn)) ? "kms" : (
      can(regex(".*hs-crypto.*", var.kms_key_crn)) ? "hs-crypto" : null
    )
  ) : null
  # tflint-ignore: terraform_unused_declarations
  validate_skip_iam_authorization_policy = var.skip_iam_authorization_policy && local.kms_service == null ? tobool("var.kms_key_crn cannot be null if var.skip_iam_authorization_policy is true.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_throughput_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.throughput != 150) ? tobool("Throughput value cannot be changed in lite and standard plan. Default value is 150.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_storage_size_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.storage_size != 2048) ? tobool("Storage size value cannot be changed in lite and standard plan. Default value is 2048.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_service_end_points_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.service_endpoints != "public") ? tobool("Service endpoint cannot be changed in lite and standard plan. Default is public.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_hpcs_guid_input = var.skip_iam_authorization_policy == false && var.existing_kms_instance_guid == null ? tobool("A value must be passed for var.existing_kms_instance_guid when creating an instance, var.skip_iam_authorization_policy is false.") : true
}

resource "ibm_resource_instance" "es_instance" {
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

  parameters = {
    service-endpoints = var.service_endpoints
    throughput        = var.throughput
    storage_size      = var.storage_size
    key_protect_key   = var.kms_key_crn
  }
}

##############################################################################
# SCHEMA
##############################################################################

resource "ibm_event_streams_schema" "es_schema" {
  count                = length(var.schemas) * (var.plan == "enterprise-3nodes-2tb" ? 1 : 0)
  resource_instance_id = ibm_resource_instance.es_instance.id
  schema_id            = var.schemas[count.index].schema_id
  schema               = jsonencode(var.schemas[count.index].schema)
}

##############################################################################
# TOPIC
##############################################################################

resource "ibm_event_streams_topic" "es_topic" {
  count                = length(var.topics)
  resource_instance_id = ibm_resource_instance.es_instance.id
  name                 = var.topics[count.index].name
  partitions           = var.topics[count.index].partitions
  config               = var.topics[count.index].config
}


##############################################################################
# IAM Authorization Policy
##############################################################################

# Create IAM Authorization Policies to allow messagehub to access kms for the encryption key
resource "ibm_iam_authorization_policy" "kms_policy" {
  count                       = var.skip_iam_authorization_policy ? 0 : 1
  depends_on                  = [ibm_resource_instance.es_instance]
  source_service_name         = "messagehub"
  source_resource_group_id    = var.resource_group_id
  target_service_name         = local.kms_service
  target_resource_instance_id = var.existing_kms_instance_guid
  roles                       = ["Reader"]
}
