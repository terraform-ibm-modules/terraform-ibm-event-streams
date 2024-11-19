##############################################################################
# Outputs
##############################################################################

output "id" {
  description = "Event Streams instance id"
  value       = ibm_resource_instance.es_instance
}

output "crn" {
  description = "Event Streams crn"
  value       = ibm_resource_instance.es_instance.crn
}

output "guid" {
  description = "Event Streams guid"
  value       = ibm_resource_instance.es_instance.guid
}

output "kafka_brokers_sasl" {
  description = "(Array of Strings) Kafka brokers use for interacting with Kafka native API"
  value       = lookup(ibm_resource_instance.es_instance.extensions, "kafka_brokers_sasl", null)
}

output "kafka_http_url" {
  description = "The API endpoint to interact with Event Streams REST API"
  value       = ibm_resource_instance.es_instance.extensions.kafka_http_url
}

output "kafka_broker_version" {
  description = "The Kafka version"
  value       = ibm_resource_instance.es_instance.extensions.kafka_broker_version
}

output "service_credentials_json" {
  description = "The service credentials JSON map."
  value       = local.service_credentials_json
  sensitive   = true
}

output "service_credentials_object" {
  description = "The service credentials object."
  value       = local.service_credentials_object
  sensitive   = true
}

output "mirroring_config_id" {
  description = "The ID of the mirroring config in CRN format"
  value       = var.mirroring_enabled ? ibm_event_streams_mirroring_config.es_mirroring_config[0].id : null
}

output "mirroring_topic_patterns" {
  description = "Mirroring topic patterns"
  value       = var.mirroring_enabled ? ibm_event_streams_mirroring_config.es_mirroring_config[0].mirroring_topic_patterns : null
}
