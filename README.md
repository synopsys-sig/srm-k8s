# Deploying Software Risk Manager on Kubernetes

You will use Helm to deploy Software Risk Manager on your Kubernetes cluster. If you want to customize your deployment or use the Scan Farm feature, refer to the [Software Risk Manager Kubernetes Deployment Guide](docs/DeploymentGuide.md).

### New Repository Location

Ignore this section if you are installing SRM on a Kubernetes cluster for the first time.

The srm-k8s repo was previously hosted at https://github.com/synopsys-sig. Git requests to that repo should get redirected to this one, so your local srm-k8s clone should continue working. To explicitly update your clone's origin to this repo, run the following command, which uses an HTTPS git connection:

```
$ cd /path/to/local/git/clone/srm-k8s
$ git remote set-url origin https://github.com/codedx/srm-k8s.git
```

The srm-k8s chart repository moved to [https://codedx.github.io/srm-k8s](https://codedx.github.io/srm-k8s/index.yaml) (from synopsys-sig.github.io/srm-k8s)

If you previously ran one of the Quick Start commands, update your `--repo` parameter to reference the new repository.

```
helm -n srm upgrade --reset-values --install --create-namespace --repo https://codedx.github.io/srm-k8s ...
```

If you previously added a helm repo for the old chart repository, you must update your repo URL to the new one. For example, if you added a repo named srm-repo, update it with the following command.

```
helm repo add --force-update srm-repo https://codedx.github.io/srm-k8s
```

## Quick Start

You can follow the Quick Start instructions if you want to deploy Software Risk Manager using default settings and either the Core or Tool Orchestration features. If you want to customize your deployment or use the Scan Farm feature, refer to the [Software Risk Manager Kubernetes Deployment Guide](docs/DeploymentGuide.md).

### Quick Start - SRM Core Feature

Run the following commands to install SRM Core using a configuration with limited resource reservations:

```
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://codedx.github.io/srm-k8s srm srm # --set openshift.createSCC=true
```

>Note: If you are using OpenShift, remove `#` when running the last command.

### Quick Start - SRM with Tool Orchestration Feature

Run the following commands to install SRM with Tool Orchestration using a configuration with limited resource reservations:

```
$ git clone https://github.com/codedx/srm-k8s
$ kubectl apply -f srm-k8s/crds/v1
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://codedx.github.io/srm-k8s -f srm-k8s/chart/values/values-to.yaml srm srm # --set openshift.createSCC=true
```

>Note: If you are using OpenShift, remove `#` when running the last command.
