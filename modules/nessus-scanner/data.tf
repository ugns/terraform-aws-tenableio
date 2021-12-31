data "aws_ami" "this" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = [var.product_code[var.license_type]]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/files/user-data.tftpl")

  vars = {
    license    = var.license_type
    key        = var.linking_key
    name       = coalesce(var.nessus_scanner_name, format("%s Scanner", title(var.name)))
    proxy      = var.nessus_proxy != null ? var.nessus_proxy : ""
    proxy_port = var.nessus_proxy_port != null ? var.nessus_proxy_port : ""
    role       = "iam-role-tbd"
  }
}
