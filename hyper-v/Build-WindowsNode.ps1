#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $base_windows_vmcx_name = "windows-server-2019-base",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $rancher_windows_node_name = "rancher-windows-node-01",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $rancher_windows_node_machine_name = "rancher-win-01",
    [Parameter(Mandatory)]
    [string] $admin_password,
    [Parameter(Mandatory)]
    [string] $windows_product_key,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('etcd','controlplane','worker')]
    [string[]] $rancher_node_roles = @("worker"),
    [Parameter()]
    [bool] $packer_debug = $false
)

$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='SilentlyContinue';

# Join the node roles into a single string
$rancher_node_docker_args = "--" + ($rancher_node_roles | Join-String -Separator " --")

# If the base windows vm doesn't exist at C:\vhds\$rancher_windows_node_name, create it
if (Test-Path -Path "C:\vhds\$base_windows_vmcx_name") {
    Write-Host "Base Windows Server 2019 VM already exists"
} else {
    Write-Host "Creating Base Windows Server 2019 VM..."

    if (Test-Path ./setup-files.iso){
        Remove-Item ./setup-files.iso -Force
    }

    & 'C:\Program Files\PowerISO\piso' create -o ./setup-files.iso -add .\templates\scripts /

    packer init .\templates\win2019.pkr.hcl

    # If Debug Is Set, set the environment variables
    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=1
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }

    packer build `
        -only="build-base-windows-server-2019-vm.hyperv-iso.windows_server_2019" `
        -var "vm_name=$base_windows_vmcx_name" `
        -var "admin_password=$admin_password" `
        -var "windows_product_key=$windows_product_key" `
        -var "rancher_node_docker_args=$rancher_node_docker_args" `
        .\templates\win2019.pkr.hcl

    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=0
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }
}

# If the Rancher Node VM doesn't exist at C:\vhds\$rancher_windows_node_name, create it
if (Test-Path -Path "C:\vhds\$rancher_windows_node_name") {
    Write-Host "Rancher Windows Node VHD already exists"
} else {
    Write-Host "Creating Rancher Windows Node VM..."

    packer init .\templates\win2019.pkr.hcl

    # If Debug Is Set, set the environment variables
    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=1
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }

    packer build `
        -only="build-rancher-windows-node.hyperv-vmcx.windows_server_2019" `
        -var "vmcx_path=c:/vhds/$base_windows_vmcx_name" `
        -var "vm_name=$rancher_windows_node_name" `
        -var "machine_name=$rancher_windows_node_machine_name" `
        -var "admin_password=$linux_password" `
        -var "rancher_node_docker_args=$rancher_node_docker_args" `
        -var "memory=16384" `
        -var "cpus=4" `
        -var "disk_size=256000" `
        .\templates\win2019.pkr.hcl

    if ($packer_debug -eq $true) {
        $env:PACKER_LOG=0
        $env:PACKER_LOG_PATH=.\packerlog.txt
    }
}