// 個別モジュールから for_each ベースのモジュールへ state アドレスを移動する。
// これにより既存リソースの破棄/再作成を防ぐ (plan が no-op になることを1台ずつ確認すること)。

// ---- QEMU VM ----
moved {
  from = module.k3s_server_1.proxmox_vm_qemu.this
  to   = module.vm["k3s-server-1"].proxmox_vm_qemu.this
}
moved {
  from = module.k3s_agent_1.proxmox_vm_qemu.this
  to   = module.vm["k3s-agent-1"].proxmox_vm_qemu.this
}
moved {
  from = module.k3s_agent_2.proxmox_vm_qemu.this
  to   = module.vm["k3s-agent-2"].proxmox_vm_qemu.this
}
moved {
  from = module.k3s_staging_server_1.proxmox_vm_qemu.this
  to   = module.vm["k3s-staging-server-1"].proxmox_vm_qemu.this
}
moved {
  from = module.openmediavault.proxmox_vm_qemu.this
  to   = module.vm_rootuser["openmediavault"].proxmox_vm_qemu.this
}

// ---- LXC ----
moved {
  from = module.secret_manager.proxmox_lxc.this
  to   = module.lxc["secret-manager"].proxmox_lxc.this
}
moved {
  from = module.monitoring.proxmox_lxc.this
  to   = module.lxc["monitoring"].proxmox_lxc.this
}
moved {
  from = module.pki.proxmox_lxc.this
  to   = module.lxc["pki"].proxmox_lxc.this
}
moved {
  from = module.dns.proxmox_lxc.this
  to   = module.lxc_rootuser["dns"].proxmox_lxc.this
}
