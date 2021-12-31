output "nessus_scanner_security_group" {
  description = "Nessus scanner security group"
  value       = local.security_group.security_group_id
}

output "nessus_target_security_group" {
  description = "Nessus scan target security group"
  value       = var.license_type == "preauth" ? module.target_sg[0].security_group_id : null
}
