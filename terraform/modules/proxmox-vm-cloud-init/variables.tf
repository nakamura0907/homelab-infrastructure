variable "name" {
  description = "Required The name of the VM within Proxmox."
  type        = string
}
variable "target_node" {
  description = "Required The name of the Proxmox Node on which to place the VM."
  type        = string
}
variable "clone_vm_name" {
  description = "The base VM name from which to clone to create the new VM. Note that clone is mutually exclusive with clone_id and pxe modes."
  type        = string
}
variable "vmid" {
  default     = 0
  description = "The ID of the VM in Proxmox. The default value of 0 indicates it should use the next available ID in the sequence."
  type        = number
}
variable "ciuser" {
  default     = null
  description = "Override the default cloud-init user for provisioning."
  type        = string
}
variable "cipassword" {
  default     = null
  description = "Override the default cloud-init user's password. Sensitive."
  type        = string
  sensitive   = true
}
variable "ipconfig" {
  description = "The first IP address to assign to the guest. Format: [gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]. When os_type is cloud-init not setting ip= is equivalent to skip_ipv4 == true and ip6= to skip_ipv6 == true ."
  type        = string
}
variable "nameserver" {
  description = "Sets default DNS server for guest."
  type        = string
}
variable "sshkeys" {
  default     = null
  description = "Newline delimited list of SSH public keys to add to authorized keys file for the cloud-init user."
  type        = string
}
variable "sockets" {
  default     = null
  description = "The number of CPU sockets to allocate to the VM."
  type        = number
}
variable "cores" {
  default     = null
  description = "The number of CPU cores per CPU socket to allocate to the VM."
  type        = number
}
variable "memory" {
  default     = null
  description = "The amount of memory to allocate to the VM in Megabytes."
  type        = string
}
variable "storage_pool" {
  description = "Required when type=disk and passthrough=false. The name of the storage pool on which to store the disk."
  type        = string
}
variable "storage_size" {
  description = "The size of the created disk. Accepts K for kibibytes, M for mebibytes, G for gibibytes, T for tibibytes. When only a number is provided gibibytes is assumed. Required when type=disk and passthrough=false, Computed when type=disk and passthrough=true."
  type        = string
}
variable "add_passthrough" {
  description = "Wether the physical cdrom drive should be passed through."
  type        = bool
  default     = false
}
variable "passthrough_file" {
  description = "Required The full unix file path to the disk."
  type        = string
  default     = null
}
