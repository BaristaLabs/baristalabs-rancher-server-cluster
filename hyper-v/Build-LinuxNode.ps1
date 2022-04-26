#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $base_ubuntu_vmcx_name = "ubuntu-2004-server-base",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $rancher_linux_node_name = "rancher-linux-node-01",
    [Parameter(Mandatory)]
    [string] $linux_username,
    [Parameter(Mandatory)]
    [string] $linux_password,
    [Parameter(Mandatory)]
    [string] $rancher_server_url,
    [Parameter(Mandatory)]
    [string] $rancher_server_token,
    [Parameter(Mandatory)]
    [string] $rancher_server_ca_checksum,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('etcd','controlplane','worker')]
    [string[]] $rancher_node_roles = @("etcd", "controlplane", "worker"),
    [Parameter()]
    [bool] $packer_debug = $false
)

$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='SilentlyContinue';

# If the base ubuntu vm doesn't exist at C:\vhds\$base_ubuntu_vmcx_path, create it
if (Test-Path -Path "C:\vhds\$base_ubuntu_vmcx_name") {
    Write-Host "Base Ubuntu 20.04 Server VM already exists"
} else {
    Write-Host "Creating Base Ubuntu 20.04 Server VM..."

    packer init .\templates\ubuntu2004.pkr.hcl

    # If Debug Is Set, set the environment variables
    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=1
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }

    $rancher_node_docker_args = ""
    foreach ($rancher_node_role in $rancher_node_roles) {
        $rancher_node_docker_args += " --$rancher_node_role"
    }

    packer build `
        -only="build-base-ubuntu-2004-server-vm.hyperv-iso.ubuntu_2004_server" `
        -var "vm_name=$base_ubuntu_vmcx_name" `
        -var "linux_username=$linux_username" `
        -var "linux_password=$linux_password" `
        -var "rancher_server_url=$rancher_server_url" `
        -var "rancher_server_token=$rancher_server_token" `
        -var "rancher_server_ca_checksum=$rancher_server_ca_checksum" `
        -var "rancher_node_docker_args=$rancher_node_docker_args" `
        .\templates\ubuntu2004.pkr.hcl

    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=0
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }
}

# If the Rancher Node VM doesn't exist at C:\vhds\$rancher_linux_node_name, create it
if (Test-Path -Path "C:\vhds\$rancher_linux_node_name") {
    Write-Host "Rancher Node VHD already exists"
} else {
    Write-Host "Creating Rancher Node VM..."

    packer init .\templates\ubuntu2004.pkr.hcl

    # If Debug Is Set, set the environment variables
    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=1
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }

    $rancher_node_docker_args = ""
    foreach ($rancher_node_role in $rancher_node_roles) {
        $rancher_node_docker_args += " --$rancher_node_role"
    }

    packer build `
        -only="build-rancher-linux-node.hyperv-vmcx.ubuntu_2004_server" `
        -var "vmcx_path=c:/vhds/${base_ubuntu_vmcx_name}" `
        -var "vm_name=$rancher_linux_node_name" `
        -var "linux_username=$linux_username" `
        -var "linux_password=$linux_password" `
        -var "rancher_server_url=$rancher_server_url" `
        -var "rancher_server_token=$rancher_server_token" `
        -var "rancher_server_ca_checksum=$rancher_server_ca_checksum" `
        -var "rancher_node_docker_args=$rancher_node_docker_args" `
        -var "memory=16384" `
        -var "cpus=4" `
        -var "disk_size=256000" `
        .\templates\ubuntu2004.pkr.hcl

    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=0
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }
}