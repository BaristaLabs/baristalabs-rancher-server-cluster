packer {
  required_plugins {
    hyperv = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

source "hyperv-iso" "ubuntu" {
  iso_url       = "https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso",
  iso_checksum  =  "sha256:84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f",

  disk_size        = 256000
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}


build {
  name    = "learn-packer"
  sources = [
    "source.hyperv-iso.ubuntu"
  ]
}