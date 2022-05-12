packer {
  required_plugins {
    hyperv = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

variable "vm_name" {
  type = string
}

variable "linux_username" {
  type = string
}

variable "linux_password" {
  type = string
}

variable "virtual_switch_name" {
  type    = string
  default = "External"
}

variable "memory" {
  type    = number
  default = 8192
}

variable "cpus" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 16000
}

variable rancher_server_image_name {
  type    = string
  default = "rancher/rancher:latest"
}

variable rancher_agent_image_name {
  type    = string
  default = "rancher/rancher-agent:v2.6.4"
}

variable "rancher_server_url" {
  type    = string
  default = null
}

variable "rancher_server_token" {
  type    = string
  default = null
}

variable "rancher_server_ca_checksum" {
  type    = string
  default = null
}

variable "rancher_node_docker_args" {
  type    = string
  default = "--worker"
}

variable "vmcx_path" {
  type    = string
  default = null
}

source "hyperv-iso" "ubuntu_2004_server" {
  iso_urls = [
    "c:/isos/ubuntu-20.04.4-live-server-amd64.iso",
    "https://releases.ubuntu.com/20.04.4/ubuntu-20.04.4-live-server-amd64.iso",
  ]
  iso_checksum    = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
  iso_target_path = "c:/isos/"

  memory          = var.memory
  cpus            = var.cpus
  disk_size       = var.disk_size
  disk_block_size = 1 # Recommended disk block size for Linux hyper-v guests is 1 MiB
  generation      = 2

  enable_secure_boot    = false
  enable_dynamic_memory = true
  vm_name               = var.vm_name
  switch_name           = var.virtual_switch_name

  shutdown_command = "echo \"${var.linux_password}\" | sudo -S -k shutdown -P now"
  shutdown_timeout = "30s"

  output_directory = "C:/vhds/${var.vm_name}"

  ssh_username = var.linux_username
  ssh_password = var.linux_password

  boot_wait = "2s"
  boot_command = [
    "<enter>",
    "<wait30s><enter>",                             # language
    "<wait><enter>",                                # keyboard layout
    "<wait5s><enter>",                              # network connections
    "<wait><enter>",                                # proxy settings
    "<wait><enter>",                                # mirror address
    "<wait><enter>",                                # mirror address
    "<wait><tab><tab><tab><tab><tab><enter>",       # storage configuration
    "<wait><enter>",                                # storage configuration 2
    "<wait><tab><enter>",                           # Confirm Destructive Action
    "<wait>${var.linux_username}<tab>",             # your name
    "<wait>${var.vm_name}<tab>",                    # server name
    "<wait>${var.linux_username}<tab>",             # username
    "${var.linux_password}<wait><enter>",           # password
    "${var.linux_password}<wait><enter><enter>",    # password again
    "<wait><enter>",                                # profile setup
    "<wait><enter>",                                # Ubuntu advantage token
    "<wait><tab><tab><enter>",                      # SSH Setup
    "<wait><tab><enter>",                           # Featured Server Snaps
    "<wait4.5m><tab><tab><enter>",                  # Installing Updates
    "<wait10s><enter>",                             # Done
    "<wait30s><enter>${var.linux_username}<enter>", #login
    "<wait>${var.linux_password}<enter>",
    "<wait>echo \"${var.linux_password}\" | sudo -S -k apt-get update<wait><enter>",
    "<wait15s>echo \"${var.linux_password}\" | sudo -S -k apt-get install -y linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual<enter>",
    "<wait2.5m>echo \"${var.linux_password}\" | sudo -S -k reboot now<enter>" # Done
  ]

  pause_before_connecting = "2s"

  communicator = "ssh"
  ssh_timeout  = "15m"
  headless     = true
}

source "hyperv-vmcx" "ubuntu_2004_server" {

  clone_from_vmcx_path = var.vmcx_path

  memory = var.memory
  cpus   = var.cpus
  disk_additional_size = [
    var.disk_size
  ]
  disk_block_size = 1 # Recommended disk block size for Linux hyper-v guests is 1 MiB
  generation      = 2

  enable_secure_boot    = false
  enable_dynamic_memory = true
  vm_name               = var.vm_name
  switch_name           = var.virtual_switch_name

  shutdown_command = "echo \"${var.linux_password}\" | sudo -S -k shutdown -P now"
  shutdown_timeout = "30s"

  output_directory = "C:/vhds/${var.vm_name}"

  ssh_username = var.linux_username
  ssh_password = var.linux_password

  pause_before_connecting = "10s"

  communicator = "ssh"
  ssh_timeout  = "15m"
  headless     = true
}

build {
  name = "build-base-ubuntu-2004-server-vm"

  sources = [
    "source.hyperv-iso.ubuntu_2004_server"
  ]

  provisioner "shell" {
    inline = [
      "echo \"${var.linux_password}\" | sudo -S -k apt-get update",
      "echo \"${var.linux_password}\" | sudo -S -k apt-get install -y ca-certificates curl gnupg lsb-release",
      "echo \"${var.linux_password}\" | sudo -S -k -- sh -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg'",
      "echo \"${var.linux_password}\" | sudo -S -k -- sh -c 'echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null'",
      "echo \"${var.linux_password}\" | sudo -S -k -- sh -c 'curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null'",
      "echo \"${var.linux_password}\" | sudo -S -k -- sh -c 'curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list'",
      "echo \"${var.linux_password}\" | sudo -S -k apt-get update",
      "echo \"${var.linux_password}\" | sudo -S -k apt-get install -y docker-ce docker-ce-cli containerd.io tailscale ctop",
      "echo \"${var.linux_password}\" | sudo -S -k usermod -aG docker $USER",
      "newgrp docker",
      "echo \"${var.linux_password}\" | sudo -S -k systemctl enable docker.service",
      "echo \"${var.linux_password}\" | sudo -S -k systemctl enable containerd.service"
    ]
  }
}

build {
  name = "build-rancher-linux-node"

  sources = [
    "source.hyperv-vmcx.ubuntu_2004_server"
  ]

  provisioner "shell" {
    pause_before = "5s"
    inline = [
      "NEW_HOSTNAME=${var.vm_name}",
      "CUR_HOSTNAME=$(cat /etc/hostname)",
      "echo \"${var.linux_password}\" | sudo -S -k hostnamectl set-hostname $NEW_HOSTNAME",
      "echo \"${var.linux_password}\" | sudo -S -k hostname $NEW_HOSTNAME",
      "echo \"${var.linux_password}\" | sudo -S -k sed -i \"s/$CUR_HOSTNAME/$NEW_HOSTNAME/g\" /etc/hosts",
      "echo \"${var.linux_password}\" | sudo -S -k sed -i \"s/$CUR_HOSTNAME/$NEW_HOSTNAME/g\" /etc/hostname",
      "hostname",
      "echo \"${var.linux_password}\" | sudo -S -k reboot",
    ]

    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "5s"
    inline = [
      "docker image pull ${var.rancher_agent_image_name}",
      "docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  ${var.rancher_agent_image_name} --server ${var.rancher_server_url} --token ${var.rancher_server_token} --ca-checksum ${var.rancher_server_ca_checksum} ${var.rancher_node_docker_args}"
    ]
  }
}

build {
  name = "build-rancher-server"

  sources = [
    "source.hyperv-vmcx.ubuntu_2004_server"
  ]

  provisioner "shell" {
    pause_before = "5s"
    inline = [
      "NEW_HOSTNAME=${var.vm_name}",
      "CUR_HOSTNAME=$(cat /etc/hostname)",
      "echo \"${var.linux_password}\" | sudo -S -k hostnamectl set-hostname $NEW_HOSTNAME",
      "echo \"${var.linux_password}\" | sudo -S -k hostname $NEW_HOSTNAME",
      "echo \"${var.linux_password}\" | sudo -S -k sed -i \"s/$CUR_HOSTNAME/$NEW_HOSTNAME/g\" /etc/hosts",
      "echo \"${var.linux_password}\" | sudo -S -k sed -i \"s/$CUR_HOSTNAME/$NEW_HOSTNAME/g\" /etc/hostname",
      "hostname",
      "echo \"${var.linux_password}\" | sudo -S -k reboot",
    ]

    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "5s"
    inline = [
      "echo \"${var.linux_password}\" | sudo -S -k hostnamectl set-hostname ${var.vm_name}",
      "docker image pull ${var.rancher_server_image_name}",
      "docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged ${var.rancher_server_image_name}",
    ]
  }
}