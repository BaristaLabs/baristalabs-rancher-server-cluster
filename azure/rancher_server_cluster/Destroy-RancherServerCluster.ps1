#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='SilentlyContinue';

terragrunt destroy
if ($lastexitcode -ne 0) {
  Write-Error "Error destroying environment. Aborting."
  exit $lastexitcode
}

Remove-Item "$($_.FullName)/.terraform" -recurse -force -ErrorAction Ignore
Remove-Item "$($_.FullName)/backend.tf" -force -ErrorAction Ignore
Remove-Item "$($_.FullName)/.terraform.lock.hcl" -force -ErrorAction Ignore