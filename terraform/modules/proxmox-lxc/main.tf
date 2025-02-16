
resource "proxmox_lxc" "this" {
  target_node = var.target_node

  ostemplate      = var.ostemplate
  cmode           = var.cmode
  cpuunits        = var.cpuunits
  hostname        = var.hostname
  memory          = var.memory
  onboot          = var.onboot
  password        = var.password
  ssh_public_keys = var.ssh_public_keys
  start           = var.start
  swap            = var.swap
  unprivileged    = true
  vmid            = var.vmid

  // Terraform will crash without rootfs defined
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = var.network_name
    bridge = var.network_bridge
    ip     = var.network_ip
  }
}