##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Events-streams-instance
##############################################################################

module "event_streams" {
  source            = "../../"
  resource_group_id = module.resource_group.resource_group_id
  es_name           = "${var.prefix}-es"
  schemas           = [{
    schema_id = "my-es-schema_1"
    schema = {
      type = "string"
      name = "name_1"

    }
  },
  {
    schema_id = "my-es-schema_2"
    schema = {
      type = "string"
      name = "name_2"
    }
  }]
  tags              = var.resource_tags
  access_tags       = var.access_tags
  topics            = [
    {
      name       = "topic-1"
      partitions = 1
      config = {
        "cleanup.policy"  = "delete"
        "retention.ms"    = "86400000"
        "retention.bytes" = "10485760"
        "segment.bytes"   = "10485760"
      }
    },
    {
      name       = "topic-2"
      partitions = 1
      config = {
        "cleanup.policy"  = "compact,delete"
        "retention.ms"    = "86400000"
        "retention.bytes" = "1073741824"
        "segment.bytes"   = "536870912"
      }
    }
  ]
  metrics           = []
  quotas            = []
  service_credential_names = {
    "es_writer" : "Writer",
    "es_reader" : "Reader",
    "es_manager" : "Manager"
  }
}
