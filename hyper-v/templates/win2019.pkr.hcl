packer {
  required_plugins {
    hyperv = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

variable "vm_name" {
  type    = string
}

variable "ssh_username" {
  type    = string
}

variable "ssh_password" {
  type    = string
}

source "hyperv-iso" "win2019" {
  iso_urls        = [
    "c:/isos/en-us_windows_server_2019_updated_aug_2021_x64_dvd_a6431a28.iso",
    "https://myvs.download.prss.microsoft.com/pr/en-us_windows_server_2019_updated_aug_2021_x64_dvd_a6431a28.iso", 
  ]
  iso_checksum    = "sha256:0067AFE7FDC4E61F677BD8C35A209082AA917DF9C117527FC4B2B52A447E89BB"
  iso_target_path = "c:/isos/"

  memory             = 8192
  cpus               = 2
  disk_size          = 256000
  generation         = 2

  enable_secure_boot    = false
  enable_dynamic_memory = true
  vm_name               = var.vm_name
  switch_name           = "External"

  shutdown_command   = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  shutdown_timeout   = "30s"

  output_directory   = "C:/vhds/${var.vm_name}"

  boot_command          = ["a<enter><wait>a<enter><wait>a<enter><wait>a<enter>"]
  boot_wait             = "1s"
  communicator          = "winrm"
  cpus                  = 4
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  memory                = 4096
  output_directory      = "${var.output_directory}"
  secondary_iso_images  = ["${var.secondary_iso_image}"]
  shutdown_timeout      = "30m"
  skip_export           = true
  switch_name           = "${var.switch_name}"
  temp_path             = "."
  vlan_id               = "${var.vlan_id}"
  vm_name               = "${var.vm_name}"
  winrm_password        = "password"
  winrm_timeout         = "8h"
  winrm_username        = "Administrator"
}