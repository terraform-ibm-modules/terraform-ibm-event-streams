# Configuring complex inputs in Event Streams

Several optional input variables in the IBM Cloud Event Streams deployable architecture use complex object types. You specify these inputs when you configure your deployable architecture.

- [Resource keys](#resource-keys) (`resource_keys`)
- [Service credential secrets](#service-credential-secrets) (`service_credential_secrets`)
- [Quotas](#quotas) (`quotas`)
- [Mirroring](#mirroring) (`mirroring`)

## Resource keys <a name="resource-keys"></a>
When you add an IBM Event Streams deployable architecture from the IBM Cloud catalog to an IBM Cloud Projects service, you can configure resource keys. In the edit mode for the projects configuration, select the Configure panel and then click the optional tab.

In the configuration, specify the name of the resource key, , the Role of the key and an optional endpoint.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the resource key configurations to the array here.

 [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) about resource keys.

- Variable name: `resource_keys`.
- Type: A list of objects that represent a resource key
- Default value: An empty list (`[]`)

### Options for resource_key

- `name` (required): A unique human-readable name that identifies this resource key.
- `role` (optional, default = `Reader`): The name of the user role. These are the supported roles : `Writer`, `Reader`, `Manager`, `NONE` .
- `endpoint` (optional, default = `private`): The endpoint of resource key.

The following example includes all the configuration options for two resource keys. One is with a `Reader` role with `Private` endpoint, the other with an IAM key with `Writer` role.
```hcl
[
  {
    "name": "es-reader-resource-key",
    "role": "Reader",
    "endpoint": "private"
  },
  {
    "name": "es-writer-resource-key",
    "role": "Writer"
    "endpoint": "private"
  }
]
```

## Service credential secrets <a name="service-credential-secrets"></a>

When you add an IBM Event Streams deployable architecture from the IBM Cloud catalog to IBM Cloud Project, you can configure service credentials. In edit mode for the projects configuration, from the configure panel click the optional tab.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the service credential secrets configurations to the array here.

In the configuration, specify the secret group name, whether it already exists or will be created and include all the necessary service credential secrets that need to be created within that secret group.

 [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-getting-started#getting-started) about service credential secrets.

- Variable name: `service_credential_secrets`.
- Type: A list of objects that represent service credential secret groups and secrets
- Default value: An empty list (`[]`)

### Options for service_credential_secrets

- `secret_group_name` (required): A unique human-readable name that identifies this service credential secret group.
- `secret_group_description` (optional, default = `null`): A human-readable description for this secret group.
- `existing_secret_group`: (optional, default = `false`): Set to true, if secret group name provided in the variable `secret_group_name` already exists.
- `service_credentials`: (required): A list of object that represents a service credential secret.

#### Options for service_credentials

- `secret_name`: (required): A unique human-readable name of the secret to create.
- `service_credentials_source_service_role_crn`: (required): The CRN of the role to give the service credential in the IBM Cloud Database service. Service credentials role CRNs can be found at https://cloud.ibm.com/iam/roles, select the IBM Cloud Database and select the role.
- `secret_labels`: (optional, default = `[]`): Labels of the secret to create. Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (|).
- `secret_auto_rotation`: (optional, default = `true`): Whether to configure automatic rotation of service credential.
- `secret_auto_rotation_unit`: (optional, default = `day`): Specifies the unit of time for rotation of a secret. Acceptable values are `day` or `month`.
- `secret_auto_rotation_interval`: (optional, default = `89`): Specifies the rotation interval for the rotation unit.
- `service_credentials_ttl`: (optional, default = `7776000`): The time-to-live (TTL) to assign to generated service credentials (in seconds).
- `service_credential_secret_description`: (optional, default = `null`): Description of the secret to create.

The following example includes all the configuration options for four service credentials and two secret groups.
```hcl
[
{
    "secret_group_name": "sg-1"
    "existing_secret_group": true
    "service_credentials": [ #pragma: allowlist secret
    {
        "secret_name": "cred-1"
        "service_credentials_source_service_role_crn":  "crn:v1:bluemix:public:iam::::role:Writer"
        "secret_labels": ["test-writer-1", "test-writer-2"]
        "secret_auto_rotation": true
        "secret_auto_rotation_unit": "day"
        "secret_auto_rotation_interval": 89
        "service_credentials_ttl": 7776000
        "service_credential_secret_description": "sample description"
    },
    {
        "secret_name": "cred-2"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::role:Reader"
    }
    ]
},
{
    "secret_group_name": "sg-2"
    "service_credentials": [ #pragma: allowlist secret
    {
        "secret_name": "cred-3"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::role:Editor"
    }
    ]
}
]
```

## Quotas <a name="quotas"></a>

You can set quotas of an Event Streams service instance. Both the default quota and user quotas may be managed. Quotas are only available on Event Streams Enterprise plan service instances. For more information, see [Event Streams Quotas](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-enabling_kafka_quotas).

### Options for quotas

- `entity` (required): Either default to set the default quota, or an IAM ID for a user quota.
- `producer_byte_rate` (optional): The producer quota in bytes/second. Use -1 for no quota.
- `consumer_byte_rate` (optional): The consumer quota in bytes/second. Use -1 for no quota.

### Example quotas

```hcl
{
    entity             = "default"
    producer_byte_rate = "16384"
    consumer_byte_rate = "32768"
}
```

## Mirroring <a name="mirroring"></a>

You can set mirroring which enables messages in one Event Streams service instance to be continuously copied to a second instance by using the `mirroring` input variable. For more information, see [Event Streams Mirroring](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-mirroring).

### Options for mirroring

- `source_crn` (required): The CRN of the source from where data is mirrored.
- `source_alias` (required): The source alias (e.g. `us-south`) from where data is mirrored.
- `target_alias` (required): The target alias (e.g. `us-east`) to where data is mirrored.
- `options` (optional): Transform configuration for `topic name` and `group id`. Supported configurations are: `topic_name_transform` and `group_id_transform`. Valid values for `type` are `rename`, `none`, or `use_alias`. If `type` is set to `rename`, then `rename` object must include the following fields: `add_prefix`, `add_suffix`, `remove_prefix` and `remove_suffix`.
- `schemas` (optional): Whether to forward schema registry requests to the source instance, and how. Supported options are `proxied`, `read-only`, `inactive` (default).

### Example mirroring

The following example includes all the configuration options for mirroring.

```hcl
{
    source_crn   = "event_streams_crn"
    source_alias = "us-south"
    target_alias = "us-east"
    options = {
        topic_name_transform = {
            type = "rename"
            rename = {
                add_prefix    = "add_prefix"
                add_suffix    = "add_suffix"
                remove_prefix = "remove_prefix"
                remove_suffix = "remove_suffix"
            }
        }
        group_id_transform = {
            type = "rename"
            rename = {
                add_prefix    = "add_prefix"
                add_suffix    = "add_suffix"
                remove_prefix = "remove_prefix"
                remove_suffix = "remove_suffix"
            }
        }
    }
  }
```
