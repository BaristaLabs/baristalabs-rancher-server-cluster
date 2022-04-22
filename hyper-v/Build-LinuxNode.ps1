#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $linux_node_vm_name,
    [Parameter(Mandatory)]
    [string] $linux_node_ssh_username,
    [Parameter(Mandatory)]
    [string] $linux_node_ssh_password
)

packer init .\templates\linux-node.pkr.hcl
packer build -var "vm_name=$linux_node_vm_name" -var "ssh_username=$linux_node_ssh_username" -var "ssh_password=$linux_node_ssh_password" .\templates\linux-node.pkr.hcl 