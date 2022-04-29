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

variable "machine_name" {
  type    = string
  default = null
}

variable "admin_password" {
  type = string
}

variable "windows_product_key" {
  type    = string
  default = null
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

source "hyperv-iso" "windows_server_2019" {
  iso_urls = [
    "c:/isos/en-us_windows_server_2019_updated_aug_2021_x64_dvd_a6431a28.iso",
    "https://myvs.download.prss.microsoft.com/pr/en-us_windows_server_2019_updated_aug_2021_x64_dvd_a6431a28.iso",
  ]
  iso_checksum    = "sha256:0067AFE7FDC4E61F677BD8C35A209082AA917DF9C117527FC4B2B52A447E89BB"
  iso_target_path = "c:/isos/"

  secondary_iso_images = [
    "${path.cwd}/setup-files.iso",
  ]

  memory     = var.memory
  cpus       = var.cpus
  disk_size  = var.disk_size
  generation = 2

  enable_secure_boot    = false
  enable_dynamic_memory = true
  vm_name               = var.vm_name
  switch_name           = var.virtual_switch_name

  shutdown_command = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout = "1m"

  output_directory = "C:/vhds/${var.vm_name}"

  boot_wait = "2s"
  boot_command = [
    "<enter>",
    "<wait><enter>",
    "<wait20s><tab><tab><tab><enter>",
    "<wait><enter>",                                      # Install Now
    "<wait15s><enter>",                                   # Install Core 2019
    "<wait><space><enter>",                               # Accept EULA
    "<wait><leftShiftOn><down><leftShiftOff><enter>",     # Custom
    "<wait><tab><tab><tab><tab><enter>",                  # Install on Drive 0
    "<wait2m>",                                           # Wait for install to complete
    "<enter>",                                            # Admin password must be changed prompt
    "<wait>${var.admin_password}<tab>",                   # Admin password
    "<wait>${var.admin_password}<enter>",                 # Confirm Password
    "<wait><enter>",                                      # Your password has been changed
    "<wait>PowerShell -File e:\\Enable-WinRM.ps1<enter>", # Enable WinRM
    "<wait>exit<enter>",                                  # Exit Powershell
  ]

  pause_before_connecting = "2s"

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.admin_password
  winrm_timeout  = "2.5m"
}

source "hyperv-vmcx" "windows_server_2019" {

  clone_from_vmcx_path = var.vmcx_path

  memory = var.memory
  cpus   = var.cpus
  disk_additional_size = [
    var.disk_size
  ]
  generation      = 2

  enable_secure_boot   = true
  secure_boot_template = "MicrosoftWindows"

  enable_dynamic_memory = false
  vm_name               = var.vm_name
  switch_name           = var.virtual_switch_name

  shutdown_command = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout = "1m"

  output_directory = "C:/vhds/${var.vm_name}"

  pause_before_connecting = "2s"

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.admin_password
  winrm_timeout  = "2.5m"
  winrm_use_ssl  = true
  #winrm_insecure = true
}

build {
  name = "build-base-windows-server-2019-vm"

  sources = [
    "source.hyperv-iso.windows_server_2019"
  ]

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = var.admin_password

    inline = [
      "wmic useraccount where \"name='Administrator'\" set PasswordExpires=FALSE",
      "cscript C:\\Windows\\System32\\slmgr.vbs /ipk ${var.windows_product_key}",
      # "cscript C:\\Windows\\System32\\slmgr.vbs /ato",
    ]
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = var.admin_password

    inline = [
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force",
      "Install-Module -Name DockerMsftProvider -Repository PSGallery -Force",
      "Install-Package -Name docker -ProviderName DockerMsftProvider -Force",
    ]
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = var.admin_password

    inline = [
      "Install-Package -Name Docker -ProviderName DockerMsftProvider -Update -Force",
      "Start-Service Docker",
      "e:\\Install-Chocolatey.ps1",
      "Copy-Item -Path 'E:\\Disable-WinRM' -Destination 'C:\\' -Force",
    ]
  }
}

build {
  name = "build-rancher-windows-node"

  sources = [
    "source.hyperv-vmcx.windows_server_2019"
  ]

  provisioner "powershell" {
    pause_before = "5s"
    inline = [
      "Rename-Computer -NewName ${var.machine_name} -Force",
      "docker image pull ${var.rancher_agent_image_name}",
      "PowerShell -NoLogo -NonInteractive -Command \"& {docker run -v c:\\:c:\\host  ${var.rancher_agent_image_name} bootstrap --server ${var.rancher_server_url} --token ${var.rancher_server_token} --ca-checksum ${var.rancher_server_ca_checksum}  ${var.rancher_node_docker_args} | iex}\""
    ]
  }
}