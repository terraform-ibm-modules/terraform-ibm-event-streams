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
  description = "(Array of Strings) Kafka brokers used for interacting with Kafka native API. For classic instances, returns the broker list from extensions. For enterprise-gen2, returns the brokers parsed from the `dataservices.connection.bootstrap_servers` extension."
  value = local.is_gen2 ? (
    try(split(",", ibm_resource_instance.es_instance.extensions["dataservices.connection.bootstrap_servers"]), null)
    ) : try(
    [
      for i in range(tonumber(ibm_resource_instance.es_instance.extensions["kafka_brokers_sasl.#"])) :
      ibm_resource_instance.es_instance.extensions["kafka_brokers_sasl.${i}"]
    ],
    null
  )
}

output "kafka_http_url" {
  description = "The API endpoint to interact with Event Streams REST API. For enterprise-gen2, returns the `dataservices.connection.rest_url` extension value."
  value = local.is_gen2 ? (
    try(ibm_resource_instance.es_instance.extensions["dataservices.connection.rest_url"], null)
  ) : try(ibm_resource_instance.es_instance.extensions.kafka_http_url, null)
}

output "kafka_broker_version" {
  description = "The Kafka version. For enterprise-gen2, returns the `dataservices.kafka.version` extension value."
  value = local.is_gen2 ? (
    try(ibm_resource_instance.es_instance.extensions["dataservices.kafka.version"], null)
  ) : try(ibm_resource_instance.es_instance.extensions.kafka_broker_version, null)
}

output "resource_keys" {
  description = "List of resource keys"
  value       = ibm_resource_key.service_credentials
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
