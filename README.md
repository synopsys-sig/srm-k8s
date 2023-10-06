# Moving from Code Dx to Software Risk Manager (SRM)

This is the place to start if you are installing SRM for the very first time. 

The SRM software uses a new deployment model that supports a separately licensed Scan Farm feature, which includes built-in SAST and SCA scanning powered by Coverity and Black Duck.

If you previously installed Code Dx, the SRM predecessor, you should upgrade your Code Dx instance using the deprecated deployment model available in the [codedx-kubernetes](https://github.com/codedx/codedx-kubernetes) repository. Code Dx customers should plan to [migrate](admin/migrate) to the new deployment model by 11/14/2023.

# Deploying SRM on Kubernetes

You will use Helm to deploy SRM on your Kubernetes cluster. The SRM deployment includes optional features and requires you to specify parameters suitable for your deployment.

## Quick Start

If you want to run SRM using default settings, run helm directly using the chart in this repository. The Quick Start deployment method supports both SRM Core and SRM with the Tool Orchestration feature.

>Note: If you want to customize your deployment or use the Scan Farm feature, refer to the Helm Chart Configuration section.

### Quick Start - SRM Core

Run the following commands to install SRM Core using the default configuration:

```
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://synopsys-sig.github.io/srm-k8s srm srm # --set openshift.createSCC=true
```

>Note: If you are using OpenShift, remove `#` when running the last command.

### Quick Start - SRM with Tool Orchestration

Run the following commands to install SRM with Tool Orchestration using the default configuration:

```
$ git clone https://github.com/synopsys-sig/srm-k8s
$ kubectl apply -f srm-k8s/crds/v1
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://synopsys-sig.github.io/srm-k8s -f srm-k8s/chart/values/values-to.yaml srm srm # --set openshift.createSCC=true
```

>Note: If you are using OpenShift, remove `#` when running the last command.

## Helm Chart Configuration

This GitHub repository contains tools to help simplify deploying SRM on your cluster.

Your first SRM Kubernetes deployment is a four-step process:

- Clone this GitHub Repository
- Run Helm Prep Wizard (once)
- Run Helm Prep Script
- Invoke helm/kubectl Commands

>Note: SRM upgrades require three steps; you will not re-run the Help Prep Wizard when upgrading SRM.

## Prerequisites

The deployment scripts in this repository require [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/overview), which runs on macOS, Linux, and Windows. Additionally, the scripts in this repository depend on a [Java JRE](https://adoptium.net/temurin/releases/?version=11), specifically, the keytool program, which should be in your PATH. Before running the scripts, you should also have your kubectl context configured for your cluster. If this is impossible, set your context to a cluster with the same K8s version as the cluster hosting your SRM software.

- [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/overview) (not [Windows PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell))
- [Java JRE](https://adoptium.net/temurin/releases/?version=11) (specifically, keytool in your PATH)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl) context (kubectl config use-context your-context)

### Pod Resources

Below are the default CPU, memory, ephemeral storage, and volume requirements for SRM pods. Your deployment may not include every pod type listed, but make sure your cluster has sufficient capacity for your specific resource requirements.

| Pod               | CPU   | Memory  | Ephemeral Storage | Volume Size | Optional Feature   |
| :---              | :---: | :---:   | :---:             | :---:       | :---:              |
| Web               | 2000m | 8192Mi  | 2048Mi            | 64Gi        | N/A                |
| DB (master)       | 2000m | 8192Mi  | -                 | 64Gi        | On-Cluster DB      |
| DB (subordinate)  | 1000m | 8192Mi  | -                 | 64Gi        | On-Cluster DB      |
| Scan Service      | 100m  | 128Mi   | -                 | -           | Scan Farm          |
| Cache Service     | 500m  | 1000Mi  | -                 | -           | Scan Farm          |
| Storage Service   | 100m  | 128Mi   | -                 | -           | Scan Farm          |
| Coverity Scan Job | 6500m | 26000Mi | -                 | -           | Scan Farm          |
| SCA Scan Job      | 1500m | 1500Mi  | -                 | -           | Scan Farm          |
| Tool Service      | 1000m | 1024Mi  | -                 | -           | Tool Orchestration |
| MinIO             | 2000m | 500Mi   | -                 | 64Gi        | Tool Orchestration |
| Workflow          | 500m  | 500Mi   | -                 | -           | Tool Orchestration |
| Tools             | 500m  | 500Mi   | -                 | -           | Tool Orchestration |

>Note: You may have more than one Tool Service pod, and orchestrated analyses can run multiple tools concurrently.

### Windows Prerequisites

On Windows, make sure that you can run PowerShell Core scripts by switching your PowerShell Execution Policy to RemoteSigned (recommended) or Unrestricted. You must run the Set-ExecutionPolicy -ExecutionPolicy RemoteSigned command from an elevated/administrator Command Prompt.

### Scan Farm Nodes

The SRM software supports a separately licensed Scan Farm feature, which includes built-in SAST and SCA scanning powered by Coverity and Black Duck. Instances of the Coverity Scan Job and the SCA Scan Job will only run on tainted nodes (NodeType=ScannerNode:NoSchedule) with a specific label (pool-type=small). Each SAST scan requires two Coverity Scan Job instances that run consecutively, and scan farm nodes can support only one Coverity Scan Job pod at a time, so you should plan your node pool size and elasticity configuration accordingly.

## Clone GitHub Repository

This GitHub repository contains what you need to start your SRM K8s deployment. Clone this repository to a stable directory on your system. You will use your cloned repository for both your initial deployment and for deploying future SRM software upgrades.

```
$ git clone https://github.com/synopsys-sig/srm-k8s
```

## Helm Prep Wizard

You can think of the Helm Prep Wizard as an interactive installation document that gets you ready to deploy SRM using helm. The Helm Prep Wizard displays a series of questions to help you select SRM features and specify related deployment parameters. It is a [PowerShell Core 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) script you can run on macOS, Linux, or Windows to select SRM deployment features and gather required deployment parameters. 

You typically run the Helm Prep Wizard once at the outset of your initial deployment. To start the wizard, you must first clone this GitHub repository. 

The Helm Prep Wizard depends on the "guided-setup" PowerShell module, which gets downloaded automatically from the PowerShell Gallery. Alternatively, you can download the module from NuGet. If you prefer to download/install manually, refer to the instructions in the installation script.

```
$ cd /path/to/srm-k8s
$ pwsh ./helm-prep-wizard.ps1
```

## Helm Prep Script

The Helm Prep Wizard concludes by creating a run-helm-prep.ps1 script that calls the SRM helm prep script with your deployment parameters to generate Helm command and values files with dependent K8s YAML resource files suitable for your SRM deployment. The SRM helm prep script outputs the kubectl/helm commands and installation notes to invoke your initial deployment.

```
$ cd /path/to/srm-k8s-work-dir # selected during Helm Prep Wizard
$ pwsh ./run-helm-prep.ps1
```

## Invoke helm/kubectl Commands

Your deployment occurs when you run the commands generated by the helm prep script. The output of the helm prep script will look similar to the following. 

```
----------------------
K8s Installation Notes
----------------------
- Your deployment includes the scan farm feature. Remember to complete the following tasks:
  * Configure external dependencies (PostgreSQL, Redis, Object Storage)
  * Define your "small" scan job node pool:
  *   Assign a pool-type label (pool-type=small) to analysis node(s).
  *   Assign a scanner node taint (NodeType=ScannerNode:NoSchedule) to analysis node(s).
  *   NOTE: A "small" pool-type requires one or more nodes with 6.5 vCPUs and 26 GB of memory
- Follow instructions at https://github.com/synopsys-sig/srm-k8s/blob/main/docs/deploy/registry.md to pull/push Synopsys Docker images to your private registry.


----------------------
Required K8s Namespace
----------------------
kubectl create namespace srm

----------------------
Required K8s Resources
----------------------
kubectl apply -f "/path/to/.k8s-srm/chart-resources"

----------------------
Required Helm Commands
----------------------
helm repo add codedx https://codedx.github.io/codedx-kubernetes
helm repo add cnc https://sig-repo.synopsys.com/artifactory/sig-cloudnative
helm repo update
helm dependency update /path/to/git/srm-k8s/chart
helm -n srm upgrade --reset-values --install srm -f "/path/to/.k8s-srm/chart-values-combined/values-combined.yaml" --timeout 30m0s /path/to/git/srm-k8s/chart
```

- The optional `K8s Installation Notes` section will include steps you should take before creating K8s resources and running helm.
- The `Required K8s Namespace` contains the kubectl command to create your SRM namespace. If the namespace already exists, you can ignore that section.
- Running the kubectl command in the `Required K8s Resources` section will generate any K8s resources upon which your helm chart configuration depends.
- The `Required Helm Commands` section includes the helm commands you must run to deploy (or upgrade) SRM.

## Upgrades

The SRM upgrade process is a three-step process:

- Pull latest from this GitHub Repository
- Re-run Helm Prep Script
- Re-invoke helm/kubectl Commands

This GitHub repository gets updated with each SRM deployment. Future SRM upgrades start by updating your clone of this repository by fetching the latest commits (git pull). If you open your run-helm-prep.ps1 script, you'll notice how it points to the helm prep script in your repo clone, allowing you to run the helm prep script associated with a specific SRM version.

Re-running your run-helm-prep.ps1 script will generate the latest kubectl/helm commands for the SRM version you're upgrading to. Invoking those commands will upgrade your SRM software.

```
$ cd /path/to/srm-k8s
$ git pull
$ cd /path/to/srm-k8s-work-dir # selected during Helm Prep Wizard
$ pwsh ./run-helm-prep.ps1
$ optionally re-pull/push SRM Docker images (see note)
$ run helm/kubectl commands
```

>Note: If you previously pulled SRM Docker images from the Synopsys Docker registry, re-pull/push the Docker images for the upgraded SRM version before running your helm command.

## Uninstall

You can remove SRM by running the following commands (replace release name and K8s namespace as necessary):

```
$ helm -n srm delete srm
$ kubectl delete ns srm
```

Delete any remaining Persistent Volumes (PV) and any related PV data.
