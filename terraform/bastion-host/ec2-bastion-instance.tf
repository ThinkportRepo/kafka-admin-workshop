# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.1"
  for_each = toset(["0", "1"])

  name                   = "ccloud-bastion-host-${each.key}"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  subnet_id              = module.vpc.public_subnets[each.value]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  user_data              = "${file("scripts/init.sh")}"
  
  tags = local.common_tags
}