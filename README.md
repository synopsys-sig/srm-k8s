# Deploying Software Risk Manager on Kubernetes

You will use Helm to deploy Software Risk Manager on your Kubernetes cluster. If you want to customize your deployment or use the Scan Farm feature, refer to the [Software Risk Manager Kubernetes Deployment Guide](docs/DeploymentGuide.md).

## Quick Start

You can follow the Quick Start instructions if you want to deploy Software Risk Manager using default settings and either the Core or Tool Orchestration features. If you want to customize your deployment or use the Scan Farm feature, refer to the [Software Risk Manager Kubernetes Deployment Guide](docs/DeploymentGuide.md).

### Quick Start - SRM Core Feature

Run the following commands to install SRM Core using a configuration with limited resource reservations:

```
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://synopsys-sig.github.io/srm-k8s srm srm # --set openshift.createSCC=true
```

>Note: If you are using OpenShift, remove `#` when running the last command.

### Quick Start - SRM with Tool Orchestration Feature

Run the following commands to install SRM with Tool Orchestration using a configuration with limited resource reservations:

```
$ git clone https://github.com/synopsys-sig/srm-k8s
$ kubectl apply -f srm-k8s/crds/v1
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://synopsys-sig.github.io/srm-k8s -f srm-k8s/chart/values/values-to.yaml srm srm # --set openshift.createSCC=true
```

>Note: If you are using OpenShift, remove `#` when running the last command.
