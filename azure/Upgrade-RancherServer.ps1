#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [string] $RancherServerDevOpsPath = "$PWD/rancher_server_devops/"
)

Push-Location $RancherServerDevOpsPath
terragrunt init -upgrade
Pop-Location
