output "hostname" {
  description = "The host name of the container."
  value       = proxmox_lxc.this.hostname
}

output "vmid" {
  description = "The VMID of the container."
  value       = proxmox_lxc.this.vmid
}

output "network_ip" {
  description = "The IPv4 address (CIDR) configured on the container's primary interface."
  value       = var.network_ip
}
