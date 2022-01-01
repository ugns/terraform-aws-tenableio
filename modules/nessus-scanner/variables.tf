variable "name" {
  description = "Application Name"
  type        = string
  default     = "nessus"
}

variable "license_type" {
  description = "The type of Nessus License to use: byol or preauth"
  type        = string
  default     = "byol"
  validation {
    condition     = var.license_type == "byol" || var.license_type == "preauth"
    error_message = "Sorry, type must be either 'byol' or 'preauth'."
  }
}

variable "product_code" {
  type = map(string)
  default = {
    "byol"    = "8fn69npzmbzcs4blc4583jd0y"
    "preauth" = "4m4uvwtrl5t872c56wb131ttw"
  }
}

variable "vpc_id" {
  description = "The ID of the VPC that Nessus will be deployed to"
  type        = string
}

variable "instance_type" {
  description = "The instance type for scanner. Must meet documented hardware requirements"
  type        = string
  default     = "m5.xlarge"
}

variable "use_spot" {
  description = "Use spot EC2 instance. Default: false"
  type        = bool
  default     = false
}

variable "detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring on scanner instance"
  type        = bool
  default     = true
}

variable "termnation_protection" {
  description = "Enable termination protection on scanner instance"
  type        = bool
  default     = true
}

variable "public_ip_address" {
  description = "Enable public IP address on scanner instance"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "The name of the key pair to use, if required for BYOL scanner."
  type        = string
  default     = null
}

variable "ingress_cidr_blocks" {
  description = "The admin desktop CIDR block. Default: [0.0.0.0/0]"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "subnet_ids" {
  description = "The Subnet IDs"
  type        = list(string)
}

variable "linking_key" {
  description = "Linking key used to register scanner with Tenable.io."
  type        = string
  sensitive   = true
}

variable "nessus_scanner_name" {
  description = "Name of the scanner shown in the Nessus UI"
  type        = string
  default     = null
}

variable "nessus_proxy" {
  description = "FQDN/IP address of proxy, if required."
  type        = string
  default     = null
}

variable "nessus_proxy_port" {
  description = "Port used to connect to proxy, if required."
  type        = number
  default     = null
}