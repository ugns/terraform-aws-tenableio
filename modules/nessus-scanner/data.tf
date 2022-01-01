data "aws_ami" "this" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = [var.product_code[var.license_type]]
  }
}

data "template_file" "user_data" {
  template = file(format("%s/files/user-data.tftpl", path.module))

  vars = {
    license    = var.license_type
    key        = var.linking_key
    name       = coalesce(var.nessus_scanner_name, format("%s Scanner", title(var.name)))
    proxy      = local.nessus_proxy
    proxy_port = local.nessus_proxy_port
    role       = local.iam_role
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

locals {
  nessus_proxy      = var.nessus_proxy != null ? var.nessus_proxy : ""
  nessus_proxy_port = var.nessus_proxy_port != null ? var.nessus_proxy_port : ""
  iam_role          = var.license_type == "preauth" ? aws_iam_role.this.name : ""
}