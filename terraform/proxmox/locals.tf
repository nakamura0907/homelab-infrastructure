locals {
  // ---- QEMU VM 台帳 ----
  // key = Proxmox 上の VM 名。共通設定(clone元/ストレージ/認証など)は variables を参照。
  // use_root_provider = true のノードは pm_user/pm_password(root) プロバイダで管理する。
  vms = {
    "k3s-server-1" = {
      vmid         = 9110
      ip           = "ip=192.168.0.110/24"
      sockets      = 1
      cores        = 4
      memory       = "4096"
      storage_size = "32G"
    }
    "k3s-agent-1" = {
      vmid         = 9111
      ip           = "ip=192.168.0.111/24"
      sockets      = 1
      cores        = 4
      memory       = "4096"
      storage_size = "32G"
    }
    "k3s-agent-2" = {
      vmid         = 9112
      ip           = "ip=192.168.0.112/24"
      sockets      = 1
      cores        = 4
      memory       = "4096"
      storage_size = "32G"
    }
    "k3s-staging-server-1" = {
      vmid         = 9120
      ip           = "ip=192.168.0.120/24"
      sockets      = 1
      cores        = 4
      memory       = "4096"
      storage_size = "32G"
      onboot       = false
      vm_state     = "stopped"
    }
    "openmediavault" = {
      vmid              = 9210
      ip                = "ip=192.168.0.210/24"
      sockets           = 1
      cores             = 1
      memory            = "2048"
      storage_size      = "6G"
      onboot            = false
      vm_state          = "stopped"
      add_passthrough   = true
      passthrough_file  = var.openmediavault_passthrough_file
      use_root_provider = true
    }
  }

  // ---- LXC 台帳 ----
  // key = 論理名 (hostname は個別に指定)。onboot は全ノード true のためモジュール既定に委譲。
  lxcs = {
    "secret-manager" = {
      hostname    = "secret-manager"
      vmid        = 212
      cpuunits    = 1024
      memory      = 1024
      network_ip  = "192.168.0.212/24"
      rootfs_size = "8G"
      swap        = 512
    }
    "monitoring" = {
      hostname         = "monitoring"
      vmid             = 214
      cpuunits         = 2048
      memory           = 2048
      network_ip       = "192.168.0.214/24"
      rootfs_size      = "8G"
      swap             = 512
      features_nesting = true
    }
    "dns" = {
      hostname          = "dns"
      vmid              = 213
      cpuunits          = 1024
      memory            = 1024
      network_ip        = "192.168.0.213/24"
      rootfs_size       = "8G"
      swap              = 512
      features_nesting  = true
      features_keyctl   = true
      use_root_provider = true
    }
    "pki" = {
      hostname   = "ca"
      vmid       = 211
      cpuunits   = 1024
      memory     = 512
      network_ip = "192.168.0.211/24"
      // HTTP-01検証でstep-ca自身がhome.arpa名を解決するため、DNS LXCを優先しルーターへフォールバック
      nameserver  = "192.168.0.213 192.168.0.1"
      rootfs_size = "8G"
      swap        = 512
    }
  }
}
