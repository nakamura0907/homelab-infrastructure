// QEMU VM の一覧 (Ansible インベントリ等での利用を想定)
output "virtual_machines" {
  description = "Map of managed QEMU VMs keyed by VM name."
  value = merge(
    { for name, m in module.vm : name => { name = m.name, vmid = m.vmid, ipconfig = m.ipconfig } },
    { for name, m in module.vm_rootuser : name => { name = m.name, vmid = m.vmid, ipconfig = m.ipconfig } },
  )
}

// LXC コンテナの一覧
output "containers" {
  description = "Map of managed LXC containers keyed by logical name."
  value = merge(
    { for name, m in module.lxc : name => { hostname = m.hostname, vmid = m.vmid, network_ip = m.network_ip } },
    { for name, m in module.lxc_rootuser : name => { hostname = m.hostname, vmid = m.vmid, network_ip = m.network_ip } },
  )
}
