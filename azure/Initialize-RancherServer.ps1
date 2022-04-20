#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [string] $RancherServerDevOpsPath = "$PWD/rancher_server_devops/"
)

$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='SilentlyContinue';

# If terraform devops resources have not been applied, apply them
if (-not(Test-Path -Path "$PWD/terragrunt.hcl" -PathType Leaf)) {
  Write-Host 'Initializing Rancher Server DevOps...'
  Push-Location $RancherServerDevOpsPath
  terraform init
  if ($lastexitcode -ne 0) {
    Pop-Location
    Write-Error "Error while initializing terraform. Aborting."
    exit $lastexitcode
  }

  & terraform apply --auto-approve
  if ($lastexitcode -ne 0) {
    Pop-Location
    Write-Error "Error while applying Rancher Server DevOps resources via terraform. Aborting."
    exit $lastexitcode
  }

  Pop-Location
  & "$PWD/Initialize-Terragrunt.ps1"

  Write-Host 'Pushing local state to remote state...'
  Push-Location $RancherServerDevOpsPath
  terragrunt init -migrate-state -force-copy
  if ($lastexitcode -ne 0) {
    Remove-Item backend.tf -force -ErrorAction Ignore
    Pop-Location
    Remove-Item terragrunt.hcl -force -ErrorAction Ignore
    Write-Error "Error while pushing terraform state. Aborting."
    exit $lastexitcode
  }
  Remove-Item terraform.tfstate -force -ErrorAction Ignore
  Pop-Location
  Write-Host 'Rancher Server DevOps Initialized Successfully.'
} else {
  Write-Host 'Rancher Server DevOps Previously Initialized. Aborted.'
}

