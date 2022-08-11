# Define Local Values in Terraform
locals {
  common_tags = {
    Project = "Kafka-Admin-Workshop"
    Owner   = "Timea Magyar"
  }
  instance_set = toset(["0", "1", "2"])

} 