resource "proxmox_lxc" "this" {
  target_node = var.target_node
  hostname    = var.hostname
  clone       = var.clone
}