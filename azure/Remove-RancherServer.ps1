#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [string] $RancherServerDevOpsPath = "$PWD/rancher_server_devops/"
)

$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='SilentlyContinue';

Write-Host "This action will remove Rancher Server DevOps resources and terraform state."
Write-Host "`t This is a highly destructive operation."
Write-Host "`t All resources used to support provisioning Rancher Server will be removed - including secrets, custom containers and terraform state."
Write-Host "`t Existing clusters provisioned through Rancher Server will not be removed, but after this operation will not be able to be managed through terraform - remove them first if that is your intent."
Write-Host "`t"
Write-Host "`t There is no undo. Only 'yes' will be accepted to confirm."
$confirmation = Read-Host "Enter a value"
if ($confirmation -ne 'yes') {
  exit 1
}

Push-Location $RancherServerDevOpsPath
if (Test-Path -Path ./.terraform -PathType Container) {
  Remove-Item backend.tf -force -ErrorAction Ignore
  terraform init -migrate-state -force-copy
  terraform destroy --auto-approve -var="rancher_server_devops_enable_tfstate_delete_lock=false"
  if ($lastexitcode -ne 0) {
    Pop-Location
    Write-Error "Error while destroying Rancher Server DevOps resources. Aborting."
    exit $lastexitcode
  }
  Remove-Item terraform.tfstate -force -ErrorAction Ignore
  Remove-Item terraform.tfstate.backup -force -ErrorAction Ignore
  Remove-Item .terraform.lock.hcl -force -ErrorAction Ignore
  Remove-Item .terraform -recurse -force -ErrorAction Ignore
}
Pop-Location

Remove-Item .terraform -recurse -force -ErrorAction Ignore
Remove-Item backend.tf -force -ErrorAction Ignore
Remove-Item terragrunt.hcl -force -ErrorAction Ignore

Write-Host 'Rancher Server has been removed.'