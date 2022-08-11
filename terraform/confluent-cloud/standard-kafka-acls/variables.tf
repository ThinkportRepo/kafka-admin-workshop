variable "ccloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "ccloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
}

variable "ccloud_environment_name" {
  description = "Confluent Cloud Environment Name"
  type        = string
}


variable "ccloud_cluster_name" {
  description = "Confluent Cloud Environment Name"
  type        = string
}

variable "ccloud_cluster_azs" {
  description = "Confluent Cloud Availability Zone Settings"
  type        = string
}

variable "ccloud_cluster_provider" {
  description = "Confluent Cloud Cluster provider"
  type        = string
}

variable "ccloud_cluster_region" {
  description = "Confluent Cloud Cluster region"
  type        = string
}

variable "ccloud_environment_id" {
  description = "Confluent Cloud Environment id"
  type        = string
}
