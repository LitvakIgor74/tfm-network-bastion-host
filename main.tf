terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.25.0"
    }
  }
}


# ----------------------------------------------------------------------------- locals
locals {
  dependent_bastion_asg_name = "${substr(aws_launch_configuration.bastion_lc.name, 0, length(aws_launch_configuration.bastion_lc.name) - 3)}-asg"
  all_ips_cidr_block = "0.0.0.0/0"
}


# ----------------------------------------------------------------------------- bastion host
resource "aws_autoscaling_group" "bastion_asg" {
  name = local.dependent_bastion_asg_name
  vpc_zone_identifier = var.vpc_public_snet_list
  min_size = 1
  max_size = 1
  launch_configuration = aws_launch_configuration.bastion_lc.name
  tag {
    key = "Name"
    value = local.dependent_bastion_asg_name
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "bastion_lc" {
  name = "${var.vpc_elevel_name_prefix}-bastion-lc"
  instance_type = var.bastion_instance_type
  image_id = var.bastion_image_id
  security_groups = [aws_security_group.bastion_sg.id]
  key_name = aws_key_pair.bastion_key_pair.key_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "${var.vpc_elevel_name_prefix}-bastion-key-pair"
  public_key = file("${path.root}/${var.bastion_public_key_file_path}")
  tags = {Name = "${var.vpc_elevel_name_prefix}-bastion-key-pair"}
}

resource "aws_security_group" "bastion_sg" {
  name = "${var.vpc_elevel_name_prefix}-bastion-sg"
  vpc_id = var.vpc_id
  tags = {Name = "${var.vpc_elevel_name_prefix}-bastion-sg"}
}

resource "aws_security_group_rule" "bastion_sg_ingress" {
  security_group_id = aws_security_group.bastion_sg.id 
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [local.all_ips_cidr_block]
}

resource "aws_security_group_rule" "bastion_sg_egress" {
  security_group_id = aws_security_group.bastion_sg.id 
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [local.all_ips_cidr_block]
}