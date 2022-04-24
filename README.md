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


If you're planning on exposing your Rancher Server to the public, you'll also need a domain name to point to your Rancher Server.
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

Modify any settings within ./rancher_server_resources/main.tf to suit your environment.

Now, deploy the rancher server resources

``` pwsh
cd ./rancher_server_resources
./Deploy-RancherServer.ps1
```

This process creates a DNS zone. Within your domain registrar you'll need to add a NS record for your hostname that indicates the nameservers in the DNS zone.

Visit whoami.<hostname> to verify the ingress is functioning.
Now visit rancher.<hostname> to get the Rancher Server UI.

6. Create any clusters you desire

For on-prem clusters using Hyper-V, you will need to create one or more VMs running docker and associate them with the cluster

Add a Linux Node with all roles
1. Download the Ubuntu ISO image
2. Create a new Hyper-V VM using the Ubuntu ISO image using a Gen 2 VM, disabling secure boot - configure the settings, install PowerShell and SSH Server.
3. SSH to the VM and install docker using the following instructions:
https://docs.docker.com/engine/install/ubuntu/
https://docs.docker.com/engine/install/linux-postinstall/
4. Create a new cluster in rancher server and run the registration script with all roles - the node will show up in the cluster

Add a Windows node with the Worker role
1. Download a Windows Server 2019 ISO
2. Create a new Hyper-V VM using the Windows Server 2019 ISO - Suggest using the non-user experience but YMMV
3. Activate windows using ```slmgr.vbs /ipk <kproduct key>```
4. Rename the VM using ```Rename-Computer -NewName <hostname> -Restart```
5. Install docker using the following:

https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=Windows-Server
```
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider
Restart-Computer -Force
Install-Package -Name Docker -ProviderName DockerMsftProvider -Update -Force
Start-Service Docker
```

6. Shutdown the VM and enable secure boot
7. Within the cluster management console in rancher, run the registration command - the ISO takes some time to download so be patient.

At this point you'll have a Rancher Server cluster, a downstream cluster running a linux and a windows node.

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