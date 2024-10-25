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

output "service_credentials_json" {
  description = "Service credentials json map"
  value       = module.event_streams.service_credentials_json
  sensitive   = true
}

output "service_credentials_object" {
  description = "Service credentials object"
  value       = module.event_streams.service_credentials_object
  sensitive   = true
}
