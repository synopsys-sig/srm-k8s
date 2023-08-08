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
2. Navigate to Licenses > Coverity.
3. Click View/Request Docker Registry Credential.
4. When access to the Synopsys SIG private repository is granted, continue with the next section.

## Docker Registry Login

Copy the Synopsys SIG Docker images to your private registry with these steps:

1. Login to Synopsys SIG Community at https://community.synopsys.com/s/.
2. Navigate to Licenses > SRM.
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
$ docker pull sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2023.8.0
$ docker tag sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2023.8.0 id.dkr.ecr.us-east-2.amazonaws.com/codedx/codedx-tomcat:v2023.8.0
$ docker push id.dkr.ecr.us-east-2.amazonaws.com/codedx/codedx-tomcat:v2023.8.0
```

The following example stores Synopsys Docker images under "my-srm" in your private registry. In this scenario, you must enter "my-srm" as your private registry repository prefix in the Guided Setup:

```
$ docker pull sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2023.8.0
$ docker tag sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2023.8.0 id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat:v2023.8.0
$ docker push id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat:v2023.8.0
```

See the following sections for the Docker images you must obtain via docker pull/tag/push commands. Pattern your commands after the above examples and run pull/tag/push for each Docker image your SRM deployment requires.

### SRM Web Docker images

The SRM Web pod requires this Docker image:

- codedx/codedx-tomcat:v2023.8.0

### SRM Database Docker images

If you are using an external SRM database, skip this section.

The SRM Database pod requires this Docker image:

- codedx/codedx-mariadb:v1.24.0

### SRM Scan Farm Docker images

If you are not using the SRM Scan Farm feature, skip this section.

The SRM Scan Farm feature requires these Docker images:

- cnc-cache-service:version
- cnc-common-infra:version
- cnc-scan-service:version
- cnc-scan-service-migration:version
- cnc-storage-service:version
- cnc-storage-service-migration:version

The SRM Scan Farm SAST feature requires these Docker images:

- cnc-cov-capture-linux64-\<cov-version>:version
- cnc-cov-analysis-linux64-\<cov-version>:version

>Note: Replace the Coverity version placeholder (e.g. 2023.6.1).

The SRM Scan Farm SCA feature requires this Docker image:

- cnc-synopsys-detect-\<detect-version>:version

>Note: Replace the Detect version placeholder (e.g. 8.9.0).

### SRM Tool Orchestration Docker images

If you are not using the SRM Tool Orchestration feature, skip this section.

The SRM Tool Orchestration feature requires these Docker images:

- codedx/codedx-tools:v2023.8.0
- codedx/codedx-toolsmono:v2023.8.0
- codedx/codedx-prepare:v1.26.0
- codedx/codedx-newanalysis:v1.26.0
- codedx/codedx-results:v1.26.0
- codedx/codedx-error-results:v1.26.0
- codedx/codedx-tool-service:v1.26.0
- codedx/codedx-cleanup:v1.26.0
- codedx/codedx-workflow-controller:v2.17.0
- codedx/codedx-argoexec:v2.17.0
- bitnami/minio:2021.4.6-debian-10-r11 (when not using external workflow storage)

## Docker Registry Logout

With your Docker images copied, log out of both registries:

```
$ docker logout sig-repo.synopsys.com
$ docker logout your.private.registry
```




