#!/usr/bin/env pwsh
[CmdletBinding()]
param(
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

# If the Rancher Server VM doesn't exist at C:\vhds\$rancher_server_vm_name, create it
if (Test-Path -Path "C:\vhds\$rancher_linux_node_name") {
    Write-Host "Rancher Server VHD already exists"
} else {
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
        -only="build-rancher-linux-node.hyperv-iso.ubuntu_2004_server" `
        -var "vm_name=$rancher_linux_node_name" `
        -var "linux_username=$linux_username" `
        -var "linux_password=$linux_password" `
        -var "rancher_server_url=$rancher_server_url" `
        -var "rancher_server_token=$rancher_server_token" `
        -var "rancher_server_ca_checksum=$rancher_server_ca_checksum" `
        -var "rancher_node_docker_args=$rancher_node_docker_args" `
        -var "disk_size=256000" `
        .\templates\ubuntu2004.pkr.hcl

    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=0
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }
}