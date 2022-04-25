#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $rancher_server_vm_name = "rancher-server",
    [Parameter(Mandatory)]
    [string] $linux_username,
    [Parameter(Mandatory)]
    [string] $linux_password,
    [Parameter()]
    [bool] $packer_debug = $false
)

$ErrorActionPreference = "Stop"

# If the Rancher Server VM doesn't exist at C:\vhds\$rancher_server_vm_name, create it
if (Test-Path -Path "C:\vhds\$rancher_server_vm_name") {
    Write-Host "Rancher Server VHD already exists"
} else {
    Write-Host "Rancher Server VHD does not exist, creating..."
    packer init .\templates\ubuntu2004.pkr.hcl

    # If Debug Is Set, set the environment variables
    if ($packer_debug -eq $true) {
      $env:PACKER_LOG=1
      $env:PACKER_LOG_PATH=.\packerlog.txt
    }

    packer build `
      -only="build-rancher-server.hyperv-iso.ubuntu_2004_server" `
      -var "vm_name=$rancher_server_vm_name" `
      -var "linux_username=$linux_username" `
      -var "linux_password=$linux_password" `
      .\templates\ubuntu2004.pkr.hcl

    if ($packer_debug -eq $true) {
      $env:PACKER_LOG=0
      $env:PACKER_LOG_PATH=.\packerlog.txt
    }
}

