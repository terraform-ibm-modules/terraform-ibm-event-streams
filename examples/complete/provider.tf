provider "ibm" {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  private_endpoint_type = var.plan == "enterprise-gen2" ? "vpe" : null
}
