#  Cloud automation for Event Streams (Security-Enforced)

## Prerequisites
- An existing resource group
- An existing KMS instance (or key) if you wan't to encrypt the Event Streams instance.

This solution supports provisioning and configuring the following infrastructure:

- An Event Streams instance.
- Topics to apply to resources.
- Schemas to apply to resources.
- Mirroring of existing event stream instace.

![event-streams-security-enforced-deployable-architecture](../../reference-architecture/deployable-architecture-event-streams-security-enforced.svg)

**Important:** Because this solution contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments, do not call this solution from one or more other modules. For more information about how resources are associated with provider configurations with multiple modules, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.76.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_event_streams"></a> [event\_streams](#module\_event\_streams) | ../../ | n/a |
| <a name="module_existing_sm_crn_parser"></a> [existing\_sm\_crn\_parser](#module\_existing\_sm\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-ibm-modules/kms-all-inclusive/ibm | 4.22.0 |
| <a name="module_kms_instance_crn_parser"></a> [kms\_instance\_crn\_parser](#module\_kms\_instance\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_kms_key_crn_parser"></a> [kms\_key\_crn\_parser](#module\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.6 |
| <a name="module_secrets_manager_service_credentials"></a> [secrets\_manager\_service\_credentials](#module\_secrets\_manager\_service\_credentials) | terraform-ibm-modules/secrets-manager/ibm//modules/secrets | 2.2.6 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.secrets_manager_key_manager](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/resources/iam_authorization_policy) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) | resource |
| [time_sleep.wait_for_en_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | A single context-based restriction rule to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-schemas-topics-cbr.md#options-with-cbr). | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | The timeout value for creating an Event Streams instance. Specify `3h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. Add 30 min for each level of non-default storage size. | `string` | `"3h"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | The timeout value for deleting an Event Streams instance. | `string` | `"15m"` | no |
| <a name="input_event_stream_instance_access_tags"></a> [event\_stream\_instance\_access\_tags](#input\_event\_stream\_instance\_access\_tags) | The list of access tags associated with the Event Steams instance. | `list(string)` | `[]` | no |
| <a name="input_event_stream_instance_resource_tags"></a> [event\_stream\_instance\_resource\_tags](#input\_event\_stream\_instance\_resource\_tags) | List of tags associated with the Event Steams instance | `list(string)` | `[]` | no |
| <a name="input_event_streams_name"></a> [event\_streams\_name](#input\_event\_streams\_name) | The name of the Event Streams instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format. | `string` | `"event-streams"` | no |
| <a name="input_existing_event_streams_kms_key_crn"></a> [existing\_event\_streams\_kms\_key\_crn](#input\_existing\_event\_streams\_kms\_key\_crn) | The CRN of a Key Protect or Hyper Protect Crypto Services key to use for Event Streams. If not specified, a key ring and key are created. | `string` | `null` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of a Key Protect or Hyper Protect Crypto Services instance. Required only when creating a new encryption key and key ring which will be used to encrypt event streams. To use an existing key, pass values for `existing_event_streams_kms_key_crn`. | `string` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision resource in. | `string` | `"Default"` | no |
| <a name="input_existing_secrets_manager_endpoint_type"></a> [existing\_secrets\_manager\_endpoint\_type](#input\_existing\_secrets\_manager\_endpoint\_type) | The endpoint type to use if `existing_secrets_manager_instance_crn` is specified. Possible values: public, private. | `string` | `"private"` | no |
| <a name="input_existing_secrets_manager_instance_crn"></a> [existing\_secrets\_manager\_instance\_crn](#input\_existing\_secrets\_manager\_instance\_crn) | The CRN of existing secrets manager to use to create service credential secrets for Event Streams instance. | `string` | `null` | no |
| <a name="input_iam_token_only"></a> [iam\_token\_only](#input\_iam\_token\_only) | If set to true, disables Kafka's SASL PLAIN authentication method, only allowing clients to authenticate with SASL OAUTHBEARER via IAM access token. For more information, see: https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-security. Only allowed for enterprise plans. | `bool` | `false` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key used to provision resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_kms_api_key"></a> [ibmcloud\_kms\_api\_key](#input\_ibmcloud\_kms\_api\_key) | The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud\_api\_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Event Streams instance. Leave this input empty if the same account owns both instances. | `string` | `null` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | The name for the new root key. Applies only if existing\_event\_streams\_kms\_key\_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format.` | `string` | `"event-streams-key"` | no |
| <a name="input_kms_key_ring_name"></a> [kms\_key\_ring\_name](#input\_kms\_key\_ring\_name) | The name for the new key ring to store the key. Applies only if `existing_event_streams_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format. . | `string` | `"event-streams-key-ring"` | no |
| <a name="input_metrics"></a> [metrics](#input\_metrics) | Enhanced metrics to activate, as list of strings. Allowed values: 'topic', 'partition', 'consumers'. | `list(string)` | `[]` | no |
| <a name="input_mirroring"></a> [mirroring](#input\_mirroring) | Event Streams mirroring configuration. Required only if creating mirroring instance. For more information on mirroring, see https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#mirroring and https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring. | <pre>object({<br/>    source_crn   = string<br/>    source_alias = string<br/>    target_alias = string<br/>    options = optional(object({<br/>      topic_name_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>      group_id_transform = object({<br/>        type = string<br/>        rename = optional(object({<br/>          add_prefix    = optional(string)<br/>          add_suffix    = optional(string)<br/>          remove_prefix = optional(string)<br/>          remove_suffix = optional(string)<br/>        }))<br/>      })<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_mirroring_topic_patterns"></a> [mirroring\_topic\_patterns](#input\_mirroring\_topic\_patterns) | The list of the topics to set in instance. Required only if creating mirroring instance. | `list(string)` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-0205-es. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA.prefix.md). | `string` | n/a | yes |
| <a name="input_provider_visibility"></a> [provider\_visibility](#input\_provider\_visibility) | Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints). | `string` | `"private"` | no |
| <a name="input_quotas"></a> [quotas](#input\_quotas) | Quotas to be applied to the Event Streams instance. Entity may be 'default' to apply to all users, or an IAM ServiceID for a specific user. Rates are bytes/second, with -1 meaning no quota. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#quotas) | <pre>list(object({<br/>    entity             = string<br/>    producer_byte_rate = optional(number, -1)<br/>    consumer_byte_rate = optional(number, -1)<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision resources to. | `string` | `"us-south"` | no |
| <a name="input_schema_global_rule"></a> [schema\_global\_rule](#input\_schema\_global\_rule) | Schema global compatibility rule. Allowed values are 'NONE', 'FULL', 'FULL\_TRANSITIVE', 'FORWARD', 'FORWARD\_TRANSITIVE', 'BACKWARD', 'BACKWARD\_TRANSITIVE'. | `string` | `null` | no |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | The list of schema objects. Include the `schema_id`, `type` and `name` of the schema in the `schema` object. Learn more: https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-schemas-topics-cbr.md#options-with-schemas. | <pre>list(object({<br/>    schema_id = string<br/>    schema = object({<br/>      type = string<br/>      name = string<br/>      fields = optional(list(object({<br/>        name = string<br/>        type = string<br/>      })))<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_service_credential_names"></a> [service\_credential\_names](#input\_service\_credential\_names) | The mapping of names and roles for service credentials that you want to create for the Event streams.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#svc-credential-name) | `map(string)` | `{}` | no |
| <a name="input_service_credential_secrets"></a> [service\_credential\_secrets](#input\_service\_credential\_secrets) | Service credential secrets configuration for Event Streams. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-types.md#service-credential-secrets). | <pre>list(object({<br/>    secret_group_name        = string # pragma: allowlist secret<br/>    secret_group_description = optional(string)<br/>    existing_secret_group    = optional(bool)<br/>    service_credentials = list(object({<br/>      secret_name                                 = string<br/>      service_credentials_source_service_role_crn = string<br/>      secret_labels                               = optional(list(string))<br/>      secret_auto_rotation                        = optional(bool)<br/>      secret_auto_rotation_unit                   = optional(string)<br/>      secret_auto_rotation_interval               = optional(number)<br/>      service_credentials_ttl                     = optional(string)<br/>      service_credential_secret_description       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_skip_event_streams_kms_auth_policy"></a> [skip\_event\_streams\_kms\_auth\_policy](#input\_skip\_event\_streams\_kms\_auth\_policy) | Set to true to skip the creation of IAM authorization policies that permits all Event Streams instances in the given resource group 'Reader' access to the Key Protect or Hyper Protect Crypto Services key. This policy is required in order to enable KMS encryption, so only skip creation if there is one already present in your account. | `bool` | `false` | no |
| <a name="input_skip_event_streams_s2s_iam_auth_policy"></a> [skip\_event\_streams\_s2s\_iam\_auth\_policy](#input\_skip\_event\_streams\_s2s\_iam\_auth\_policy) | Set to true to skip the creation of an Event Streams s2s IAM authorization policy to provision an Event Streams mirroring instance. This is required to read from the source cluster. This policy is required when creating mirroring instance. | `bool` | `false` | no |
| <a name="input_skip_event_streams_secrets_manager_auth_policy"></a> [skip\_event\_streams\_secrets\_manager\_auth\_policy](#input\_skip\_event\_streams\_secrets\_manager\_auth\_policy) | Whether an IAM authorization policy is created for Secrets Manager instance to create a service credential secrets for Event Streams.If set to false, the Secrets Manager instance passed by the user is granted the Key Manager access to the Event Streams instance created by the Deployable Architecture. Set to `true` to use an existing policy. The value of this is ignored if any value for 'existing\_secrets\_manager\_instance\_crn' is not passed. | `bool` | `false` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | The list of topics to apply to resources. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/solutions/enterprise/DA-schemas-topics-cbr.md#options-with-topics). | <pre>list(object(<br/>    {<br/>      name       = string<br/>      partitions = number<br/>      config     = object({})<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | The timeout value for updating an Event Streams instance. Specify `1h` for an Enterprise plan instance. Add 1 h for each level of non-default throughput. A 30 min for each level of non-default storage size. | `string` | `"1h"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_streams_crn"></a> [event\_streams\_crn](#output\_event\_streams\_crn) | Event Streams instance crn |
| <a name="output_event_streams_guid"></a> [event\_streams\_guid](#output\_event\_streams\_guid) | Event Streams instance guid |
| <a name="output_event_streams_id"></a> [event\_streams\_id](#output\_event\_streams\_id) | Event Streams instance id |
| <a name="output_event_streams_mirroring_config_id"></a> [event\_streams\_mirroring\_config\_id](#output\_event\_streams\_mirroring\_config\_id) | The ID of the mirroring config in CRN format |
| <a name="output_event_streams_mirroring_topic_patterns"></a> [event\_streams\_mirroring\_topic\_patterns](#output\_event\_streams\_mirroring\_topic\_patterns) | Mirroring topic patterns |
| <a name="output_kafka_broker_version"></a> [kafka\_broker\_version](#output\_kafka\_broker\_version) | The Kafka version |
| <a name="output_kafka_brokers_sasl"></a> [kafka\_brokers\_sasl](#output\_kafka\_brokers\_sasl) | (Array of Strings) Kafka brokers use for interacting with Kafka native API |
| <a name="output_kafka_http_url"></a> [kafka\_http\_url](#output\_kafka\_http\_url) | The API endpoint to interact with Event Streams REST API |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group ID |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
| <a name="output_service_credential_secret_groups"></a> [service\_credential\_secret\_groups](#output\_service\_credential\_secret\_groups) | Service credential secret groups |
| <a name="output_service_credential_secrets"></a> [service\_credential\_secrets](#output\_service\_credential\_secrets) | Service credential secrets |
| <a name="output_service_credentials_json"></a> [service\_credentials\_json](#output\_service\_credentials\_json) | Service credentials json map |
| <a name="output_service_credentials_object"></a> [service\_credentials\_object](#output\_service\_credentials\_object) | Service credentials object |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
