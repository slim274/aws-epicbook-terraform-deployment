
variable "db_password" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  description = "Public SSH key for EC2 access"
  type        = string
}
