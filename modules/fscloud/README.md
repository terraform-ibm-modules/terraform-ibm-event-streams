# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Solution for IBM Cloud Framework for Financial Services](/solutions/standard/) for logic that uses this module. The profile assumes you are deploying into an account that complies with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable rules.

## Before you begin

Before you run the module, configure an authorization policy to allow the Event Streams service to access the key management service instance with the reader role. For more information, see [About KMS encryption](../../README.md#about-kms-encryption) in the main readme file.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.62.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_event_streams"></a> [event\_streams](#module\_event\_streams) | ../../ | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, list) List of CBR rules to create | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>  }))</pre> | `[]` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | Name of the event streams instance | `string` | n/a | yes |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of the Hyper Protect Crypto Service (HPCS) to use for disk encryption. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where event streams will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of resource group to use when creating the event stream instance | `string` | n/a | yes |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema object which contains schema id and format of the schema | <pre>list(object(<br>    {<br>      schema_id = string<br>      schema = object({<br>        type = string<br>        name = string<br>      })<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags associated with the Event Steams instance | `list(string)` | `[]` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | List of topics. For lite plan only one topic is allowed. | <pre>list(object(<br>    {<br>      name       = string<br>      partitions = number<br>      config     = object({})<br>    }<br>  ))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | Event Streams instance crn |
| <a name="output_guid"></a> [guid](#output\_guid) | Event Streams instance guid |
| <a name="output_id"></a> [id](#output\_id) | Event Streams instance crn |
| <a name="output_kafka_brokers_sasl"></a> [kafka\_brokers\_sasl](#output\_kafka\_brokers\_sasl) | (Array of Strings) Kafka brokers use for interacting with Kafka native API |
| <a name="output_kafka_http_url"></a> [kafka\_http\_url](#output\_kafka\_http\_url) | The API endpoint to interact with Event Streams REST API |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
