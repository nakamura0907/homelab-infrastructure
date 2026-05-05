terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_tls_insecure     = var.pm_tls_insecure
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_parallel         = 4
}

provider "proxmox" {
  alias = "rootuser"

  pm_api_url      = var.pm_api_url
  pm_tls_insecure = var.pm_tls_insecure
  pm_user         = var.pm_rootuser
  pm_password     = var.pm_rootpassword
  pm_parallel     = 4
}

