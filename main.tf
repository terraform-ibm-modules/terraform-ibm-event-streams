#######################################################################################
# This file creates an event streams resource instance, topics, partitions and schema.
#######################################################################################

locals {
  kp_backup_crn = var.backup_encryption_key_crn != null ? var.backup_encryption_key_crn : var.kms_key_crn
  # tflint-ignore: terraform_unused_declarations
  validate_es_inputs_lite_standard_and_enterprise = ((length(var.topic_names) == length(var.partitions)) && (length(var.topic_names) == length(var.cleanup_policy)) && (length(var.topic_names) == length(var.retention_ms)) && (length(var.topic_names) == length(var.retention_bytes)) && (length(var.topic_names) == length(var.segment_bytes))) ? true : tobool("The number of topic_name, partitions, cleanup_policy, retention_ms, retention_bytes and segment bytes should be of same length.")
  # tflint-ignore: terraform_unused_declarations
  validate_es_inputs_schema_enterprise = ((var.plan == "lite") || (var.plan == "standard") || (var.plan == "enterprise-3nodes-2tb" && (length(var.topic_names) == length(var.schemas)))) ? true : tobool("The number of topic_name, schemas, partitions, cleanup_policy, retention_ms, retention_bytes and segment bytes should be of same length.")
  # tflint-ignore: terraform_unused_declarations
  validate_throughput_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.throughput != 150) ? tobool("Throughput value cannot be changed in lite and standard plan. Default value is 150.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_storage_size_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.storage_size != 2048) ? tobool("Storage size value cannot be changed in lite and standard plan. Default value is 2048.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_service_end_points_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.service_endpoints != "public") ? tobool("Service endpoint cannot be changed in lite and standard plan. Default is public.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_private_ip_allowlist_lite_standard = ((var.plan == "lite" || var.plan == "standard") && var.private_ip_allowlist != null) ? tobool("Private ip allowlist cannot be changed in lite and standard plan.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cleanup_lite = [for cp0 in var.cleanup_policy : (var.plan == "lite" && (cp0 == "compact" || cp0 == "compact,delete")) ? tobool("In lite plan the only allowed cleanup policy is 'delete'") : true]
  # tflint-ignore: terraform_unused_declarations
  validate_number_of_topic_lite = (var.plan == "lite" && length(var.topic_names) > 1) ? tobool("Only one topic is allowed in lite plan") : true
  # tflint-ignore: terraform_unused_declarations
  validate_partition_lite_inputs = [for p1 in var.partitions : (var.plan == "lite" && p1 > 1 ? tobool("For lite plan partition can not exceed 1") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_partition_standard_inputs = [for p2 in var.partitions : (var.plan == "standard" && p2 > 100 ? tobool("For standard plan partition can not exceed 100") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_segment_bytes_lite_inputs = [for s0 in var.segment_bytes : (var.plan == "lite" && (s0 < 10485760 || s0 > 536870912) ? tobool("For lite plan the allowed value is [10 MiB, 500 MiB]") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_segment_bytes_standard_inputs = [for s1 in var.segment_bytes : (var.plan == "standard" && (s1 < 102400 || s1 > 536870912) ? tobool("For standard plan the allowed value is [100 KiB, 500 MiB]") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_segment_bytes_enterprise_inputs = [for s2 in var.segment_bytes : (var.plan == "enterprise-3nodes-2tb" && (s2 < 102400 || s2 > 2199023255552) ? tobool("For enterprise plan the allowed value is [100 KiB, 2 TiB]") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_retention_bytes_lite_inputs = [for r0 in var.retention_bytes : (var.plan == "lite" && (r0 < 10485760 || r0 > 104857600) ? tobool("For lite plan the allowed value is [10 MiB, 100 MiB]") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_retention_bytes_standard_inputs = [for r1 in var.retention_bytes : (var.plan == "standard" && (r1 < 102400 || r1 > 1074790400) ? tobool("For standard plan the allowed value is [100 KiB, 1 GiB]") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_retention_bytes_enterprise_inputs = [for r2 in var.retention_bytes : (var.plan == "enterprise-3nodes-2tb" && (r2 < 102400 || r2 > 2199023255552) ? tobool("For enterprise plan the allowed value is [100 KiB, 2 TiB]") : true)]
  # tflint-ignore: terraform_unused_declarations
  validate_retention_ms_lite = [for rm0 in var.retention_ms : (var.plan == "lite" && (rm0 < 3600000 || rm0 > 2592000000)) ? tobool("For lite plan allowed range for retention time is [1 hour, 30 days]") : true]
  # tflint-ignore: terraform_unused_declarations
  validate_retention_ms_standard = [for rm1 in var.retention_ms : (var.plan == "standard" && (rm1 < 3600000 || rm1 > 2592000000)) ? tobool("For standard plan allowed range for retention time is [1 hour, 30 days]") : true]
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

    service-endpoints         = var.service_endpoints
    private_ip_allowlist      = var.private_ip_allowlist
    throughput                = var.throughput
    storage_size              = var.storage_size # Storage capacity cannot be scaled down once instance is created.
    key_protect_key           = var.kms_key_crn
    backup_encryption_key_crn = local.kp_backup_crn
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
  count                = length(var.topic_names)
  resource_instance_id = ibm_resource_instance.es_instance.id
  name                 = var.topic_names[count.index]
  partitions           = var.partitions[count.index]
  config = {
    "cleanup.policy"  = var.cleanup_policy[count.index]
    "retention.ms"    = var.retention_ms[count.index]
    "retention.bytes" = var.retention_bytes[count.index]
    "segment.bytes"   = var.segment_bytes[count.index]
  }
}
