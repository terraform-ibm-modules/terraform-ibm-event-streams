# Event Streams Module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-event-streams?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module implements Event Streams with topics, partitions, throughput, storage size, cleanup policy, retention time, retention size, segment size and schema.

## Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
module "event_streams" {
  source  = "terraform-ibm-modules/event-streams/ibm"
  version = "latest" # Replace "latest" with a release version to lock into a specific release
  resource_group    = "event-streams-rg"
  plan                 = "standard"
  topics           = [
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
  schema_id            = [{
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
    },
    {
      schema_id = "my-es-schema_3"
      schema = {
        type = "string"
        name = "name_3"
      }
    }
  ]
}
```
<!--
Include the following 'Controls' section if the module implements NIST controls
Remove the 'section if the module does not implement controls
-->

<!-- GoldenEye core team only
## Compliance and security

This module implements the following NIST controls. For more information about how this module implements the controls in the following list, see [NIST controls](docs/controls.md).

| Profile | Category | ID       | Description |
|---------|----------|----------|-------------|
| NIST    | SC-7     | SC-7(3)  | Limit the number of external network connections to the information system. |

The 'Profile' and 'ID' columns are used by the IBM Cloud catalog to import
the controls into the catalog page.

In the example here, remove the SC-7 row and include a row for each control
that the module implements.

Include the control enhancement in the ID column ('SC-7(3)' in this example).

Identify how the module is complying with the controls. Summarize the
rationale or implementation in the 'Description' column.

For details about the controls, see the NIST Risk Management Framework page at
https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#/controls?version=4.0.
-->

## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **IBM Authorization Policy**
        - `Editor` platform access
        - `Manager` service access
    - **Event Streams** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Basic example](examples/basic)
- [ Complete example with topics and schema creation.](examples/complete)
- [ Financial Services Cloud profile example](examples/fscloud)
<!-- END EXAMPLES HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.54.0, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//cbr-rule-module | 1.3.2 |

### Resources

| Name | Type |
|------|------|
| [ibm_event_streams_schema.es_schema](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_schema) | resource |
| [ibm_event_streams_topic.es_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_topic) | resource |
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.es_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, list) List of CBR rules to create | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>  }))</pre> | `[]` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Creation timeout value of the Event Streams module. Use 3h when creating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage\_size | `string` | `"3h"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Deleting timeout value of the Event Streams module | `string` | `"15m"` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | The name to give the IBM Event Streams instance created by this module. | `string` | n/a | yes |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | The GUID of the Hyper Protect Crypto Services or Key Protect instance in which the key specified in var.kms\_key\_crn is coming from. Required only if var.kms\_encryption\_enabled is set to true, var.skip\_iam\_authorization\_policy is set to false, and you pass a value for var.kms\_key\_crn. | `string` | `null` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Set this to true to control the encryption keys used to encrypt the data that you store in IBM Cloud® Databases. If set to false, the data is encrypted by using randomly generated keys. For more info on Key Protect integration, see https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect. For more info on HPCS integration, see https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of a Key Management Services like Key Protect or Hyper Protect Crypto Services (HPCS) that you want to use for disk encryption. Only used if var.kms\_encryption\_enabled is set to true. | `string` | `null` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Plan for the event streams instance : lite, standard or enterprise-3nodes-2tb | `string` | `"standard"` | no |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where event streams will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the Event Streams instance will be created. | `string` | n/a | yes |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema object which contains schema id and format of the schema | <pre>list(object(<br>    {<br>      schema_id = string<br>      schema = object({<br>        type = string<br>        name = string<br>      })<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Specify whether you want to enable the public, private, or both service endpoints. Supported values are 'public', 'private', or 'public-and-private'. | `string` | `"public"` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Event Streams database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing\_kms\_instance\_guid variable. In addition, no policy is created if var.kms\_encryption\_enabled is set to false. | `bool` | `false` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | Storage size of the event streams in GB. For enterprise instance only. Options are: 2048, 4096, 6144, 8192, 10240, 12288,. Note: When throughput is 300, storage\_size starts from 4096, when throughput is 450, storage\_size starts from 6144. Storage capacity cannot be scaled down once instance is created. | `number` | `"2048"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags associated with the Event Steams instance | `list(string)` | `[]` | no |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | Throughput capacity in MB per second. For enterprise instance only. Options are: 150, 300, 450. | `number` | `"150"` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | List of topics. For lite plan only one topic is allowed. | <pre>list(object(<br>    {<br>      name       = string<br>      partitions = number<br>      config     = object({})<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | Updating timeout value of the Event Streams module. Use 1h when updating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage\_size. | `string` | `"1h"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | Event Streams crn |
| <a name="output_guid"></a> [guid](#output\_guid) | Event Streams guid |
| <a name="output_id"></a> [id](#output\_id) | Event Streams instance id |
| <a name="output_kafka_brokers_sasl"></a> [kafka\_brokers\_sasl](#output\_kafka\_brokers\_sasl) | (Array of Strings) Kafka brokers use for interacting with Kafka native API |
| <a name="output_kafka_http_url"></a> [kafka\_http\_url](#output\_kafka\_http\_url) | The API endpoint to interact with Event Streams REST API |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
