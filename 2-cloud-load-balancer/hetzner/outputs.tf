output "controller_pip" {
  value       = hcloud_server.controller.ipv4_address
  description = "Controller Server IP"
}