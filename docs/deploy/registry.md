# Downloading Docker Images from the Synopsys SIG Docker Registry

Your SRM configuration requires you to pull SRM Docker images from the Synopsys SIG (Software Integrity Group) private Docker registry and push them to your own private registry. You can use a private registry hosted by a cloud provider (e.g., AWS, GCP, Azure, etc.) or deploy your own.

The following sections outline how to copy SRM Docker images to your private registry.

## Request access to SIG Community

If you are new to Synopsys SIG, request access to Synopsys SIG Community:

1. Go to https://community.synopsys.com/s/SelfRegistrationForm.
2. Complete and submit the registration form. You should receive access instantaneously.

## Request SIG Docker Registry Credentials

Obtain SIG docker registry credentials to provide access to download Synopsys SIG images:

1. Login to Synopsys SIG Community at https://community.synopsys.com/s/.
2. Navigate to Licenses > SRM Integrated.
3. Click View/Request Docker Registry Credential.
4. When access to the Synopsys SIG private repository is granted, continue with the next section.

## Docker Registry Login

Log on to the Synopsys SIG Docker registry and your private Docker registry with these steps:

1. Login to Synopsys SIG Community at https://community.synopsys.com/s/.
2. Navigate to Licenses > SRM Integrated.
3. Click on View/Request Docker Registry Credential to open the license pop-up. This pop-up contains
copy buttons to copy the credentials.
4. Log on to the Synopsys SIG registry using the following command, specifying the username and password you copied:
```
$ docker login sig-repo.synopsys.com
```
5. Log on to your private registry:
```
$ docker login your.private.registry
```

## Obtain Docker Images

