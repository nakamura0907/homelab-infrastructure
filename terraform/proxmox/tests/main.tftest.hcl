// proxmox プロバイダをモックし、実インフラに接続せず plan の結果を検証する。
// 台帳(locals)と for_each の配線・プロバイダ別分割が意図通りかを担保する。
mock_provider "proxmox" {}
mock_provider "proxmox" {
  alias = "rootuser"
}

// デフォルト値の無い変数をテスト用に充足する
variables {
  pm_api_url                      = "https://pve.example:8006/api2/json"
  pm_tls_insecure                 = true
  pm_api_token_id                 = "test@pam!token"
  pm_api_token_secret             = "secret"
  pm_rootuser                     = "root@pam"
  pm_rootpassword                 = "password"
  cipassword                      = "password"
  openmediavault_passthrough_file = "/dev/disk/by-id/test"
  sshkeys                         = "ssh-ed25519 AAAA test"
}

run "provider_split_counts" {
  command = plan

  assert {
    condition     = length(module.vm) == 4
    error_message = "API トークンで管理する VM は 4 台であるべき"
  }
  assert {
    condition     = length(module.vm_rootuser) == 1
    error_message = "root プロバイダで管理する VM は 1 台 (openmediavault) であるべき"
  }
  assert {
    condition     = length(module.lxc) == 3
    error_message = "API トークンで管理する LXC は 3 台であるべき"
  }
  assert {
    condition     = length(module.lxc_rootuser) == 1
    error_message = "root プロバイダで管理する LXC は 1 台 (dns) であるべき"
  }
}

run "outputs_reflect_inventory" {
  command = plan

  assert {
    condition     = length(output.virtual_machines) == 5
    error_message = "virtual_machines 出力は VM 全 5 台を含むべき"
  }
  assert {
    condition     = length(output.containers) == 4
    error_message = "containers 出力は LXC 全 4 台を含むべき"
  }
  assert {
    condition     = output.virtual_machines["k3s-server-1"].vmid == 9110
    error_message = "k3s-server-1 の vmid は台帳の 9110 と一致すべき"
  }
  assert {
    condition     = output.virtual_machines["openmediavault"].vmid == 9210
    error_message = "openmediavault の vmid は台帳の 9210 と一致すべき"
  }
  assert {
    condition     = output.containers["pki"].hostname == "ca"
    error_message = "pki コンテナの hostname は 'ca' であるべき"
  }
  assert {
    condition     = output.containers["dns"].vmid == 213
    error_message = "dns コンテナの vmid は台帳の 213 と一致すべき"
  }
}
