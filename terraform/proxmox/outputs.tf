// QEMU VM の一覧 (Ansible インベントリ等での利用を想定)
output "virtual_machines" {
  description = "Map of managed QEMU VMs keyed by logical name."
  value = {
    k3s_server_1         = { name = module.k3s_server_1.name, vmid = module.k3s_server_1.vmid, ipconfig = module.k3s_server_1.ipconfig }
    k3s_agent_1          = { name = module.k3s_agent_1.name, vmid = module.k3s_agent_1.vmid, ipconfig = module.k3s_agent_1.ipconfig }
    k3s_agent_2          = { name = module.k3s_agent_2.name, vmid = module.k3s_agent_2.vmid, ipconfig = module.k3s_agent_2.ipconfig }
    k3s_staging_server_1 = { name = module.k3s_staging_server_1.name, vmid = module.k3s_staging_server_1.vmid, ipconfig = module.k3s_staging_server_1.ipconfig }
    openmediavault       = { name = module.openmediavault.name, vmid = module.openmediavault.vmid, ipconfig = module.openmediavault.ipconfig }
  }
}

// LXC コンテナの一覧
output "containers" {
  description = "Map of managed LXC containers keyed by logical name."
  value = {
    secret_manager = { hostname = module.secret_manager.hostname, vmid = module.secret_manager.vmid, network_ip = module.secret_manager.network_ip }
    monitoring     = { hostname = module.monitoring.hostname, vmid = module.monitoring.vmid, network_ip = module.monitoring.network_ip }
    dns            = { hostname = module.dns.hostname, vmid = module.dns.vmid, network_ip = module.dns.network_ip }
    pki            = { hostname = module.pki.hostname, vmid = module.pki.vmid, network_ip = module.pki.network_ip }
  }
}
