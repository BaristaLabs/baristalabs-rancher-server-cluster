#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [string] $RancherServerDevOpsPath = "$PWD/rancher_server_devops/",
    [Parameter()]
    [bool] $Force = $false
)

Write-Host 'Creating root terragrunt.hcl...'

Push-Location $RancherServerDevOpsPath
$rancher_server_devops_output = terraform output -json | ConvertFrom-Json -AsHashtable
$rancher_server_devops_resource_group_name = $rancher_server_devops_output.rancher_server_devops_resource_group.value.name
$rancher_server_devops_tfstate_storage_account_name = $rancher_server_devops_output.rancher_server_devops_tfstate_storage_account_name.value
Pop-Location

if ($Force -or -not(Test-Path -Path ./terragrunt.hcl -PathType Leaf)) {
  Copy-Item ./templates/terragrunt.hcl ./terragrunt.hcl
}

Write-Host "Using Rancher Server DevOps Resource Group: $rancher_server_devops_resource_group_name"
Write-Host "Using Rancher Server DevOps TFState Storage Account: $rancher_server_devops_tfstate_storage_account_name"

(Get-Content terragrunt.hcl) `
  -replace '\${rancher_server_devops_resource_group_name}', "$rancher_server_devops_resource_group_name" `
  -replace '\${rancher_server_devops_tfstate_storage_account_name}', "$rancher_server_devops_tfstate_storage_account_name" `
  | Out-File terragrunt.hcl

Write-Host 'Created root terragrunt.hcl'