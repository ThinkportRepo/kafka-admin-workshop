  
# AWS EC2 Instance Terraform Variables

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key pair that needs to be associated with EC2 Instance"
  type = string
}
