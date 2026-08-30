// ---- QEMU VM ----
// API トークンで管理する VM 群
module "vm" {
  source   = "./modules/proxmox-vm-cloud-init"
  for_each = { for name, vm in local.vms : name => vm if !try(vm.use_root_provider, false) }

  name        = each.key
  target_node = var.target_node

  clone_vm_name = var.clone_vm_name
  vmid          = each.value.vmid

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ipconfig   = "${each.value.ip},${var.ipconfig_gw}"
  nameserver = var.nameserver
  sshkeys    = var.sshkeys

  sockets = each.value.sockets
  cores   = each.value.cores
  memory  = each.value.memory

  onboot   = try(each.value.onboot, true)
  vm_state = try(each.value.vm_state, null)

  storage_pool = var.storage_pool
  storage_size = each.value.storage_size

  add_passthrough  = try(each.value.add_passthrough, false)
  passthrough_file = try(each.value.passthrough_file, null)
}

// pm_user/pm_password(root) で管理する VM 群
// (物理ディスク passthrough 等で API トークンの権限が不足するため root プロバイダを使用)
module "vm_rootuser" {
  source   = "./modules/proxmox-vm-cloud-init"
  for_each = { for name, vm in local.vms : name => vm if try(vm.use_root_provider, false) }

  providers = {
    proxmox = proxmox.rootuser
  }

  name        = each.key
  target_node = var.target_node

  clone_vm_name = var.clone_vm_name
  vmid          = each.value.vmid

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ipconfig   = "${each.value.ip},${var.ipconfig_gw}"
  nameserver = var.nameserver
  sshkeys    = var.sshkeys

  sockets = each.value.sockets
  cores   = each.value.cores
  memory  = each.value.memory

  onboot   = try(each.value.onboot, true)
  vm_state = try(each.value.vm_state, null)

  storage_pool = var.storage_pool
  storage_size = each.value.storage_size

  add_passthrough  = try(each.value.add_passthrough, false)
  passthrough_file = try(each.value.passthrough_file, null)
}

// ---- LXC ----
// API トークンで管理する LXC 群
module "lxc" {
  source   = "./modules/proxmox-lxc"
  for_each = { for name, c in local.lxcs : name => c if !try(c.use_root_provider, false) }

  target_node = var.target_node

  ostemplate      = var.lxc_ostemplate
  cpuunits        = each.value.cpuunits
  hostname        = each.value.hostname
  memory          = each.value.memory
  onboot          = try(each.value.onboot, true)
  network_ip      = each.value.network_ip
  network_gw      = var.lxc_gw
  rootfs_size     = each.value.rootfs_size
  ssh_public_keys = var.sshkeys
  swap            = try(each.value.swap, 512)
  vmid            = each.value.vmid

  nameserver       = try(each.value.nameserver, null)
  features_nesting = try(each.value.features_nesting, false)
  features_keyctl  = try(each.value.features_keyctl, false)
}

// pm_user/pm_password(root) で管理する LXC 群
module "lxc_rootuser" {
  source   = "./modules/proxmox-lxc"
  for_each = { for name, c in local.lxcs : name => c if try(c.use_root_provider, false) }

  providers = {
    proxmox = proxmox.rootuser
  }

  target_node = var.target_node

  ostemplate      = var.lxc_ostemplate
  cpuunits        = each.value.cpuunits
  hostname        = each.value.hostname
  memory          = each.value.memory
  onboot          = try(each.value.onboot, true)
  network_ip      = each.value.network_ip
  network_gw      = var.lxc_gw
  rootfs_size     = each.value.rootfs_size
  ssh_public_keys = var.sshkeys
  swap            = try(each.value.swap, 512)
  vmid            = each.value.vmid

  nameserver       = try(each.value.nameserver, null)
  features_nesting = try(each.value.features_nesting, false)
  features_keyctl  = try(each.value.features_keyctl, false)
}
