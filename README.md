# Event Streams module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-event-streams?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module implements IBM Event Streams for IBM Cloud with topics, partitions, throughput, storage size, cleanup policy, retention time, retention size, segment size, and schema.

## About KMS encryption

The Event Streams service supports payload data encryption that uses a root key CRN of a key management service, such as Key Protect or Hyper Protect Crypto Services. You specify the root key CRN with the `kms_key_crn` input. For more information, see [Managing encryption in Event Streams](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-managing_encryption).

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-event-streams](#terraform-ibm-event-streams)
* [Submodules](./modules)
    * [fscloud](./modules/fscloud)
* [Examples](./examples)
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
    * <a href="./examples/basic">Basic example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=event-streams-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
    * <a href="./examples/complete">Complete example with topics and schema creation.</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=event-streams-complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/examples/complete"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
    * <a href="./examples/fscloud">Financial Services Cloud profile example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=event-streams-fscloud-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/examples/fscloud"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-event-streams
### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
module "event_streams" {
  source  = "terraform-ibm-modules/event-streams/ibm"
  version = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of resource group to use
  plan              = "standard"
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
  schemas            = [{
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

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Event Streams** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, <2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.35.11 |
| <a name="module_es_guid_crn_parser"></a> [es\_guid\_crn\_parser](#module\_es\_guid\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |
| <a name="module_kms_key_crn_parser"></a> [kms\_key\_crn\_parser](#module\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_event_streams_mirroring_config.es_mirroring_config](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_mirroring_config) | resource |
| [ibm_event_streams_quota.eventstreams_quotas](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_quota) | resource |
| [ibm_event_streams_schema.es_schema](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_schema) | resource |
| [ibm_event_streams_schema_global_rule.es_globalrule](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_schema_global_rule) | resource |
| [ibm_event_streams_topic.es_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_topic) | resource |
| [ibm_iam_authorization_policy.es_s2s_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.es_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.service_credentials](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.es_access_tag](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_es_s2s_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_kms_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | The list of access tags associated with the Event Streams instance. | `list(string)` | `[]` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The context-based restrictions rule to create. Only one rule is allowed. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | The timeout value for creating an Event Streams instance. Specify `3h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. Add 30 min for each level of non-default storage size. | `string` | `"3h"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | The timeout value for deleting an Event Streams instance. | `string` | `"15m"` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | The name to give the Event Streams instance created by this module. | `string` | n/a | yes |
| <a name="input_iam_token_only"></a> [iam\_token\_only](#input\_iam\_token\_only) | If set to true, disables Kafka's SASL PLAIN authentication method, only allowing clients to authenticate with SASL OAUTHBEARER via IAM access token. For more information, see: https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-security. Only allowed for enterprise plans. | `bool` | `false` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Set this to true to control the encryption keys used to encrypt the data that you store in IBM Cloud® Databases. If set to false, the data is encrypted by using randomly generated keys. For more info on Key Protect integration, see https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect. For more info on HPCS integration, see https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of the key management service (Key Protect or Hyper Protect Crypto Services) to use to encrypt the payload data. [Learn more](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-managing_encryption) about integrating Hyper Protect Crypto Services with Event Streams. | `string` | `null` | no |
| <a name="input_metrics"></a> [metrics](#input\_metrics) | Enhanced metrics to activate, as list of strings. Only allowed for enterprise plans. Allowed values: 'topic', 'partition', 'consumers'. | `list(string)` | `[]` | no |
| <a name="input_mirroring"></a> [mirroring](#input\_mirroring) | Event Streams mirroring configuration. Required only if creating mirroring instance. For more information on mirroring, see https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring. | <pre>object({<br/>    source_crn   = string<br/>    source_alias = string<br/>    target_alias = string<br/>    options = optional(object({<br/>      topic_name_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>      group_id_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>    }))<br/>    schemas = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_mirroring_topic_patterns"></a> [mirroring\_topic\_patterns](#input\_mirroring\_topic\_patterns) | The list of the topics to set in instance. Required only if creating mirroring instance. | `list(string)` | `null` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | The plan for the Event Streams instance. Possible values: `lite`, `standard`, `enterprise-3nodes-2tb`. | `string` | `"standard"` | no |
| <a name="input_quotas"></a> [quotas](#input\_quotas) | Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota. | <pre>list(object({<br/>    entity             = string<br/>    producer_byte_rate = optional(number, -1)<br/>    consumer_byte_rate = optional(number, -1)<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the Event Streams instance is created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the Event Streams instance is created. | `string` | n/a | yes |
| <a name="input_resource_keys"></a> [resource\_keys](#input\_resource\_keys) | A list of service credential resource keys to be created for the Event Streams instance. | <pre>list(object({<br/>    name     = string<br/>    key_name = optional(string, null)<br/>    role     = optional(string, "Manager")<br/>    endpoint = optional(string, "public")<br/>  }))</pre> | `[]` | no |
| <a name="input_schema_global_rule"></a> [schema\_global\_rule](#input\_schema\_global\_rule) | Schema global compatibility rule. Allowed values are 'NONE', 'FULL', 'FULL\_TRANSITIVE', 'FORWARD', 'FORWARD\_TRANSITIVE', 'BACKWARD', 'BACKWARD\_TRANSITIVE'. | `string` | `null` | no |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema objects. Include the `schema_id` and the `type` and `name` of the schema in the `schema` object. | <pre>list(object(<br/>    {<br/>      schema_id = string<br/>      schema = object({<br/>        type = string<br/>        name = string<br/>        fields = optional(list(object({<br/>          name = string<br/>          type = string<br/>        })))<br/>      })<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of service endpoints. Possible values: 'public', 'private', 'public-and-private'. | `string` | `"public"` | no |
| <a name="input_skip_es_s2s_iam_authorization_policy"></a> [skip\_es\_s2s\_iam\_authorization\_policy](#input\_skip\_es\_s2s\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that will allow all Event Streams instances in the given resource group access to read from the mirror source instance. This policy is required when creating a mirroring instance, and will only be created if a value is passed in the mirroring input. | `bool` | `false` | no |
| <a name="input_skip_kms_iam_authorization_policy"></a> [skip\_kms\_iam\_authorization\_policy](#input\_skip\_kms\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Event Streams database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `kms_key_crn` variable. In addition, no policy is created if var.kms\_encryption\_enabled is set to false. | `bool` | `false` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | Storage size of the Event Streams in GB. Applies only to Enterprise plan instances. Possible values: `2048`, `4096`, `6144`, `8192`, `10240`, `12288`. Storage capacity cannot be reduced after the instance is created. When the `throughput` input variable is set to `300`, storage size starts at 4096. When `throughput` is `450`, storage size starts starts at `6144`. | `number` | `"2048"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The list of tags associated with the Event Streams instance. | `list(string)` | `[]` | no |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | Throughput capacity in MB per second. Applies only to Enterprise plan instances. Possible values: `150`, `300`, `450`. | `number` | `"150"` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | The list of topics to apply to resources. Only one topic is allowed for Lite plan instances. | <pre>list(object(<br/>    {<br/>      name       = string<br/>      partitions = number<br/>      config     = map(string)<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | The timeout value for updating an Event Streams instance. Specify `1h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. A 30 min for each level of non-default storage size. | `string` | `"1h"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | Event Streams crn |
| <a name="output_guid"></a> [guid](#output\_guid) | Event Streams guid |
| <a name="output_id"></a> [id](#output\_id) | Event Streams instance id |
| <a name="output_kafka_broker_version"></a> [kafka\_broker\_version](#output\_kafka\_broker\_version) | The Kafka version |
| <a name="output_kafka_brokers_sasl"></a> [kafka\_brokers\_sasl](#output\_kafka\_brokers\_sasl) | (Array of Strings) Kafka brokers use for interacting with Kafka native API |
| <a name="output_kafka_http_url"></a> [kafka\_http\_url](#output\_kafka\_http\_url) | The API endpoint to interact with Event Streams REST API |
| <a name="output_mirroring_config_id"></a> [mirroring\_config\_id](#output\_mirroring\_config\_id) | The ID of the mirroring config in CRN format |
| <a name="output_mirroring_topic_patterns"></a> [mirroring\_topic\_patterns](#output\_mirroring\_topic\_patterns) | Mirroring topic patterns |
| <a name="output_resource_keys"></a> [resource\_keys](#output\_resource\_keys) | List of resource keys |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
