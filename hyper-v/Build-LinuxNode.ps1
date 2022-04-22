#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $linux_node_vm_name,
    [Parameter(Mandatory)]
    [string] $linux_node_ssh_username,
    [Parameter(Mandatory)]
    [string] $linux_node_ssh_password,
    [Parameter()]
    [bool] $packer_debug = $false
)

packer init .\templates\linux-node.pkr.hcl

# If Debug Is Set, set the environment variables
if ($packer_debug -eq $true) {
    $env:PACKER_LOG=1
    $env:PACKER_LOG_PATH=.\packerlog.txt
}

packer build -var "vm_name=$linux_node_vm_name" -var "ssh_username=$linux_node_ssh_username" -var "ssh_password=$linux_node_ssh_password" .\templates\linux-node.pkr.hcl

if ($packer_debug -eq $true) {
    $env:PACKER_LOG=0
    $env:PACKER_LOG_PATH=.\packerlog.txt
}