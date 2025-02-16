// k3s_server
module "k3s_server_1" {
  source = "../../modules/proxmox-vm-cloud-init"

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
  source = "../../modules/proxmox-vm-cloud-init"

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
  source = "../../modules/proxmox-vm-cloud-init"

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
  source = "../../modules/proxmox-vm-cloud-init"

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

  storage_pool = var.storage_pool
  storage_size = var.k3s_agent_storage_size
}

// NAS
module "openmediavault" {
  source = "../../modules/proxmox-vm-cloud-init"

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

  storage_pool = var.storage_pool
  storage_size = var.openmediavault_storage_size

  add_passthrough  = true
  passthrough_file = var.openmediavault_passthrough_file
}

// Secret Manager
module "secret_manager" {
  source = "../../modules/proxmox-lxc"

  target_node = var.target_node

  ostemplate  = var.lxc_ostemplate
  cpuunits    = var.secret_manager_cpuunits
  hostname    = var.secret_manager_hostname
  memory      = var.secret_manager_memory
  network_ip  = var.secret_manager_network_ip
  rootfs_size = var.secret_manager_rootfs_size
  swap        = var.secret_manager_swap
  vmid        = var.secret_manager_vmid
}
resource "null_resource" "configure_lxc" {
  depends_on = [module.secret_manager]

  provisioner "local-exec" {
    environment = {
      PM_API_URL = var.pm_api_url
      NODE       = var.target_node
      VMID       = var.secret_manager_vmid
      TOKEN      = "${var.pm_api_token_id}=${var.pm_api_token_secret}"
    }
    command = <<EOT
        curl -k -X PUT "$PM_API_URL/nodes/$NODE/lxc/$VMID/config" \
            -H "Authorization: PVEAPIToken=$TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"onboot": 1}'

        curl -k -X POST "$PM_API_URL/nodes/$NODE/lxc/$VMID/status/start" \
            -H "Authorization: PVEAPIToken=$TOKEN"
    EOT
  }
}

// development
