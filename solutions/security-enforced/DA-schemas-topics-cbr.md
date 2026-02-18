# Configuring topics and schemas in Event Streams

When you add a Event Streams deployable architecture from the IBM Cloud catalog to IBM Cloud Projects, you can configure topics, schemas and context-based restriction rules. When you edit your project configuration, select the **Configure** panel, and then click the **Optional** tab.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the topics configurations to the array.

## Options with topics <a name="options-with-topics"></a>

- `name` (required): The name of the topic.
- `partitions` (optional): The number of partitions of the topic. The default value is `1`.
- `config` (optional): The configuration parameters of the topic. Supported configurations are: `cleanup.policy`, `retention.ms`, `retention.bytes`, `segment.bytes`, `segment.ms`, `segment.index.bytes`.

The following example includes all the configuration options for topics.

```hcl
[
    {
        name       = "my-es-topic"
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
```

## Options with schemas <a name="options-with-schemas"></a>

- `schema_id` (required): The unique ID to be assigned to schema. If this value is not specified, a generated UUID is assigned.
- `schema` (required): The schema definition as a JSON-compatible Terraform object. Supports nested structures, arrays, maps, and other complex objects.

The following example includes all the configuration options for schemas.

```hcl
[
    {
      schema_id = "job_events_cloud_sync_value_v1"
      schema = {
        type      = "record"
        name      = "job_events_cloud_sync_value_v1"
        namespace = "envelope"
        fields = [
          { name = "source", type = "string" },
          { name = "subject", type = "string" },
          { name = "time", type = "string" },
          { name = "datacontenttype", type = "string", default = "application/json" },
          { name = "producer", type = "string" },
          {
            name = "data"
            type = {
              type      = "record"
              name      = "payload"
              namespace = "payload"
              fields = [
                { name = "event_type", type = "string" },
                { name = "job_id", type = "string" },
                { name = "metadata", type = ["null", "string"], default = null },
                { name = "monotonic_ns", type = "long" },
                { name = "source_instance_id", type = "string" },
                { name = "source_type_id", type = "string" },
                { name = "sub_job_id", type = ["null", "string"], default = null }
              ]
            }
          }
        ]
      }
    },
    {
      schema_id = "my-es-schema_1"
      schema = {
        type = "record"
        name = "book"
        fields = [
          {
            name = "title"
            type = "string"
          },
          {
            name = "author"
            type = "string"
          }
        ]
      }
    },
    {
      schema_id = "my-es-schema_2"
      schema = {
        type = "record"
        name = "book"
        fields = [
          {
            name = "author"
            type = "string"
          },
          {
            name = "title"
            type = "string"
          }
        ]
      }
    }
]
```

## Options with context-based restriction (cbr) rules <a name="options-with-cbr"></a>

- `description` (required): The description of the context-based restriction rule.
- `enforcement_mode` (required): The rule enforcement mode. Supported values are: `enabled`, `disabled` and `report`.
- `account_id` (required): The id of the account owning this cbr rule .
- `rule_contexts` (required): The list of contexts the rule applies to. Supported `attributes` configurations are: `name` and `value`.

The following example includes all the configuration options for cbr rule.

```hcl
[
    {
        description      = "Event streams access only from vpc"
        enforcement_mode = "enabled"
        account_id       = "defc0df06b644a9cabc6e44f55b3880s"
        rule_contexts = [{
            attributes = [
                {
                    name = "endpointType",
                    value = "private"
                },
                {
                    name  = "networkZoneId"
                    value = "93a51a1debe2674193217209601dde6f" # pragma: allowlist secret
            }]
        }]
    }
]
```
