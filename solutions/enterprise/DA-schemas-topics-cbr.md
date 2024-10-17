# Configuring topics and schemas in Event Streams

When you add a Event Streams deployable architecture from the IBM Cloud catalog to IBM Cloud Projects, you can configure topics. When you edit your project configuration, select the **Configure** panel, and then click the **Optional** tab.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the topics configurations to the array.


## Options with topics

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

## Options with schemas

- `schema_id` (required): The unique ID to be assigned to schema. If this value is not specified, a generated UUID is assigned.
- `schema` (required): The schema in JSON format. Supported parameters are: `type`, `name` and `fields` (optional).

The following example includes all the configuration options for schemas.

```hcl
[
    {
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
    }
]
```
