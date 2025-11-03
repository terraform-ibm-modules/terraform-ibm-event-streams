##############################################################################
# Outputs
##############################################################################

output "id" {
  description = "Event Streams instance id"
  value       = ibm_resource_instance.es_instance.id
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
  value = [
    for i in range(tonumber(ibm_resource_instance.es_instance.extensions["kafka_brokers_sasl.#"])) :
    ibm_resource_instance.es_instance.extensions["kafka_brokers_sasl.${i}"]
  ]
}

output "kafka_http_url" {
  description = "The API endpoint to interact with Event Streams REST API"
  value       = ibm_resource_instance.es_instance.extensions.kafka_http_url
}

output "kafka_broker_version" {
  description = "The Kafka version"
  value       = ibm_resource_instance.es_instance.extensions.kafka_broker_version
}

output "resource_keys" {
  description = "List of resource keys"
  value       = ibm_resource_key.resource_keys
  sensitive   = true
}

output "mirroring_config_id" {
  description = "The ID of the mirroring config in CRN format"
  value       = var.mirroring != null ? ibm_event_streams_mirroring_config.es_mirroring_config[0].id : null
}

output "mirroring_topic_patterns" {
  description = "Mirroring topic patterns"
  value       = var.mirroring != null ? ibm_event_streams_mirroring_config.es_mirroring_config[0].mirroring_topic_patterns : null
}
