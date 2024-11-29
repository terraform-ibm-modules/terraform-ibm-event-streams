# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Solution for IBM Cloud Framework for Financial Services](/solutions/standard/) for logic that uses this module. The profile assumes you are deploying into an account that complies with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable rules.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.71.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_event_streams"></a> [event\_streams](#module\_event\_streams) | ../../ | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | The list of access tags associated with the Event Steams instance. | `list(string)` | `[]` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The list of context-based restriction rules to create. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_es_name"></a> [es\_name](#input\_es\_name) | The name of the Event Streams instance. | `string` | n/a | yes |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | The GUID of the Hyper Protect Crypto service in which the key specified in var.kms\_key\_crn is coming from | `string` | n/a | yes |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of the key management service (Key Protect or Hyper Protect Crypto Services) to use to encrypt the payload data. | `string` | n/a | yes |
| <a name="input_metrics"></a> [metrics](#input\_metrics) | Enhanced metrics to activate, as list of strings. Allowed values: 'topic', 'partition', 'consumers'. | `list(string)` | `[]` | no |
| <a name="input_mirroring"></a> [mirroring](#input\_mirroring) | Configuration for the mirroring setup. (Optional) Valid values for 'type' are 'rename', 'none', or 'use\_alias'. If 'type' is set to 'rename', then 'rename' object must include the following fields: 'add\_prefix', 'add\_suffix', 'remove\_prefix', and 'remove\_suffix'. | <pre>object({<br/>    source_crn   = string<br/>    source_alias = string<br/>    target_alias = string<br/>    options = optional(object({<br/>      topic_name_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>      group_id_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_mirroring_topic_patterns"></a> [mirroring\_topic\_patterns](#input\_mirroring\_topic\_patterns) | The list of the topics to set in instance. Required only if creating mirroring instance. | `list(string)` | `null` | no |
| <a name="input_quotas"></a> [quotas](#input\_quotas) | Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota. | <pre>list(object({<br/>    entity             = string<br/>    producer_byte_rate = optional(number, -1)<br/>    consumer_byte_rate = optional(number, -1)<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the Event Streams are created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the Event Streams instance is created. | `string` | n/a | yes |
| <a name="input_schema_global_rule"></a> [schema\_global\_rule](#input\_schema\_global\_rule) | Schema global compatibility rule. Allowed values are 'NONE', 'FULL', 'FULL\_TRANSITIVE', 'FORWARD', 'FORWARD\_TRANSITIVE', 'BACKWARD', 'BACKWARD\_TRANSITIVE'. | `string` | `null` | no |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema objects. Include the `schema_id` and the `type` and `name` of the schema in the `schema` object. | <pre>list(object(<br/>    {<br/>      schema_id = string<br/>      schema = object({<br/>        type = string<br/>        name = string<br/>        fields = optional(list(object({<br/>          name = string<br/>          type = string<br/>        })))<br/>      })<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_service_credential_names"></a> [service\_credential\_names](#input\_service\_credential\_names) | The mapping of names and roles for service credentials that you want to create for the Event streams. | `map(string)` | `{}` | no |
| <a name="input_skip_es_s2s_iam_authorization_policy"></a> [skip\_es\_s2s\_iam\_authorization\_policy](#input\_skip\_es\_s2s\_iam\_authorization\_policy) | Set to true to skip the creation of an Event Streams s2s IAM authorization policy to provision an Event Streams mirroring instance. This is required to read from the source cluster. This policy is required when creating mirroring instance. | `bool` | `false` | no |
| <a name="input_skip_kms_iam_authorization_policy"></a> [skip\_kms\_iam\_authorization\_policy](#input\_skip\_kms\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Event Streams database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing\_kms\_instance\_guid variable. In addition, no policy is created if var.kms\_encryption\_enabled is set to false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The list of tags associated with the Event Steams instance. | `list(string)` | `[]` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | The list of topics to apply to resources. Only one topic is allowed for Lite plan instances. | <pre>list(object(<br/>    {<br/>      name       = string<br/>      partitions = number<br/>      config     = map(string)<br/>    }<br/>  ))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | Event Streams instance crn |
| <a name="output_guid"></a> [guid](#output\_guid) | Event Streams instance guid |
| <a name="output_id"></a> [id](#output\_id) | Event Streams instance crn |
| <a name="output_kafka_broker_version"></a> [kafka\_broker\_version](#output\_kafka\_broker\_version) | The Kafka version |
| <a name="output_kafka_brokers_sasl"></a> [kafka\_brokers\_sasl](#output\_kafka\_brokers\_sasl) | (Array of Strings) Kafka brokers use for interacting with Kafka native API |
| <a name="output_kafka_http_url"></a> [kafka\_http\_url](#output\_kafka\_http\_url) | The API endpoint to interact with Event Streams REST API |
| <a name="output_mirroring_config_id"></a> [mirroring\_config\_id](#output\_mirroring\_config\_id) | The ID of the mirroring config in CRN format |
| <a name="output_mirroring_topic_patterns"></a> [mirroring\_topic\_patterns](#output\_mirroring\_topic\_patterns) | Mirroring topic patterns |
| <a name="output_service_credentials_json"></a> [service\_credentials\_json](#output\_service\_credentials\_json) | Service credentials json map |
| <a name="output_service_credentials_object"></a> [service\_credentials\_object](#output\_service\_credentials\_object) | Service credentials object |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
