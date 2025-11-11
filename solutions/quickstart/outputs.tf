#############################################################################
# Outputs
#############################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "event_streams_crn" {
  description = "Event Streams instance crn"
  value       = module.event_streams.crn
}

output "event_streams_id" {
  description = "Event Streams instance id"
  value       = module.event_streams.id
}

output "event_streams_guid" {
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
output "kafka_broker_version" {
  description = "The Kafka version"
  value       = module.event_streams.kafka_broker_version
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

output "service_credential_secrets" {
  description = "Service credential secrets"
  value       = length(local.service_credential_secrets) > 0 ? module.secrets_manager_service_credentials[0].secrets : null
}

output "service_credential_secret_groups" {
  description = "Service credential secret groups"
  value       = length(local.service_credential_secrets) > 0 ? module.secrets_manager_service_credentials[0].secret_groups : null
}

output "next_steps_text" {
  value       = "Your Event Streams instance is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Event Streams Instance"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/services/messagehub/${urlencode(module.event_streams.crn)}?paneId=manage"
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = "Learn more about Event Streams"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-getting-started"
  description = "Secondary URL"
}
