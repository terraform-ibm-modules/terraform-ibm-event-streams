# Configuring schemas, topics and context-based restriction rules in Event Streams

When you add a Event Streams deployable architecture from the IBM Cloud catalog to IBM Cloud Projects, you can configure schemas, topics, and context-based restriction rules. When you edit your project configuration, select the **Configure** panel, and then click the **Optional** tab.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the schemas, topics, and context-based restriction rules configurations to the array.

## Options with schemas


- `schema_id` (optional): The unique ID to assign to the schema. If this value is not specified, a generated `UUID` is assigned.
- `schema`
    - `type` (required): schema type.
    - `name` (required): schema name.
    - `fields` (optional, only required when schema `type` is `complex`): A list of `name`, `type` field pairs. For more information, see [Using Event Streams Schema Registry](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-ES_schema_registry).

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
        type = "record"
        name = "name_2",
        fields : [
            {"name": "value_1", "type": "long"},
            {"name": "value_2", "type": "string"}
            ]
        }
    }
]
```

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

## Options with Context-based restriction rules

- `description` (required): The description of the rule.
- `account_id` (required): Your IBM Cloud account ID.
- `enforcement_mode`(required): The rule enforcement mode. Allowable values are: `enabled`, `disabled`, `report`. For more information, see [What are context-based restrictions](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#rule-enforcement).
- `rule_contexts` (optional): The contexts this rule applies to. For more information, see [Rule contexts](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#restriction-context).
    - `attributes` (required): List of attributes.
        - `name` (required): The attribute name.
        - `value` (required): The attribute value.

The following example includes all the configuration options for a context-based restriction rule.

```hcl
{
    description      = "Event stream access only from vpc"
    enforcement_mode = "enabled"
    account_id       = "XX....XX"
    rule_contexts = [{
    attributes = [
        {
            "name" : "endpointType",
            "value" : "private"
        },
        {
            name  = "networkZoneId"
            value = <<cbr_zone_id>>
        }]
    }]
}
```