You must [pull, tag, and push](https://docs.docker.com/registry/deploying/#copy-an-image-from-docker-hub-to-your-registry) each SRM Docker image that your SRM deployment requires.

### Example Pull/Tag/Push

The following example commands use a fictitious private registry hosted in AWS at id.dkr.ecr.us-east-2.amazonaws.com.

The first example stores Synopsys Docker images at the root of your private registry:

```
$ docker pull sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2024.6.0
$ docker tag sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2024.6.0 id.dkr.ecr.us-east-2.amazonaws.com/codedx/codedx-tomcat:v2024.6.0
$ docker push id.dkr.ecr.us-east-2.amazonaws.com/codedx/codedx-tomcat:v2024.6.0
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

The following example stores Synopsys Docker images under "my-srm" in your private registry. In this scenario, you must enter "my-srm" as your private registry repository prefix in the Guided Setup:

```
$ docker pull sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2024.6.0
$ docker tag sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2024.6.0 id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat:v2024.6.0
$ docker push id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat:v2024.6.0
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

See the following sections for the Docker images you must obtain via docker pull/tag/push commands. Pattern your commands after the above examples and run pull/tag/push for each Docker image your SRM deployment requires.

### SRM Web Docker images

The SRM Web pod requires this Docker image:

- sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2024.6.0

You can use this PowerShell script below to pull, tag, and push the above Synopsys Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-tomcat:v2024.6.0' | ForEach-Object {

   docker pull "sig-repo.synopsys.com/synopsys/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "sig-repo.synopsys.com/synopsys/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### SRM Database Docker images

If you are using an external SRM database, skip this section.

The SRM Database pod requires this Docker image:

- sig-repo.synopsys.com/synopsys/codedx/codedx-mariadb:v1.31.0

You can use this PowerShell script below to pull, tag, and push the above Synopsys Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-mariadb:v1.31.0' | ForEach-Object {

   docker pull "sig-repo.synopsys.com/synopsys/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "sig-repo.synopsys.com/synopsys/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### SRM Scan Farm Docker images

If you are not using the SRM Scan Farm feature, skip this section.

The SRM Scan Farm feature requires these Docker images:

- sig-repo.synopsys.com/synopsys/cnc-cache-service:2024.3.0
- sig-repo.synopsys.com/synopsys/cnc-common-infra:2024.3.0
- sig-repo.synopsys.com/synopsys/cnc-scan-service:2024.3.0
- sig-repo.synopsys.com/synopsys/cnc-scan-service-migration:2024.3.0
- sig-repo.synopsys.com/synopsys/cnc-storage-service:2024.3.0
- sig-repo.synopsys.com/synopsys/cnc-storage-service-migration:2024.3.0
- sig-repo.synopsys.com/synopsys/cnc-job-runner:2024.3.0

You can use this PowerShell script below to pull, tag, and push the above Synopsys Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'cnc-cache-service:2024.3.0',
'cnc-common-infra:2024.3.0',
'cnc-scan-service:2024.3.0',
'cnc-scan-service-migration:2024.3.0',
'cnc-storage-service:2024.3.0',
'cnc-storage-service-migration:2024.3.0',
'cnc-job-runner:2024.3.0' | ForEach-Object {

   docker pull "sig-repo.synopsys.com/synopsys/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "sig-repo.synopsys.com/synopsys/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### SRM Tool Orchestration Docker images

If you are not using the SRM Tool Orchestration feature, skip this section.

The SRM Tool Orchestration feature requires these Docker images:

- sig-repo.synopsys.com/synopsys/codedx/codedx-tools:v2024.6.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-toolsmono:v2024.6.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-prepare:v2.0.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-newanalysis:v2.0.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-results:v2.0.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-tool-service:v2.0.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-cleanup:v2.0.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-workflow-controller:v3.0.0
- sig-repo.synopsys.com/synopsys/codedx/codedx-argoexec:v3.0.0
- sig-repo.synopsys.com/synopsys/bitnami/minio:2021.4.6-debian-10-r11 (when not using external workflow storage)

You can use this PowerShell script below to pull, tag, and push the above Synopsys Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-tools:v2024.6.0',
'codedx/codedx-toolsmono:v2024.6.0',
'codedx/codedx-prepare:v2.0.0',
'codedx/codedx-newanalysis:v2.0.0',
'codedx/codedx-results:v2.0.0',
'codedx/codedx-tool-service:v2.0.0',
'codedx/codedx-cleanup:v2.0.0',
'bitnami/minio:2021.4.6-debian-10-r11',
'codedx/codedx-workflow-controller:v3.0.0',
'codedx/codedx-argoexec:v3.0.0' | ForEach-Object {

   docker pull "sig-repo.synopsys.com/synopsys/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "sig-repo.synopsys.com/synopsys/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### Powershell Core Docker Pull/Tag/Push All Example

If you are logged in to the Synopsys SIG Docker registry and your private registry, you can use the script below to pull, tag, and push all Synopsys Docker images; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash).

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-tomcat:v2024.6.0',
'codedx/codedx-tools:v2024.6.0',
'codedx/codedx-toolsmono:v2024.6.0',
'codedx/codedx-prepare:v2.0.0',
'codedx/codedx-newanalysis:v2.0.0',
'codedx/codedx-results:v2.0.0',
'codedx/codedx-tool-service:v2.0.0',
'codedx/codedx-cleanup:v2.0.0',
'codedx/codedx-mariadb:v1.31.0',
'bitnami/minio:2021.4.6-debian-10-r11',
'codedx/codedx-workflow-controller:v3.0.0',
'codedx/codedx-argoexec:v3.0.0',
'cnc-cache-service:2024.3.0',
'cnc-common-infra:2024.3.0',
'cnc-scan-service:2024.3.0',
'cnc-scan-service-migration:2024.3.0',
'cnc-storage-service:2024.3.0',
'cnc-storage-service-migration:2024.3.0',
'cnc-job-runner:2024.3.0' | ForEach-Object {

   docker pull "sig-repo.synopsys.com/synopsys/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "sig-repo.synopsys.com/synopsys/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

## Docker Registry Logout

With your Docker images copied, log out of both registries:

```
$ docker logout sig-repo.synopsys.com
$ docker logout your.private.registry
```




