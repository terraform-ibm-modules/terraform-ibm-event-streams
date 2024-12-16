# Event Streams on IBM Cloud

This architecture creates a Financial Services compliant instance of IBM Event Streams for IBM Cloud.

The solution provisions the following resources:

- A resource group, if one is not passed in.
- An Event Streams instance using `enterprise` plan.
- An IAM authorization between all Event Stream instances in the given resource group and the Hyper Protect Crypto Services instance that is passed in.
- An Event Streams instance that is encrypted with the Hyper Protect Crypto Services root key that is passed in.
- A sample virtual private cloud (VPC).
- A context-based restriction (CBR) rule to only allow Event Streams to be accessible from within the VPC.
- Topics to apply to resources.
- Schemas to apply to resources.

![da-enterprise](../../reference-architecture/da-enterprise.svg)

**Important:** Because this solution contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments, do not call this solution from one or more other modules. For more information about how resources are associated with provider configurations with multiple modules, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
