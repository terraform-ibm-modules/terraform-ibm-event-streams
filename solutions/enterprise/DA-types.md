# Configuring complex inputs in Event Streams

Several optional input variables in the IBM Cloud Event Streams deployable architecture use complex object types. You specify these inputs when you configure you deployable architecture.

- [Service credentials](#svc-credential-name) (`service_credential_names`)
- [Quotas](#quotas) (`quotas`)
- [Mirroring](#mirroring) (`quotas`)

## Service credentials <a name="svc-credential-name"></a>

You can specify a set of IAM credentials to connect to the instance with the `service_credential_names` input variable. Include a credential name and IAM service role for each key-value pair. Each role provides a specific level of access to the instance. For more information, see [Adding and viewing credentials](https://cloud.ibm.com/docs/account?topic=account-service_credentials&interface=ui).

- Variable name: `service_credential_names`.
- Type: A map. The key is the name of the service credential. The value is the role that is assigned to that credential.
- Default value: An empty map (`{}`).

### Options for service_credential_names

- Key (required): The name of the service credential.
- Value (required): The IAM service role that is assigned to the credential. The following values are valid for service credential roles: 'Manager', 'Writer', 'Reader'. For more information, see [IBM Cloud IAM roles](https://cloud.ibm.com/docs/account?topic=account-userroles).

### Example service credentials

```hcl
{
    "es_writer" : "Writer",
    "es_reader" : "Reader",
    "es_manager" : "Manager"
}
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
