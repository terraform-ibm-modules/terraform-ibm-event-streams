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
  value       = length(ibm_event_streams_topic.es_topic) > 0 ? ibm_event_streams_topic.es_topic[0].kafka_brokers_sasl : null
}

output "kafka_http_url" {
  description = "The API endpoint to interact with Event Streams REST API"
  value       = ibm_resource_instance.es_instance.extensions.kafka_http_url
}
