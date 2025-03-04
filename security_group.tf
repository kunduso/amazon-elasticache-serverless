#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "custom_sg" {
  name        = "${var.name}_allow_inbound_access"
  description = "manage traffic for ${var.name}"
  vpc_id      = module.vpc.vpc.id
  tags = {
    "Name" = "${var.name}-sg"
  }
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #This security group is attached to the Amazon ElastiCache Serverless resource
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_custom_sg" {
  description       = "allow traffic to the cache cluster"
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.custom_sg.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress_custom_sg" {
  description       = "allow traffic to reach outside the vpc"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.custom_sg.id
}