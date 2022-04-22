packer {
  required_plugins {
    hyperv = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

variable "ssh_username" {
  type    = string
}

variable "ssh_password" {
  type    = string
}

source "hyperv-iso" "ubuntu" {
  iso_urls        = [
    "c:/isos/ubuntu-20.04.4-live-server-amd64.iso",
    "https://releases.ubuntu.com/20.04.4/ubuntu-20.04.4-live-server-amd64.iso", 
  ],
  iso_checksum    = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad",
  iso_target_path = "c:/isos/", 

  memory             = 8192,
  cpus               = 2,
  disk_size          = 256000,
  generation         = 2,
  enable_secure_boot = false,

  shutdown_command   = "echo '${var.ssh_password}' | sudo -S shutdown -P now"

  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password

  boot_command = 
}


build {
  name    = "learn-packer"
  sources = [
    "source.hyperv-iso.ubuntu"
  ]
}