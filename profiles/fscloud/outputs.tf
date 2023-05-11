##############################################################################
# Outputs
##############################################################################

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
