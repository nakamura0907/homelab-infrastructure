
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

  features {
    nesting = var.features_nesting
    keyctl  = var.features_keyctl
  }

  // Terraform will crash without rootfs defined
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = var.network_name
    bridge = var.network_bridge
    ip     = var.network_ip
    gw     = var.network_gw
  }

  // ostemplate と ssh_public_keys は作成時のみ有効かつ API から読み戻されない
  // ForceNew 属性のため、import 済みリソースでは state 上 null となり毎回 replace を
  // 誘発する。差分を無視して既存コンテナの再作成を防ぐ。
  lifecycle {
    ignore_changes = [
      ostemplate,
      ssh_public_keys,
    ]
  }
}
