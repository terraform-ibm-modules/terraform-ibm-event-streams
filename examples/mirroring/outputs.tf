##############################################################################
# Outputs
##############################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "crn" {
  description = "Event Streams mirror instance crn"
  value       = module.event_streams_mirror.crn
}

output "guid" {
  description = "Event Streams instance guid"
  value       = module.event_streams_mirror.guid
}

output "kafka_brokers_sasl" {
  description = "(Array of Strings) Kafka brokers use for interacting with Kafka native API"
  value       = module.event_streams_mirror.kafka_brokers_sasl
}

output "kafka_http_url" {
  description = "The API endpoint to interact with Event Streams REST API"
  value       = module.event_streams_mirror.kafka_http_url
}

output "kafka_broker_version" {
  description = "The Kafka version"
  value       = module.event_streams_mirror.kafka_broker_version
}

output "mirroring_config_id" {
  description = "The ID of the mirroring config in CRN format"
  value       = module.event_streams_mirror.mirroring_config_id
}

output "mirroring_topic_patterns" {
  description = "Mirroring topic patterns"
  value       = module.event_streams_mirror.mirroring_topic_patterns
}
