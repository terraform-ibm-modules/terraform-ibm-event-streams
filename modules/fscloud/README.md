# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Solution for IBM Cloud Framework for Financial Services](/solutions/standard/) for logic that uses this module. The profile assumes you are deploying into an account that complies with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable rules.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_event_streams"></a> [event\_streams](#module\_event\_streams) | ../../ | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | Add access management tags to the Event Streams instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console). | `list(string)` | `[]` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The list of context-based restriction rules to create. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | The timeout value for creating an Event Streams instance. Specify `3h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. Add 30 min for each level of non-default storage size. | `string` | `"3h"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | The timeout value for deleting an Event Streams instance. | `string` | `"15m"` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | The name of the Event Streams instance. | `string` | n/a | yes |
| <a name="input_iam_token_only"></a> [iam\_token\_only](#input\_iam\_token\_only) | If set to true, disables Kafka's SASL PLAIN authentication method, only allowing clients to authenticate with SASL OAUTHBEARER via IAM access token. For more information, see: https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-security. Only allowed for enterprise plans. | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of the key management service (Key Protect or Hyper Protect Crypto Services) to use to encrypt the payload data. | `string` | n/a | yes |
| <a name="input_metrics"></a> [metrics](#input\_metrics) | Enhanced metrics to activate, as list of strings. Allowed values: 'topic', 'partition', 'consumers'. | `list(string)` | `[]` | no |
| <a name="input_mirroring"></a> [mirroring](#input\_mirroring) | Event Streams mirroring configuration. Required only if creating mirroring instance. For more information on mirroring, see https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring. | <pre>object({<br/>    source_crn   = string<br/>    source_alias = string<br/>    target_alias = string<br/>    options = optional(object({<br/>      topic_name_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>      group_id_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>    }))<br/>    schemas = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_mirroring_topic_patterns"></a> [mirroring\_topic\_patterns](#input\_mirroring\_topic\_patterns) | The list of the topics to set in instance. Required only if creating mirroring instance. | `list(string)` | `null` | no |
| <a name="input_quotas"></a> [quotas](#input\_quotas) | Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota. | <pre>list(object({<br/>    entity             = string<br/>    producer_byte_rate = optional(number, -1)<br/>    consumer_byte_rate = optional(number, -1)<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the Event Streams are created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the Event Streams instance is created. | `string` | n/a | yes |
| <a name="input_resource_keys"></a> [resource\_keys](#input\_resource\_keys) | A list of service credential resource keys to be created for the Event Streams instance. | <pre>list(object({<br/>    name     = string<br/>    role     = optional(string, "Reader")<br/>    endpoint = optional(string, "private")<br/>  }))</pre> | `[]` | no |
| <a name="input_schema_global_rule"></a> [schema\_global\_rule](#input\_schema\_global\_rule) | Schema global compatibility rule. Allowed values are 'NONE', 'FULL', 'FULL\_TRANSITIVE', 'FORWARD', 'FORWARD\_TRANSITIVE', 'BACKWARD', 'BACKWARD\_TRANSITIVE'. | `string` | `null` | no |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | List of schema objects. Each schema must include `schema_id` and `schema` definition. Supports full Apache Avro specification with nested structures. [Learn more](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-ES_schema_registry#ES_apache_avro_data_format). | `any` | `[]` | no |
| <a name="input_skip_es_s2s_iam_authorization_policy"></a> [skip\_es\_s2s\_iam\_authorization\_policy](#input\_skip\_es\_s2s\_iam\_authorization\_policy) | Set to true to skip the creation of an Event Streams s2s IAM authorization policy to provision an Event Streams mirroring instance. This is required to read from the source cluster. This policy is required when creating mirroring instance. | `bool` | `false` | no |
| <a name="input_skip_kms_iam_authorization_policy"></a> [skip\_kms\_iam\_authorization\_policy](#input\_skip\_kms\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Event Streams database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the kms\_key\_crn variable. In addition, no policy is created if var.kms\_encryption\_enabled is set to false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Add user resource tags to the Event Streams instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types). | `list(string)` | `[]` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | The list of topics to apply to resources. Only one topic is allowed for Lite plan instances. | <pre>list(object(<br/>    {<br/>      name       = string<br/>      partitions = number<br/>      config     = map(string)<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | The timeout value for updating an Event Streams instance. Specify `1h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. A 30 min for each level of non-default storage size. | `string` | `"1h"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | Event Streams instance crn |
| <a name="output_guid"></a> [guid](#output\_guid) | Event Streams instance guid |
| <a name="output_id"></a> [id](#output\_id) | Event Streams instance id |
| <a name="output_kafka_broker_version"></a> [kafka\_broker\_version](#output\_kafka\_broker\_version) | The Kafka version |
| <a name="output_kafka_brokers_sasl"></a> [kafka\_brokers\_sasl](#output\_kafka\_brokers\_sasl) | (Array of Strings) Kafka brokers use for interacting with Kafka native API |
| <a name="output_kafka_http_url"></a> [kafka\_http\_url](#output\_kafka\_http\_url) | The API endpoint to interact with Event Streams REST API |
| <a name="output_mirroring_config_id"></a> [mirroring\_config\_id](#output\_mirroring\_config\_id) | The ID of the mirroring config in CRN format |
| <a name="output_mirroring_topic_patterns"></a> [mirroring\_topic\_patterns](#output\_mirroring\_topic\_patterns) | Mirroring topic patterns |
| <a name="output_resource_keys"></a> [resource\_keys](#output\_resource\_keys) | List of resource keys |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
