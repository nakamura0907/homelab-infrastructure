// k3s_server
module "k3s_server_1" {
  source = "./modules/proxmox-vm-cloud-init"

  name        = var.k3s_server_1_name
  target_node = var.target_node

  clone_vm_name = var.clone_vm_name
  vmid          = var.k3s_server_1_vmid

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ipconfig   = "${var.k3s_server_1_ipconfig},${var.ipconfig_gw}"
  nameserver = var.nameserver
  sshkeys    = var.sshkeys

  sockets = var.k3s_server_sockets
  cores   = var.k3s_server_cores
  memory  = var.k3s_server_memory

  storage_pool = var.storage_pool
  storage_size = var.k3s_server_storage_size
}

// k3s_agent
module "k3s_agent_1" {
  source = "./modules/proxmox-vm-cloud-init"

  name        = var.k3s_agent_1_name
  target_node = var.target_node

  clone_vm_name = var.clone_vm_name
  vmid          = var.k3s_agent_1_vmid

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ipconfig   = "${var.k3s_agent_1_ipconfig},${var.ipconfig_gw}"
  nameserver = var.nameserver
  sshkeys    = var.sshkeys

  sockets = var.k3s_agent_sockets
  cores   = var.k3s_agent_cores
  memory  = var.k3s_agent_memory

  storage_pool = var.storage_pool
  storage_size = var.k3s_agent_storage_size
}

module "k3s_agent_2" {
  source = "./modules/proxmox-vm-cloud-init"

  name        = var.k3s_agent_2_name
  target_node = var.target_node

  clone_vm_name = var.clone_vm_name
  vmid          = var.k3s_agent_2_vmid

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ipconfig   = "${var.k3s_agent_2_ipconfig},${var.ipconfig_gw}"
  nameserver = var.nameserver
  sshkeys    = var.sshkeys

  sockets = var.k3s_agent_sockets
  cores   = var.k3s_agent_cores
  memory  = var.k3s_agent_memory

  storage_pool = var.storage_pool
  storage_size = var.k3s_agent_storage_size
}

// k3s_staging
module "k3s_staging_server_1" {
  source = "./modules/proxmox-vm-cloud-init"

  name        = var.k3s_staging_server_1_name
  target_node = var.target_node

  clone_vm_name = var.clone_vm_name
  vmid          = var.k3s_staging_server_1_vmid

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ipconfig   = "${var.k3s_staging_server_1_ipconfig},${var.ipconfig_gw}"
  nameserver = var.nameserver
  sshkeys    = var.sshkeys

  sockets = var.k3s_agent_sockets
  cores   = var.k3s_agent_cores
  memory  = var.k3s_agent_memory

  onboot   = var.k3s_staging_server_1_onboot
  vm_state = var.k3s_staging_server_1_vm_state

  storage_pool = var.storage_pool
  storage_size = var.k3s_agent_storage_size
}

// NAS
module "openmediavault" {
  source = "./modules/proxmox-vm-cloud-init"

  providers = {
    proxmox = proxmox.rootuser
  }

  name        = var.openmediavault_name
  target_node = var.target_node

  clone_vm_name = var.clone_vm_name
  vmid          = var.openmediavault_vmid

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ipconfig   = "${var.openmediavault_ipconfig},${var.ipconfig_gw}"
  nameserver = var.nameserver
  sshkeys    = var.sshkeys

  sockets = var.openmediavault_sockets
  cores   = var.openmediavault_cores
  memory  = var.openmediavault_memory

  onboot   = var.openmediavault_onboot
  vm_state = var.openmediavault_vm_state

  storage_pool = var.storage_pool
  storage_size = var.openmediavault_storage_size

  add_passthrough  = true
  passthrough_file = var.openmediavault_passthrough_file
}

// monitoring
module "monitoring" {
  source = "./modules/proxmox-lxc"

  target_node = var.target_node

  ostemplate      = var.lxc_ostemplate
  cpuunits        = var.monitoring_cpuunits
  hostname        = var.monitoring_hostname
  memory          = var.monitoring_memory
  onboot          = var.monitoring_onboot
  network_ip      = var.monitoring_network_ip
  network_gw      = var.lxc_gw
  rootfs_size     = var.monitoring_rootfs_size
  ssh_public_keys = var.sshkeys
  swap            = var.monitoring_swap
  vmid            = var.monitoring_vmid

  features_nesting = true
}
// local-exec不要で作成後の起動ができるようになったため削除

// DNS (Pi-hole + Unbound)
module "dns" {
  source = "./modules/proxmox-lxc"

  providers = {
    proxmox = proxmox.rootuser
  }

  target_node = var.target_node

  ostemplate      = var.lxc_ostemplate
  cpuunits        = var.dns_cpuunits
  hostname        = var.dns_hostname
  memory          = var.dns_memory
  onboot          = var.dns_onboot
  network_ip      = var.dns_network_ip
  network_gw      = var.lxc_gw
  rootfs_size     = var.dns_rootfs_size
  ssh_public_keys = var.sshkeys
  swap            = var.dns_swap
  vmid            = var.dns_vmid

  features_nesting = true
  features_keyctl  = true
}

// PKI (step-ca 内部CA)
module "pki" {
  source = "./modules/proxmox-lxc"

  target_node = var.target_node

  ostemplate      = var.lxc_ostemplate
  cpuunits        = var.pki_cpuunits
  hostname        = var.pki_hostname
  memory          = var.pki_memory
  onboot          = var.pki_onboot
  network_ip      = var.pki_network_ip
  network_gw      = var.lxc_gw
  rootfs_size     = var.pki_rootfs_size
  ssh_public_keys = var.sshkeys
  swap            = var.pki_swap
  vmid            = var.pki_vmid

  // HTTP-01検証でstep-ca自身がhome.arpa名を解決するため、DNS LXCを優先しルーターへフォールバック
  nameserver = var.pki_nameserver
}
