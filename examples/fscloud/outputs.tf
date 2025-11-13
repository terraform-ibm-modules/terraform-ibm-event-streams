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
  description = "Event Streams instance crn"
  value       = module.event_streams.crn
}

output "guid" {
  description = "Event Streams instance guid"
  value       = module.event_streams.guid
}

output "kafka_brokers_sasl" {
  description = "(Array of Strings) Kafka brokers use for interacting with Kafka native API"
  value       = module.event_streams.kafka_brokers_sasl
}

output "kafka_http_url" {
  description = "The API endpoint to interact with Event Streams REST API"
  value       = module.event_streams.kafka_http_url
}

output "resource_keys" {
  description = "List of resource keys"
  value       = module.event_streams.resource_keys
  sensitive   = true
}
output "mirroring_config_id" {
  description = "The ID of the mirroring config in CRN format"
  value       = module.event_streams.mirroring_config_id
}

output "mirroring_topic_patterns" {
  description = "Mirroring topic patterns"
  value       = module.event_streams.mirroring_topic_patterns
}
