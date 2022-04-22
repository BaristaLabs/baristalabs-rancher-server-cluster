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

source "hyperv-iso" "ubuntu" {
  iso_urls        = [
    "c:/isos/ubuntu-20.04.4-live-server-amd64.iso",
    "https://releases.ubuntu.com/20.04.4/ubuntu-20.04.4-live-server-amd64.iso", 
  ]
  iso_checksum    = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
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

  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password

  boot_wait = "2s"
  boot_command = [
    "<enter>",
    "<wait30s><enter>", # language
    "<wait><enter>", # keyboard layout
    "<wait5s><enter>", # network connections
    "<wait><enter>", # proxy settings
    "<wait><enter>", # mirror address
    "<wait><enter>", # mirror address
    "<wait><tab><tab><tab><tab><tab><enter>", # storage configuration
    "<wait><enter>", # storage configuration 2
    "<wait><tab><enter>", # Confirm Destructive Action
    "<wait>${var.ssh_username}<tab>", # your name
    "<wait>${var.vm_name}<tab>", # server name
    "<wait>${var.ssh_username}<tab>", # username
    "${var.ssh_password}<wait><enter>", # password
    "${var.ssh_password}<wait><enter><enter>", # password again
    "<wait><enter>", # profile setup
    "<wait><enter>", # Ubuntu advantage token
    "<wait><tab><tab><enter>", # SSH Setup
    "<wait><tab><enter>", # Featured Server Snaps
    "<wait3.5m><tab><tab><enter>", # Installing Updates
    "<wait10s><enter>", # Done
    "<wait30s><enter>${var.ssh_username}<enter>", #login
    "<wait>${var.ssh_password}<enter>",
    "<wait>sudo apt-get update<enter><wait>${var.ssh_password}<wait><enter>",
    "<wait30s>sudo apt-get install linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual -y<enter>",
    "<wait2.5m>sudo reboot now<enter>" # Done
  ]

  pause_before_connecting = "10s"

  communicator = "ssh"
  ssh_timeout  = "15m"
}


build {
  name    = "build-linux-node"
  sources = [
    "source.hyperv-iso.ubuntu"
  ]
}