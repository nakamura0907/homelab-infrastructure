output "name" {
  description = "The name of the VM within Proxmox."
  value       = proxmox_vm_qemu.this.name
}

output "vmid" {
  description = "The ID of the VM in Proxmox."
  value       = proxmox_vm_qemu.this.vmid
}

output "ipconfig" {
  description = "The cloud-init IP configuration applied to the VM."
  value       = proxmox_vm_qemu.this.ipconfig0
}

output "default_ipv4_address" {
  description = "The primary IPv4 address reported by the guest agent (may be empty until the guest boots)."
  value       = proxmox_vm_qemu.this.default_ipv4_address
}
