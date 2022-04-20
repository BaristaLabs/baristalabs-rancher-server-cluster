# BaristaLabs - Terraform Configuration for a Rancher Server Cluster on AKS

Terraform based setup for a HA Rancher Server Cluster on Azure Kubernetes Service (AKS)

## Prerequisites

The following tools are required to be installed:

Powershell
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell

Terraform
https://www.terraform.io/downloads.html

Terragrunt
https://terragrunt.gruntwork.io/docs/getting-started/install/

Helm
https://helm.sh/

Azure CLI
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli


### Windows
To install with [chocolatey](https://chocolatey.org/):
``` PS
choco install pwsh terraform terragrunt helm azure-cli
```

### macOS
To install with [Homebrew](https://brew.sh/):
``` PS
brew install terraform terragrunt helm azure-cli
brew install --cask powershell
```

Visual Studio Code and Lens are recommended to edit code and interact with environments

## Structure

The configuration is broken up into modules for reuse and separation between cloud-specific resource provisioning and Kubernetes configuration.

The structure folder is currently the following:
```
.
├── assets - Contains any infrastructure related files, images, scripts, etc
├── config - Contains configuration files including license and certificates
├── azure - Contains configurations for Azure-based environments
|   ├── 1_rancher_server_devops - Provides base configuration to support DevOps
│   ├── 2_rancher_server_cluster - Provides the configuration for the AKS cluster that will run the Rancher Server
|   └── 3_rancher_server_resources - Provides the configuration for the Rancher Server itself and associated resources
├── modules - Contains supporting terraform modules
└── scripts - Contains PowerShell scripts in support of Rancher Server DevOps
``` 
```

## Getting Started (Azure)
This series of steps will initialize Rancher Server in an Azure environment.

An exiting Azure account and subscription is required.

1. Ensure that the Azure CLI is installed. Log into your Azure account using ```az login```
2. Ensure the desired Azure account/subscription is set using ```az account show```

If it is not, use ```az account set --sub <subscriptionid>``` to set the desired subscription
```az account list``` will display all available subscriptions.

> Note: On the target subscription, the user must have ```Contribute``` as well as the ```User Access Administrator`` roles.

```User Access Administrator``` is required as Managed Identities are created as part of the configuration scripts

3. If this is the first time working with this repository, initialize the Rancher Server DevOps environment

> Note: If Rancher Server DevOps has already been initialized (On Azure, a resource group named rg-rancher-server-devops will exist), skip this step.

``` pwsh
cd ./azure
./Initialize-RancherServer.ps1
```

> Note: If you have already initialized Rancher Server previously, run ```./Upgrade-RancherServer.ps1``` to upgrade the providers and state to the latest versions.

4. Provision a AKS cluster for Rancher Server.

``` pwsh
cd ./rancher_server_cluster
./Deploy-RancherServerCluster.ps1
```

The deployment script will associated contexts to the local environment - for instance, adding and setting the current kubectl context to the newly created kubernetes cluster.

5. Provision the Rancher Server itself.

First, based on the output of step 4, associate DNS entries rancher.
Next, create SSL certificates for the Rancher Server by executing ```./Create-RancherServerCertificates.ps1```
Add the certificates to the DevOps Azure Key Vault with the keys ```rancher-server-naked-domain-cert``` and ```rancher-server-wildcard-domain-cert```

Now, deploy the rancher server resources

``` pwsh
cd ./rancher_server_resources
./Deploy-RancherServer.ps1
```

Visit whoami.<hostname> to verify the ingress is functioning.
Now visit rancher.<hostname> to get the Rancher Server UI.

All Done!

## Removing a Rancher Server Cluster

To un-provision, simply execute ```./Destroy-RancherServerCluster.ps1``` or ```terragrunt destroy``` within the folder for a particular cloud environment (for instance, ./azure/rancher_server_cluster/Destroy-RancherServerCluster.ps1).

> Note: As a clean-up process, after performing a successful ```terragrunt destroy``` remove backend.tf .terraform.lock.hcl files and the .terraform folder within the target environment folder. The PowerShell Destroy-Environment script performs this step.

## Removing Rancher Server DevOps

To remove Rancher Server DevOps from a subscription, execute ```./Remove-RancherServer.ps1``` within the folder for a particular cloud environment (for instance ./azure/Remove-RancherServer.ps1)

This command does *not* remove any already-provisioned k8s clusters, so if you want to do so, remove the cluster before running this command.

>Note: that this is a destructive operation and you won't be able to provision or change existing environments through terraform if this
is run. This script normally supports development of this repo or when wanting to completly unprovision an environment in demo/development scenarios to save on resource costs.

## Troubleshooting

Please become familar with terraform state management as this will greatly assist with any questions. Often times a manual removal of a resource coupled with a refresh of the state fixes a lot of ailments.

Q: I recieve ```Error: rpc error: code = Unavailable desc = transport is closing``` or ```Error: rpc error: code = Canceled desc = context canceled``` when running terraform operations

A: You're likely running into Azure API throttling, decrease the level of parallelism using ```terraform apply --parallelism=5```. The default is 10.


## Optional Visual Studio Code Extensions

These extensions may help in development:

 - hashicorp.terraform
 - ms-azuretools.vscode-azureterraform
 - ms-azuretools.vscode-docker
 - ms-vscode.powershell
 - ms-vscode.azure-account
 - redhat.vscode-yaml

## Resources

https://www.terraform.io/
https://rancher.com/products/rancher
https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#example-names