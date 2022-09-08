output "public_ip" {
  description = "Public IPs of created instances. "
  value       = oci_core_instance.millenium_postgres.public_ip
}
