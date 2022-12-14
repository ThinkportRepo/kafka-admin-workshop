# Create Elastic IP for Bastion Host
# Resource - depends_on Meta-Argument
resource "aws_eip" "bastion_eip" {
  depends_on = [module.ec2_public, module.vpc ]
  for_each = local.instance_set

  instance = module.ec2_public[each.key].id
  vpc      = true
  tags = local.common_tags  
}
