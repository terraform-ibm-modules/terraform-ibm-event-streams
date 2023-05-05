<!-- BEGIN MODULE HOOK -->

<!-- Update the title to match the module name and add a description -->
# Event Streams Module
<!-- UPDATE BADGES:
1. Make sure that the badge link for the current status of the module is correct. For the status options, see https://github.com/terraform-ibm-modules/documentation/blob/main/status.md.
2. Update the "Build Status" badge to point to the travis pipeline for the module. Replace "module-template" in two places.
3. Update the "latest release" badge to point to the new module. Replace "module-template" in two places.
-->

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cos?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/releases/latest)
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
  # replace "main" with a GIT release version to lock into a specific release
  source               = "git::https://github.com/terraform-ibm-modules/terraform-ibm-event-streams?ref=main"
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


## Examples

- [ Complete example with key protect and secret manager](examples/complete)
- [ Default Example](examples/default)
<!-- END EXAMPLES HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_event_streams_schema.es_schema](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_schema) | resource |
| [ibm_event_streams_topic.es_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_topic) | resource |
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.es_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_encryption_key_crn"></a> [backup\_encryption\_key\_crn](#input\_backup\_encryption\_key\_crn) | (Optional) The CRN of a Key Protect Key to use for encrypting backups. If left null, the value passed for the 'kms\_key\_crn' variable will be used. Take note that Hyper Protect Crypto Services for IBM Cloud® Databases backups is not currently supported. | `string` | `null` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Creation timeout value of the Event Streams module. Use 3h when creating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage\_size | `string` | `"3h"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Deleting timeout value of the Event Streams module | `string` | `"15m"` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | The name to give the IBM Event Streams instance created by this module. | `string` | n/a | yes |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | (Optional) The GUID of the Hyper Protect or Key Protect instance in which the key specified in var.kms\_key\_crn is coming from. Only required if skip\_iam\_authorization\_policy is false | `string` | `null` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | (Optional) The root key CRN of a Key Management Service like Key Protect or Hyper Protect Crypto Service (HPCS) that you want to use for disk encryption. If null, database is encrypted by using randomly generated keys. See https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok for current list of supported regions for BYOK | `string` | `null` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Plan for the event streams instance : lite, standard or enterprise-3nodes-2tb | `string` | `"standard"` | no |
| <a name="input_private_ip_allowlist"></a> [private\_ip\_allowlist](#input\_private\_ip\_allowlist) | Range of IPs that have the access. For enterprise instance only. Specify 1 or more IP range in CIDR format. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where event streams will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of resource group to use when creating the event stream instance | `string` | n/a | yes |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema object which contains schema id and format of the schema | <pre>list(object(<br>    {<br>      schema_id = string<br>      schema = object({<br>        type = string<br>        name = string<br>      })<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of service endpoint(public,private or public-and-private) to be used for connection. | `string` | `"private"` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether or not you want to skip applying an authorization policy to your kms instance. | `bool` | `false` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | Storage size of the event streams in GB. For enterprise instance only. Options are: 2048, 4096, 6144, 8192, 10240, 12288, and the default is 2048. Note: When throughput is 300, storage\_size starts from 4096, when throughput is 450, storage\_size starts from 6144. | `number` | `"2048"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags associated with the Event Steams instance | `list(string)` | `[]` | no |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | Throughput capacity in MB per second. for enterprise instance only. Options are: 150, 300, 450. Default is 150. | `number` | `"150"` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | List of topics. For lite plan only one topic is allowed. | <pre>list(object(<br>    {<br>      name       = string<br>      partitions = number<br>      config     = object({})<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | Updating timeout value of the Event Streams module. Use 1h when updating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage\_size. | `string` | `"1h"` | no |

## Outputs

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
