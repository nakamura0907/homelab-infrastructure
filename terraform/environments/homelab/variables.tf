// tfvars
variable "pm_api_url" {
  type = string
}
variable "pm_tls_insecure" {
  type = bool
}
variable "pm_api_token_id" {
  type      = string
  sensitive = true
}
variable "pm_api_token_secret" {
  type      = string
  sensitive = true
}
variable "openmediavault_passthrough_file" {
  type = string
}
variable "pm_rootuser" {
  type = string
}
variable "pm_rootpassword" {
  type      = string
  sensitive = true
}

// Proxmox
variable "target_node" {
  type    = string
  default = "pve"
}
variable "clone_vm_name" {
  type    = string
  default = "debian-template"
}
variable "ciuser" {
  type    = string
  default = "root"
}
variable "cipassword" {
  type      = string
  sensitive = true
}
variable "ipconfig_gw" {
  type    = string
  default = "gw=192.168.0.1"
}
variable "nameserver" {
  type    = string
  default = "192.168.0.1"
}
variable "sshkeys" {
  default = null
  type    = string
}
variable "storage_pool" {
  type    = string
  default = "local-lvm"
}
variable "lxc_ostemplate" {
  type    = string
  default = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
}

// k3s_server_
variable "k3s_server_sockets" {
  type    = number
  default = 1
}
variable "k3s_server_cores" {
  type    = number
  default = 4
}
variable "k3s_server_memory" {
  type    = string
  default = "4096"
}
variable "k3s_server_storage_size" {
  type    = string
  default = "32G"
}
// k3s_agent_
variable "k3s_agent_sockets" {
  type    = number
  default = 1
}
variable "k3s_agent_cores" {
  type    = number
  default = 4
}
variable "k3s_agent_memory" {
  type    = string
  default = "4096"
}
variable "k3s_agent_storage_size" {
  type    = string
  default = "32G"
}

// リソース別
variable "k3s_server_1_name" {
  type    = string
  default = "k3s-server-1"
}
variable "k3s_server_1_vmid" {
  type    = number
  default = 9110
}
variable "k3s_server_1_ipconfig" {
  type    = string
  default = "ip=192.168.0.110/24"
}

variable "k3s_agent_1_name" {
  type    = string
  default = "k3s-agent-1"
}
variable "k3s_agent_1_vmid" {
  type    = number
  default = 9111
}
variable "k3s_agent_1_ipconfig" {
  type    = string
  default = "ip=192.168.0.111/24"
}

variable "k3s_agent_2_name" {
  type    = string
  default = "k3s-agent-2"
}
variable "k3s_agent_2_vmid" {
  type    = number
  default = 9112
}
variable "k3s_agent_2_ipconfig" {
  type    = string
  default = "ip=192.168.0.112/24"
}

variable "k3s_staging_server_1_name" {
  type    = string
  default = "k3s-staging-server-1"
}
variable "k3s_staging_server_1_vmid" {
  type    = number
  default = 9120
}
variable "k3s_staging_server_1_ipconfig" {
  type    = string
  default = "ip=192.168.0.120/24"
}

variable "openmediavault_name" {
  type    = string
  default = "openmediavault"
}
variable "openmediavault_vmid" {
  type    = number
  default = 9210
}
variable "openmediavault_ipconfig" {
  type    = string
  default = "ip=192.168.0.210/24"
}
variable "openmediavault_sockets" {
  type    = number
  default = 1
}
variable "openmediavault_cores" {
  type    = number
  default = 1
}
variable "openmediavault_memory" {
  type    = number
  default = 2048
}
variable "openmediavault_storage_size" {
  type    = string
  default = "6G"
}

// LXC - Secret Manager
variable "secret_manager_cpuunits" {
  type    = number
  default = 1024
}
variable "secret_manager_hostname" {
  type    = string
  default = "secret-manager"
}
variable "secret_manager_memory" {
  type    = number
  default = 1024
}
variable "secret_manager_network_ip" {
  type    = string
  default = "192.168.0.212/24"
}
variable "secret_manager_rootfs_size" {
  type    = string
  default = "8G"
}
variable "secret_manager_swap" {
  type    = number
  default = 512
}
variable "secret_manager_vmid" {
  type    = number
  default = 212
}
