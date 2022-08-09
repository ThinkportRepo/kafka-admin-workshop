output "app-manager-api-keys" {
  description = "App Manager Kafka API Keys"
  value = { for p in local.instance_set : p => confluent_api_key.app-manager-kafka-api-key[p].id }
  sensitive = true
}

output "app-consumer-api-keys" {
  description = "App Consumer Kafka API Keys"
  value = { for p in local.instance_set : p => confluent_api_key.app-consumer-kafka-api-key[p].id }
  sensitive = true
}

output "app-producer-api-keys" {
  description = "App Consumer Kafka API Keys"
  value = { for p in local.instance_set : p => confluent_api_key.app-producer-kafka-api-key[p].id }
  sensitive = true
}

output "app-manager-api-secrets" {
  description = "App Manager Kafka API Secrets"
  value = { for p in local.instance_set : p => confluent_api_key.app-manager-kafka-api-key[p].secret }
  sensitive = true
}

output "app-consumer-api-secrets" {
  description = "App Consumer Kafka API Secrets"
  value = { for p in local.instance_set : p => confluent_api_key.app-consumer-kafka-api-key[p].secret }
  sensitive = true
}

output "app-producer-api-secrets" {
  description = "App Consumer Kafka API Secrets"
  value = { for p in local.instance_set : p => confluent_api_key.app-producer-kafka-api-key[p].secret }
  sensitive = true
}

output "confluent-kafka-topics" {
  description = "Orders topic"
  value = { for p in local.instance_set : p => confluent_kafka_topic.orders[p] }
  sensitive = true
}
