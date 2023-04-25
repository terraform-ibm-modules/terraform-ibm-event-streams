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
# Events-streams-instance
##############################################################################

module "event_streams" {
  source               = "../../"
  resource_group_id    = module.resource_group.resource_group_id
  es_name              = var.prefix
  plan                 = var.plan
  tags                 = var.resource_tags
  service_endpoints    = var.service_endpoints
  private_ip_allowlist = var.private_ip_allowlist
  throughput           = var.throughput
  storage_size         = var.storage_size
  schemas              = var.schemas
}
