terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.0.0"
    }
  }
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "confluent" {
  cloud_api_key    = var.ccloud_api_key
  cloud_api_secret = var.ccloud_api_secret
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "standard" {
  for_each = local.instance_set

  display_name = "${var.ccloud_cluster_name}-${each.key}"
  availability = var.ccloud_cluster_azs
  cloud        = var.ccloud_cluster_provider
  region       = var.ccloud_cluster_region
  standard {}
  environment {
    id = var.ccloud_environment_id
  }
}

## 'app-manager' service account is required in this configuration to create 'orders' topic and assign roles
## to 'app-producer' and 'app-consumer' service accounts.
resource "confluent_service_account" "app-manager" {
  for_each = local.instance_set

  display_name = "app-manager-${each.key}"
  description  = "Service account to manage 'inventory'-${each.key} Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  for_each = local.instance_set

  principal   = "User:${confluent_service_account.app-manager[each.key].id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard[each.key].rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  for_each = local.instance_set

  display_name = "app-manager-kafka-api-key-${each.key}"
  description  = "Kafka API Key that is owned by 'app-manager'-${each.key} service account"
  owner {
    id          = confluent_service_account.app-manager[each.key].id
    api_version = confluent_service_account.app-manager[each.key].api_version
    kind        = confluent_service_account.app-manager[each.key].kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard[each.key].id
    api_version = confluent_kafka_cluster.standard[each.key].api_version
    kind        = confluent_kafka_cluster.standard[each.key].kind

    environment {
      id = var.ccloud_environment_id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-kafka-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}

resource "confluent_kafka_topic" "orders" {

  for_each = local.instance_set

  kafka_cluster {
    id = confluent_kafka_cluster.standard[each.key].id
  }
  topic_name    = "orders-${each.key}"
  rest_endpoint = confluent_kafka_cluster.standard[each.key].rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key[each.key].id
    secret = confluent_api_key.app-manager-kafka-api-key[each.key].secret
  }
}

resource "confluent_service_account" "app-consumer" {
  for_each = local.instance_set

  display_name = "app-consumer-${each.key}"
  description  = "Service account to consume from 'orders'-${each.key} topic of 'inventory'-${each.key} Kafka cluster"
}

resource "confluent_api_key" "app-consumer-kafka-api-key" {
  for_each = local.instance_set

  display_name = "app-consumer-kafka-api-key-${each.key}"
  description  = "Kafka API Key that is owned by 'app-consumer'-${each.key} service account"
  owner {
    id          = confluent_service_account.app-consumer[each.key].id
    api_version = confluent_service_account.app-consumer[each.key].api_version
    kind        = confluent_service_account.app-consumer[each.key].kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard[each.key].id
    api_version = confluent_kafka_cluster.standard[each.key].api_version
    kind        = confluent_kafka_cluster.standard[each.key].kind

    environment {
      id = var.ccloud_environment_id
    }
  }
}

resource "confluent_service_account" "app-producer" {
  for_each = local.instance_set

  display_name = "app-producer-${each.key}"
  description  = "Service account to produce to 'orders'-${each.key} topic of 'inventory'-${each.key} Kafka cluster"
}

resource "confluent_api_key" "app-producer-kafka-api-key" {

  for_each = local.instance_set
  display_name = "app-producer-kafka-api-key-${each.key}"
  description  = "Kafka API Key that is owned by 'app-producer'-${each.key} service account"
  owner {
    id          = confluent_service_account.app-producer[each.key].id
    api_version = confluent_service_account.app-producer[each.key].api_version
    kind        = confluent_service_account.app-producer[each.key].kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard[each.key].id
    api_version = confluent_kafka_cluster.standard[each.key].api_version
    kind        = confluent_kafka_cluster.standard[each.key].kind

    environment {
      id = var.ccloud_environment_id
    }
  }
}

##### ACLS

resource "confluent_kafka_acl" "app-producer-write-on-topic" {
  for_each = local.instance_set

  kafka_cluster {
    id = confluent_kafka_cluster.standard[each.key].id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.orders[each.key].topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-producer[each.key].id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard[each.key].rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key[each.key].id
    secret = confluent_api_key.app-manager-kafka-api-key[each.key].secret
  }
}

// Note that in order to consume from a topic, the principal of the consumer ('app-consumer' service account)
// needs to be authorized to perform 'READ' operation on both Topic and Group resources:
// confluent_kafka_acl.app-consumer-read-on-topic, confluent_kafka_acl.app-consumer-read-on-group.
// https://docs.confluent.io/platform/current/kafka/authorization.html#using-acls
resource "confluent_kafka_acl" "app-consumer-read-on-topic" {
  for_each = local.instance_set

  kafka_cluster {
    id = confluent_kafka_cluster.standard[each.key].id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.orders[each.key].topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-consumer[each.key].id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard[each.key].rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key[each.key].id
    secret = confluent_api_key.app-manager-kafka-api-key[each.key].secret
  }
}

###### Lab 2: below resource is commented out on purpose, this is the missing permission participants should identify and apply on their own

#resource "confluent_kafka_acl" "app-consumer-read-on-group" {
#  kafka_cluster {
#    id = confluent_kafka_cluster.standard[each.key].id
#  }
#  resource_type = "GROUP"
#  // The existing values of resource_name, pattern_type attributes are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
#  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
#  // Update the values of resource_name, pattern_type attributes to match your target consumer group ID.
#  // https://docs.confluent.io/platform/current/kafka/authorization.html#prefixed-acls
#  resource_name = "confluent_cli_consumer_"
#  pattern_type  = "PREFIXED"
#  principal     = "User:${confluent_service_account.app-consumer[each.key].id}"
#  host          = "*"
#  operation     = "READ"
#  permission    = "ALLOW"
#  rest_endpoint = confluent_kafka_cluster.standard[each.key].rest_endpoint
#  credentials {
#    key    = confluent_api_key.app-manager-kafka-api-key[each.key].id
#    secret = confluent_api_key.app-manager-kafka-api-key[each.key].secret
#  }
#}

