#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [string] $RancherServerDevOpsPath = "$PWD/rancher_server_devops/"
)

Write-Host "This action will remove Terraform related files from all child folders."
Write-Host "`t Generally, this script is run when testing the rancher server cluster provisioning scripts. If this is run in error, you'll need to re-run terragrunt init in all child folders."
Write-Host "`t"
Write-Host "`t Please type 'yes' to proceed."
$confirmation = Read-Host "Enter a value"
if ($confirmation -ne 'yes') {
  exit 1
}

Get-ChildItem -Path $PWD -Directory | Foreach-Object {
  if ($_.FullName -eq $RancherServerDevOpsPath -or $_.Name -eq 'templates') {
    return
  }

  Write-Host "Cleaning terraform files in $($_.FullName)..."

  if (Test-Path -Path "$($_.FullName)/.terraform" -PathType Container) {
    Write-Host "`tRemoving .terraform"
    Remove-Item "$($_.FullName)/.terraform" -recurse -force -ErrorAction Ignore
  }

  if (Test-Path -Path "$($_.FullName)/backend.tf" -PathType Leaf) {
    Write-Host "`tRemoving backend.tf"
    Remove-Item "$($_.FullName)/backend.tf" -force -ErrorAction Ignore
  }

  if (Test-Path -Path "$($_.FullName)/.terraform.lock.hcl" -PathType Leaf) {
    Write-Host "`tRemoving .terraform.lock.hcl"
    Remove-Item "$($_.FullName)/.terraform.lock.hcl" -force -ErrorAction Ignore
  }
}

Write-Host "Terraform files removed."