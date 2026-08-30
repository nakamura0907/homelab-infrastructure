// tfvars (機密情報・環境固有値。デフォルト無しの変数は tfvars で必須)
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

// Proxmox 共通設定
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
variable "lxc_gw" {
  type    = string
  default = "192.168.0.1"
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
