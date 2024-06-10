# Event Streams module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-event-streams?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module implements Event Streams with topics, partitions, throughput, storage size, cleanup policy, retention time, retention size, segment size, and schema.

## About KMS encryption

The Event Streams service supports payload data encryption that uses a root key CRN of a key management service, such as Key Protect or Hyper Protect Crypto Services (HPCS). You specify the root key CRN with the `kms_key_crn` input. For more information, see [Managing encryption in Event Streams](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-managing_encryption).

Before you run the module, configure an authorization policy to allow the Event Streams service to access the key management service instance with the reader role. For more information, see [Using authorizations to grant access between services](https://cloud.ibm.com/docs/account?topic=account-serviceauth).

You can't manage the policy in the same Terraform state file as the Event Streams service instance. When you issue a `terraform destroy` command, the instance is only soft deleted and remains as a reclamation resource for a while to support recovery (reclamation). An authorization policy must exist when the instance is hard deleted or reclaimed or else the unregistration of the instance from the root key fails on the backend. If the policy doesn't exist, the only way to unregister the instance, which is a requirement for deletion of the root key, is by opening a support case. For more information, see [Using a customer-managed key](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-managing_encryption#using_encryption).

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-event-streams](#terraform-ibm-event-streams)
* [Submodules](./modules)
    * [fscloud](./modules/fscloud)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Complete example with topics and schema creation.](./examples/complete)
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.62.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.22.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_event_streams_schema.es_schema](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_schema) | resource |
| [ibm_event_streams_topic.es_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/event_streams_topic) | resource |
| [ibm_resource_instance.es_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, list) List of CBR rules to create | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>  }))</pre> | `[]` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Creation timeout value of the Event Streams module. Use 3h when creating enterprise instance, add more 1h for each level of non-default throughput, add more 30m for each level of non-default storage\_size | `string` | `"3h"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Deleting timeout value of the Event Streams module | `string` | `"15m"` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | The name to give the IBM Event Streams instance created by this module. | `string` | n/a | yes |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of a Key Management Services like Key Protect or Hyper Protect Crypto Services (HPCS) that you want to use payload data encryption. Only used if var.kms\_encryption\_enabled is set to true. Note an authorization policy to allow the Event Streams service to access the key management service instance as a Reader MUST be configured in advance and should not be managed as part of the same terraform state as the event streams instance, see https://cloud.ibm.com/docs/account?topic=account-serviceauth | `string` | `null` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Plan for the event streams instance : lite, standard or enterprise-3nodes-2tb | `string` | `"standard"` | no |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where event streams will be created | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the Event Streams instance will be created. | `string` | n/a | yes |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema object which contains schema id and format of the schema | <pre>list(object(<br>    {<br>      schema_id = string<br>      schema = object({<br>        type = string<br>        name = string<br>      })<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Specify whether you want to enable the public, private, or both service endpoints. Supported values are 'public', 'private', or 'public-and-private'. | `string` | `"public"` | no |
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
