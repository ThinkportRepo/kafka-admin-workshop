# AWS EC2 Instance Terraform Outputs
# Public EC2 Instances - Bastion Host

## ec2_bastion_public_instance_ids
output "ec2_bastion_public_instance_ids" {
  description = "List of IDs of instances"
  value       = { for p in toset(["0", "1"]) : p => module.ec2_public[p].id }
}

## ec2_bastion_public_ip
output "ec2_bastion_eip" {
  description = "Elastic IP associated to the Bastion Host"
  value       = { for p in toset(["0", "1"]) : p => aws_eip.bastion_eip[p].public_ip }
}
