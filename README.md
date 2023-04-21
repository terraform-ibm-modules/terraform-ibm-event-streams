<!-- BEGIN MODULE HOOK -->

<!-- Update the title to match the module name and add a description -->
# Event Streams Module
<!-- UPDATE BADGES:
1. Make sure that the badge link for the current status of the module is correct. For the status options, see https://github.com/terraform-ibm-modules/documentation/blob/master/status.md.
2. Update the "Build Status" badge to point to the travis pipeline for the module. Replace "module-template" in two places.
3. Update the "latest release" badge to point to the new module. Replace "module-template" in two places.
-->

[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-cos/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/actions/workflows/ci.yml)
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
  # replace "master" with a GIT release version to lock into a specific release
  source               = "git::https://github.com/terraform-ibm-modules/terraform-ibm-event-streams?ref=main"
  resource_group_id    = module.resource_group.resource_group_id
  plan                 = var.plan
  topic_name           = var.topic_name
  schema_id            = var.schema_id
  schema               = var.schema
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
    - **Event Streams** service
        - `Editor` role access


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
| [ibm_resource_instance.es_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_encryption_key_crn"></a> [backup\_encryption\_key\_crn](#input\_backup\_encryption\_key\_crn) | (Optional) The CRN of a key protect key, that you want to use for encrypting disk that holds deployment backups. If null, will use 'key\_protect\_key\_crn' as encryption key. If 'key\_protect\_key\_crn' is also null, database is encrypted by using randomly generated keys. | `string` | `null` | no |
| <a name="input_cleanup_policy"></a> [cleanup\_policy](#input\_cleanup\_policy) | Supported types - delete, compact. delete - deletes segments after the retention time. compact - retains the latest value | `list(string)` | `null` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Creation timeout value of the Event Streams module. | `string` | `"3h"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Deleting timeout value of the Event Streams module | `string` | `"15m"` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | Name of the resource instance | `string` | n/a | yes |
| <a name="input_key_protect_key_crn"></a> [key\_protect\_key\_crn](#input\_key\_protect\_key\_crn) | (Optional) CRN of the existing key protect to be used | `string` | `null` | no |
| <a name="input_partitions"></a> [partitions](#input\_partitions) | The number of partitions in which the topics are to be divided | `list(number)` | <pre>[<br>  1,<br>  1,<br>  1<br>]</pre> | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Plan for the event streams instance : lite, standard or enterprise-3nodes-2tb | `string` | `null` | no |
| <a name="input_private_ip_allowlist"></a> [private\_ip\_allowlist](#input\_private\_ip\_allowlist) | Range of IPs that have the access. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where event streams will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of resource group to use when creating the event stream instance | `string` | n/a | yes |
| <a name="input_retention_bytes"></a> [retention\_bytes](#input\_retention\_bytes) | Length of messages to be retained in bytes | `list(number)` | `null` | no |
| <a name="input_retention_ms"></a> [retention\_ms](#input\_retention\_ms) | Time in ms for which the messages will be retained | `list(number)` | `null` | no |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema object which contains schema id and format of the schema | <pre>list(object(<br>    {<br>      schema_id = string<br>      schema = object({<br>        type = string<br>        name = string<br>      })<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_segment_bytes"></a> [segment\_bytes](#input\_segment\_bytes) | The maximum size of a partition in bytes | `list(number)` | `null` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of service endpoint(public,private or public-and-private) to be used for connection. | `string` | `null` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | Storage size of the event streams in GB. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags associated with the Event Steams instance | `list(string)` | `[]` | no |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | Throughput capacity in MB per second. | `number` | `"150"` | no |
| <a name="input_topic_names"></a> [topic\_names](#input\_topic\_names) | The name of the topic instance | `list(string)` | <pre>[<br>  "topic_1",<br>  "topic_2",<br>  "topic_3"<br>]</pre> | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | Updating timeout value of the Event Streams module. | `string` | `"1h"` | no |

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
