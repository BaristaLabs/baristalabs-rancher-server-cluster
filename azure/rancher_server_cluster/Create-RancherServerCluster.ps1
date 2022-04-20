#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [bool] $CertCAUseProduction = $false
)

$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='SilentlyContinue';

& terragrunt apply

if ($lastexitcode -ne 0) {
  Write-Error "Error deploying environment. Aborting."
  exit $lastexitcode
}

$tf = terraform output -json | ConvertFrom-Json -AsHashtable
az aks get-credentials --resource-group $tf.rancher_server_resource_group_name.value --name $tf.rancher_server_cluster_name.value --overwrite-existing
kubectl config set-context --current --namespace="default"
kubectl config current-context
kubectl config view --minify | grep namespace:
Write-Host "External IP: $($tf.rancher_server_cluster_ip.value)"
