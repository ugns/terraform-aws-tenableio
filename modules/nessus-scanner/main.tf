module "nessus_scanner" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "3.3.0"
  for_each = toset(var.subnet_ids)

  name = format("%s %s", coalesce(var.nessus_scanner_name, var.name), local.license_type[var.license_type])

  create_spot_instance                 = var.use_spot
  spot_type                            = "persistent"
  spot_instance_interruption_behavior  = "stop"
  spot_wait_for_fulfillment            = true
  instance_initiated_shutdown_behavior = "stop"

  ami                         = data.aws_ami.this.id
  instance_type               = var.instance_type
  iam_instance_profile        = local.iam_instance_profile
  key_name                    = local.key_name
  monitoring                  = var.detailed_monitoring
  vpc_security_group_ids      = local.vpc_security_group_ids
  subnet_id                   = each.key
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = var.public_ip_address
  disable_api_termination     = var.termination_protection
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = format("%s-", var.name)
  role        = aws_iam_role.this.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "this" {
  name_prefix        = format("%s-", var.name)
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ]

  lifecycle {
    ignore_changes = [
      tags,
    ]
    create_before_destroy = true
  }
}

locals {
  iam_instance_profile   = var.license_type == "preauth" ? aws_iam_instance_profile.this.name : null
  key_name               = var.license_type == "byol" ? var.key_name : null
  vpc_security_group_ids = var.license_type == "byol" ? [module.byol_security_group[0].security_group_id] : [module.preauth_security_group[0].security_group_id]
  license_type = {
    "byol"    = "BYOL"
    "preauth" = "Pre-Authorized"
  }
}