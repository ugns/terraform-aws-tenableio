module "scanner" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "3.3.0"
  for_each = toset(var.subnet_ids)

  name = format("%s %s", coalesce(var.nessus_scanner_name, var.name), upper(var.license_type))

  create_spot_instance                 = var.use_spot
  spot_type                            = "persistent"
  spot_instance_interruption_behavior  = "stop"
  spot_wait_for_fulfillment            = true
  instance_initiated_shutdown_behavior = "stop"

  ami                         = data.aws_ami.this.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = var.detailed_monitoring
  vpc_security_group_ids      = var.license_type == "byol" ? [module.byol_sg[0].security_group_id] : [module.preauth_sg[0].security_group_id]
  subnet_id                   = each.key
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = var.public_ip_address
  disable_api_termination     = var.termnation_protection

  metadata_options = {
    http_tokens = "required"
  }
}
