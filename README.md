# Terraform Configuration for automated deployments of Rancher Server and a homelab downstream environment.

Terraform based setup for a HA Rancher Server Cluster on Azure Kubernetes Service (AKS) configured for low cost.

Within this configuration, Tailscale is used to allow ingress traffic to seamlessly tunnel to downstream clusters set up through rancher server.

The repository also provides packer scripts to create Ubuntu-based and Windows Server based Hyper-V VM images and configuration that support a homelab cluster running on Hyper-V as well as base 'big-tent' resources for that cluster.

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

Packer
https://www.packer.io/

PowerISO
https://www.poweriso.com/tutorials/command-line-argus.htm

Azure CLI
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli


If you're planning on exposing your Rancher Server to the public, you'll also need a domain name to point to your Rancher Server.

These tools can be installed with the following commands:

### Windows
To install with [chocolatey](https://chocolatey.org/):
``` PS
choco install pwsh terraform terragrunt helm packer azure-cli poweriso
```

### macOS
To install with [Homebrew](https://brew.sh/):
``` PS
brew install terraform terragrunt helm packer azure-cli
brew install --cask powershell
```

Visual Studio Code and Lens are recommended to edit code and interact with environments

Additionally, this Rancher Server configuration is designed to be used with Tailscale in order to facilitate clusters that are not publicly accessible, 
thus, a Terraform account is needed with an ephemerial API key and a non-ephemerial API key.

## Structure

The configuration is broken up into modules for reuse and separation between cloud-specific resource provisioning and Kubernetes configuration.

The structure folder is currently the following:
```
.
├── assets - Contains any infrastructure related files, images, scripts, etc
├── config - Contains configuration files including license and certificates
├── azure - Contains configurations for Azure-based environments
|   ├── rancher_server_devops - Provides base configuration to support DevOps
│   └── rancher_server_cluster - Provides the configuration for the AKS cluster that will run the Rancher Server
├── k8s - Contains configurations for downstream Rancher clusters
|   ├── homelab - Provides the configuration for the homelab cluster to run workloads
|   └── local - Provides the configuration for provisioning traefik and other resources to the Rancher server cluster
├── docker-images - Contains the container images used by the cluster
├── hyper-v - Contains packer scripts to create VMs in Hyper-V that support the homelab cluster
└── modules - Contains supporting terraform modules
``` 

## Getting Started (Azure)
This series of steps will initialize Rancher Server in an Azure environment.

An exiting Azure account and subscription is required. The configuration provisioned will fit into the credits provided by a Visual Studio Subscription

> Note: The Rancher Server provisioned is designed to save on resources. It adheres to a 'Small' HA deployment size as described on [the rancher documentation](https://rancher.com/docs/k3s/latest/en/installation/installation-requirements/)
> Additionally, the Rancher pods are scheduled on the AKS system node pool which is not recommended for production scenarios.
> To scale up the Rancher Server, create a user node pool of the desired size and nodes.
> Adding a dedicated database for production large clusters is beyond the scope of this project.

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

First, modify main.tf and set the locals to your desired values.

``` pwsh
cd ./rancher_server_cluster
./Deploy-RancherServerCluster.ps1
```

The deployment script will associated contexts to the local environment - for instance, adding and setting the current kubectl context to the newly created kubernetes cluster.

This process also creates a DNS zone in Azure which allows cert manager in the rancher server cluster to create wildcard certificates.
Within your domain registrar you'll need to add a NS record for your hostname that indicates the nameservers in the DNS zone.

5. Provision the Rancher Server itself.

The local Rancher Server resources are deployed into the AKS cluster we created earlier via terraform configuration contained in the ./k8s/local/ folder.

First, copy the terragrunt.hcl from ./azure/terragrunt.hcl into the ./k8s/ folder.

At this point you may wish to add your Tailscale API keys to the terragrunt.hcl file as well. If you opt not to, you will be prompted to enter them when running terragrunt.

Now, deploy the rancher server resources

``` pwsh
cd ./local
./terragrunt apply
```

Visit whoami.rancher.<hostname> to verify the ingress is functioning.
Then, visit rancher.<hostname> to get the Rancher Server UI.

6. Create any downstream clusters. If you're provisioning rancher clusters through Rancher Server, feel free to use the Rancher Server UI to create the clusters.

Instructions to provision a homelab cluster are provided below.

## Adding a Homelab cluster

Configuration to facilitate a homelab cluster is provided in the ./k8s/homelab/ folder.

This base configuration consists of the following 'big tent' items that allow for common functionality within homelab resources:

    * Nodes that are able to be accessed via Tailscale
    * Traefik Ingress with upstreams to the Rancher Server environment
    * Promethus for cluster metrics
    * Loki for cluster logs
    * Grafana for metrics
    * Jaeger for tracing
    * NATS for pub/sub
    * Redis for caching/streaming/pub/sub/etc
    * Dapr for service invocation/mesh, state management, pub/sub, external binding, and routing of microservices
 
Additionally, the creation of Hyper-V based nodes is automated through packer.

### Creating Nodes that run on Hyper-V

For on-prem clusters using Hyper-V, you will need to create one or more VMs running docker and associate them with the cluster

Windows and Linux based nodes can be created using the following commands via packer:

```
./hyper-v/Build-LinuxNode.ps1
```

Or manually:
### Add a Linux Node with all roles

1. Download the Ubuntu ISO image
2. Create a new Hyper-V VM using the Ubuntu ISO image using a Gen 2 VM, disabling secure boot - configure the settings, install PowerShell and SSH Server.
3. SSH to the VM and install RKE2 prerequisites using the following instructions: 
https://docs.rke2.io/install/quickstart/#linux-agent-worker-node-installation

4. Create a new custom cluster in rancher server named 'homelab-01' using the RKE2 engine. Run the registration script with all roles - the node will show up in the cluster. Add --address <tailscale ip> to the registration script to set the external talescale ip

### Add a Windows node with the Worker role
1. Download a Windows Server 2019 ISO
2. Create a new Hyper-V VM using the Windows Server 2019 ISO - Suggest using the non-user experience but YMMV
3. Activate windows using ```slmgr.vbs /ipk <product key>```
4. Rename the VM using ```Rename-Computer -NewName <hostname> -Restart```
5. Install the Windows Server Containers feature via the following using the following in an elevated PowerShell session:

```
Enable-WindowsOptionalFeature -Online -FeatureName containers –All
Restart-Computer -Force
```

6. Shutdown the VM and enable secure boot.
7. From the Rancher Server cluster registration page, run the windows registration command, adding -Address <tailscale ip> to the registration script to set the external talescale ip. The ISO takes some time to download so be patient.

At this point you'll have a Rancher Server cluster and downstream homelab cluster running a linux and a windows node.

You'll want to update ./k8s/local/specs/homelab-01-service.yaml with the Tailscale IPs
Next, we'll deploy some the base homelab resources to the cluster.

### Deploying cluster resources to the downstream homelab cluster

First, create a rancher API key in the Rancher Server UI and add the cluster id, url, token key to the ./k8s/terragrunt.hcl file using the following syntax, replacing the values with your own:

``` hcl
  inputs = {
    ...
    cluster_id = "<homelab_cluster_id>"
    cluster_api_url = "https://<homelab_cluster_hostname>"
    cluster_token_key = "<homelab_cluster_token_key>"
  }
```

Now, deploy the homelab resources using ```terragrunt apply``` in ./k8s/homelab-01/

## Removing a Rancher Server Cluster

To un-provision, simply execute ```terragrunt destroy``` within the folder for a particular cloud environment (for instance, ./k8s/local/).

## Removing Rancher Server DevOps

To remove Rancher Server DevOps from a subscription, execute ```./Remove-RancherServerDevOps.ps1``` within the folder for a particular cloud environment (for instance ./azure/Remove-RancherServerDevOps.ps1)

This command does *not* remove any already-provisioned k8s clusters, so if you want to do so, remove the cluster before running this command.

>Note: that this is a destructive operation and you won't be able to provision or change existing environments through terraform if this
is run. This script normally supports development of this repo or when wanting to completly unprovision an environment in demo/development scenarios.

## Troubleshooting

Please become familar with terraform state management as this will greatly assist with any questions. Often times a manual removal of a resource coupled with a refresh of the state fixes a lot of ailments.

Q: I receive ```Error: rpc error: code = Unavailable desc = transport is closing``` or ```Error: rpc error: code = Canceled desc = context canceled``` when running terraform operations

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