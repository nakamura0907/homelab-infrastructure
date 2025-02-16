variable "target_node" {
  description = "(required) - A string containing the cluster node name."
  type        = string
}

variable "ostemplate" {
  description = "The volume identifier that points to the OS template or backup file."
  type        = string
  default     = null
}

variable "cmode" {
  description = "Configures console mode. 'tty' tries to open a connection to one of the available tty devices. 'console' tries to attach to /dev/console instead. 'shell' simply invokes a shell inside the container (no login)."
  type        = string
  default     = "shell"
}

variable "cpuunits" {
  description = "A number of the CPU weight that the container possesses."
  type        = number
  default     = null
}

variable "hostname" {
  description = "Specifies the host name of the container."
  type        = string
  default     = null
}

variable "memory" {
  description = "A number containing the amount of RAM to assign to the container (in MB)."
  type        = number
  default     = null
}

variable "network_name" {
  description = "(required) - The name of the network interface as seen from inside the container."
  type        = string
  default     = "eth0"
}

variable "network_bridge" {
  description = "The bridge to attach the network interface to."
  type        = string
  default     = "vmbr0"
}

variable "network_firewall" {
  description = "A boolean to enable the firewall on the network interface."
  type        = bool
  default     = true
}

variable "network_ip" {
  description = "The IPv4 address of the network interface. Can be a static IPv4 address (in CIDR notation), 'dhcp', or 'manual'."
  type        = string
  default     = "dhcp"
}

variable "onboot" {
  description = "A boolean that determines if the container will start on boot."
  type        = bool
  default     = null
}

variable "password" {
  description = "Sets the root password inside the container."
  type        = string
  default     = null
}

variable "rootfs_size" {
  description = "Size of the underlying volume. Must end in T, G, M, or K (e.g. '1T', '1G', '1024M' , '1048576K'). Note that this is a read only value."
  type        = string
  default     = "4G"
}

variable "rootfs_storage" {
  description = "A string containing the volume , directory, or device to be mounted into the container (at the path specified by mp). E.g. local-lvm, local-zfs, local etc."
  type        = string
  default     = "local-lvm"
}

variable "ssh_public_keys" {
  description = "Multi-line string of SSH public keys that will be added to the container. Can be defined using heredoc syntax."
  type        = string
  default     = null
}

variable "start" {
  description = "A boolean that determines if the container is started after creation."
  type        = bool
  default     = true
}

variable "swap" {
  description = "A number that sets the amount of swap memory available to the container."
  type        = number
  default     = 0
}

variable "vmid" {
  description = "A number that sets the VMID of the container. If set to 0, the next available VMID is used."
  type        = number
  default     = null
}