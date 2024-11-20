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
# Events-streams-source-instance
##############################################################################
module "source_event_streams" {
  source            = "../../"
  resource_group_id = module.resource_group.resource_group_id
  es_name           = "${var.prefix}-es"
  tags              = var.resource_tags
  plan              = "enterprise-3nodes-2tb"
}

##############################################################################
# Events-streams-mirroring-instance
##############################################################################

module "event_streams_mirror" {
  depends_on               = [module.source_event_streams]
  source                   = "../../"
  resource_group_id        = module.resource_group.resource_group_id
  es_name                  = "${var.prefix}-mirror"
  tags                     = var.resource_tags
  plan                     = "enterprise-3nodes-2tb"
  mirroring_enabled        = true
  mirroring_topic_patterns = ["topic-1", "topic-2"]
  mirroring = {
    source_crn   = module.source_event_streams.crn
    source_alias = "source-alias"
    target_alias = "target-alias"
  }
}
