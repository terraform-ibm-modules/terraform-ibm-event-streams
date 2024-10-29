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

module "event_streams_mirror" {
  source            = "../../"
  resource_group_id = module.resource_group.resource_group_id
  es_name           = "${var.prefix}-mirror"
  tags              = var.resource_tags
  plan              = "enterprise-3nodes-2tb"
  mirroring_enabled = true
  mirroring_topic_list = ["topic-1", "topic-2"]
}
