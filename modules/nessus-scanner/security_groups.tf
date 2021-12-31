module "byol_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"
  count   = var.license_type == "byol" ? 1 : 0

  name        = format("%s %s", coalesce(var.nessus_scanner_name, var.name), upper(var.license_type))
  description = format("The Security Group to be applied to scanner within %s", var.vpc_id)
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.ingress_cidr_blocks
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8834
      to_port     = 8834
      protocol    = "tcp"
      description = "HTTPS"
    }
  ]
}

module "preauth_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"
  count   = var.license_type == "preauth" ? 1 : 0

  name        = format("%s %s", coalesce(var.nessus_scanner_name, var.name), upper(var.license_type))
  description = format("The Security Group to be applied to scanner within %s", var.vpc_id)
  vpc_id      = var.vpc_id

  egress_rules = ["all-all"]
}

module "target_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"
  count   = var.license_type == "preauth" ? 1 : 0

  name        = format("%s Target Security Group", coalesce(var.nessus_scanner_name, var.name))
  description = format("The Security Group to be applied to scan targets within %s", var.vpc_id)
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-tcp"
      description              = "Allow all TCP"
      source_security_group_id = local.security_group.security_group_id
    },
    {
      rule                     = "all-udp"
      description              = "Allow all UDP"
      source_security_group_id = local.security_group.security_group_id
    },
    {
      rule                     = "all-icmp"
      description              = "Allow all ICMP"
      source_security_group_id = local.security_group.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 3
}

locals {
  security_group = var.license_type == "byol" ? module.byol_sg[0] : module.preauth_sg[0]
}
