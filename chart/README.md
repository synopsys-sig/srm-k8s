# Software Risk Manager (SRM)

![Version: 1.4.0](https://img.shields.io/badge/Version-1.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2023.8.4](https://img.shields.io/badge/AppVersion-2023.8.4-informational?style=flat-square)

## Requirements

| Repository | Name | Version |
|:---|:---|:---|
| https://codedx.github.io/codedx-kubernetes | argo | 0.14.5 |
| https://codedx.github.io/codedx-kubernetes | mariadb | 7.4.4 |
| https://codedx.github.io/codedx-kubernetes | minio | 3.2.1 |
| https://sig-repo.synopsys.com/artifactory/sig-cloudnative | cnc | 2023.6.1 |

## Values

| Key | Type | Default | Description |
|:---|:---|:---|:---|
| argo.controller.containerRuntimeExecutor | string | `"pns"` | the runtime executor for the Argo workflow |
| argo.controller.extraEnv[0] | object | `{ "name" : "RECENTLY_STARTED_POD_DURATION" , "value" : "10s" }` | the list of extra environment variables for the Argo workflow controller |
| argo.controller.instanceID.enabled | bool | `true` | whether the Argo workflow controller uses an instance ID |
| argo.controller.instanceID.useReleaseName | bool | `true` | whether the Argo workflow controller instance ID uses the release name |
| argo.controller.nodeSelector | object | `{}` | the node selector for the Argo workflow controller |
| argo.controller.pdb.enabled | bool | `false` | whether to create a pod disruption budget for the Argo component (a workflow controller can tolerate occasional downtime) |
| argo.controller.priorityClassValue | int | `10100` | the Argo priority value, which must be set relative to other Tool Orchestration component priority values |
| argo.controller.resources.limits.cpu | string | `"500m"` | the required CPU for the Argo workload |
| argo.controller.resources.limits.memory | string | `"500Mi"` | the required memory for the Argo workload |
| argo.controller.tolerations | list | `[]` | the pod tolerations for the Argo component |
| argo.images.controller | string | `"codedx-workflow-controller"` | the Docker image repository name for the Argo controller |
| argo.images.executor | string | `"codedx-argoexec"` | the Docker image repository name for the Argo executor |
| argo.images.namespace | string | `"codedx"` | the Docker image repository prefix for the Argo Docker images |
| argo.images.pullSecrets | list | `[]` | the K8s image pull secret to use for Argo Docker images |
| argo.images.tag | string | `"v2.17.0"` | the Docker image version for the Argo workload |
| cnc.cnc-common-infra.cleanupSchedule | string | `"*/55 * * * *"` | the schedule to use for the cleanup cronjob - must be a valid schedule for a K8s cronjob |
| cnc.imagePullPolicy | string | `"Always"` | the image pull policy for scan farm components |
| cnc.scanfarm.srm.port | string | `"9090"` | the port number of the SRM web service |
| features.mariadb | bool | `true` | whether to enable the on-cluster MariaDB; an external database must be used otherwise |
| features.minio | bool | `false` | whether to enable the on-cluster MinIO for the SRM Tool Orchestration feature; an external object storage system must be used otherwise |
| features.scanfarm | bool | `false` | whether to enable the Scan Farm feature, which requires an SRM Scan Farm license |
| features.to | bool | `false` | whether to enable the Tool Orchestration feature, which requires an SRM Tool Orchestration license |
| imagePullSecrets | list | `[]` | the K8s image pull secret to use for SRM Docker images Command: kubectl create secret docker-registry private-registry --docker-server=your-registry-server --docker-username=your-username --docker-password=your-password --docker-email=your-email |
| ingress.annotations.scanfarm.cache "nginx.ingress.kubernetes.io/backend-protocol" | string | `"HTTPS"` | the protocol for the K8s cache service |
| ingress.annotations.scanfarm.cache "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | the max proxy body size for the cache service ingress (no max when 0) |
| ingress.annotations.scanfarm.scan "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | the max proxy body size for the scan service ingress (no max when 0) |
| ingress.annotations.scanfarm.storage "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | the max proxy body size for the storage service ingress (no max when 0) |
| ingress.annotations.web "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"0"` | the max proxy body size for the web component ingress (no max when 0) |
| ingress.annotations.web "nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"3600"` | the proxy read timeout for the web component ingress |
| ingress.className | string | `"nginx"` | the class name for the SRM ingress |
| ingress.enabled | bool | `false` | whether to enable an SRM ingress (required for the Scan Farm feature) |
| ingress.hosts[0] | object | `{"host":"chart-example.local"}` | the host to associate with the SRM ingress |
| ingress.tls | list | `[]` | the TLS configuration for the SRM ingress |
| mariadb.db.name | string | `"codedx"` | the on-cluster database catalog name for SRM web (must be codedx) |
| mariadb.db.user | string | `"codedx"` | the on-cluster database username for SRM web (must be codedx) |
| mariadb.existingSecret | string | `""` | the K8s secret name containing the on-cluster MariaDB root and user passwords with required fields mariadb-root-password and mariadb-password Command: kubectl -n srm create secret generic srm-mariadb-secret --from-literal mariadb-root-password=password --from-literal mariadb-password=password |
| mariadb.image.pullPolicy | string | `"IfNotPresent"` | the K8s Docker image pull policy for the MariaDB workload |
| mariadb.image.pullSecrets | list | `[]` | the K8s image pull secret to use for MariaDB Docker images |
| mariadb.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the MariaDB Docker image |
| mariadb.image.repository | string | `"codedx/codedx-mariadb"` | the Docker image repository name for the MariaDB workload |
| mariadb.image.tag | string | `"v1.25.0"` | the Docker image version for the MariaDB workload |
| mariadb.master.masterCaConfigMap | string | `nil` | the configmap name containing the CA cert with required field ca.crt Command: kubectl -n srm create configmap master-ca-configmap --from-file ca.crt=/path/to/ca.crt |
| mariadb.master.masterTlsSecret | string | `nil` | the K8s secret name containing the public and private TLS key with required fields tls.crt and tls.key Command: kubectl -n srm create secret tls master-tls-secret --cert=path/to/cert-file --key=path/to/key-file |
| mariadb.master.nodeSelector | object | `{}` | the node selector to use for the MariaDB primary database workload |
| mariadb.master.persistence.existingClaim | string | `nil` | the existing claim to use for the MariaDB primary persistent volume; a new persistent volume is generated when unset |
| mariadb.master.persistence.size | string | `"64Gi"` | the size of the MariaDB persistent volume  |
| mariadb.master.persistence.storageClass | string | `nil` | the storage class name for the MariaDB primary persistent volume; the default storage class used when unset |
| mariadb.master.podDisruptionBudget.enabled | bool | `false` | whether to create a pod disruption budget for the MariaDB primary database component |
| mariadb.master.podDisruptionBudget.maxUnavailable | int | `0` | the maximum number of unavailable instances of the MariaDB primary database component |
| mariadb.master.priorityClass.create | bool | `false` | whether to create a PriorityClass resource for the MariaDB primary database component |
| mariadb.master.priorityClass.value | int | `10200` | the MariaDB primary database component priority value, which must be set relative to other Tool Orchestration component priority values |
| mariadb.master.resources.limits.cpu | string | `"1000m"` | the required CPU for the MariaDB primary database workload |
| mariadb.master.resources.limits.memory | string | `"8192Mi"` | the required memory for the MariaDB primary database workload |
| mariadb.master.tolerations | list | `[]` | the pod tolerations for the MariaDB primary database component |
| mariadb.replication.enabled | bool | `false` | whether to enable MariaDB replication |
| mariadb.serviceAccount.create | bool | `true` | whether to create a service account for the MariaDB service |
| mariadb.slave.annotations."backup.codedx.io/type" | string | `"none"` | the annotations for the MariaDB replica database component |
| mariadb.slave.nodeSelector | object | `{}` | the node selector to use for the MariaDB replica database workload |
| mariadb.slave.persistence.backup.size | string | `"64Gi"` | the size of the backup persistent volume |
| mariadb.slave.persistence.size | string | `"64Gi"` | the size of the MariaDB replica database persistent volume |
| mariadb.slave.persistence.storageClass | string | `nil` | the storage class name for the MariaDB replica persistent volume; the default storage class used when unset |
| mariadb.slave.podDisruptionBudget.enabled | bool | `false` | whether to create a pod disruption budget for the MariaDB replica database component |
| mariadb.slave.podDisruptionBudget.minAvailable | int | `1` | the minimum number of available instances of the MariaDB replica database component |
| mariadb.slave.priorityClass.create | bool | `false` | whether to create a PriorityClass resource for the MariaDB replica database component |
| mariadb.slave.priorityClass.value | int | `10200` | the MariaDB replica database component priority value, which must be set relative to other Tool Orchestration component priority values |
| mariadb.slave.replicas | int | `1` | the number of replica database workloads |
| mariadb.slave.resources.limits.cpu | string | `"1000m"` | the required CPU for the MariaDB replica database workload |
| mariadb.slave.resources.limits.memory | string | `"8192Mi"` | the required memory for the MariaDB replica database workload |
| mariadb.slave.tolerations | list | `[]` | the pod tolerations for the MariaDB replica database component |
| minio.enabled | bool | `true` | whether to enable the on-cluster MinIO component |
| minio.global.minio.existingSecret | string | `nil` | the K8s secret name with the MinIO access and secret key with required fields access-key and secret-key Command: kubectl -n srm create secret generic minio-secret --from-literal=access-key=admin --from-literal=secret-key=password |
| minio.image.pullSecrets | list | `[]` | the K8s Docker image pull policy for the MinIO workload |
| minio.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the MinIO Docker image |
| minio.image.repository | string | `"bitnami/minio"` | the Docker image repository name for the MinIO workload |
| minio.image.tag | string | `"2021.4.6-debian-10-r11"` | the Docker image version for the MinIO workload (tag '2021.4.6-debian-10-r11' predates license change) |
| minio.nodeSelector | object | `{}` | the node selector to use for the MinIO workload |
| minio.persistence.existingClaim | string | `nil` | the existing claim to use for the MinIO persistent volume; a new persistent volume is generated when unset |
| minio.persistence.size | string | `"64Gi"` | the size of the MinIO persistent volume  |
| minio.persistence.storageClass | string | `nil` | the storage class name for the MinIO persistent volume; the default storage class used when unset |
| minio.podAnnotations | object | `{}` | the pod annotations to use for the MinIO pod |
| minio.podDisruptionBudget.enabled | bool | `true` | whether to create a pod disruption budget for the MinIO component |
| minio.podDisruptionBudget.maxUnavailable | int | `0` | the maximum number of unavailable instances of the MinIO component |
| minio.priorityClassValue | int | `10100` | the MinIO component priority value, which must be set relative to other Tool Orchestration component priority values |
| minio.resources.limits.cpu | string | `"2000m"` | the required CPU for the MinIO workload |
| minio.resources.limits.memory | string | `"500Mi"` | the required memory for the MinIO workload |
| minio.tlsSecret | string | `nil` | the K8s secret name for web component TLS with required fields tls.crt and tls.key |
| minio.tolerations | list | `[]` | the pod tolerations for the MinIO component |
| networkPolicy.enabled | bool | `false` | whether to enable network policies for SRM components that support network policy |
| networkPolicy.k8sApiPort | int | `443` | the port for the K8s API, required when using the Tool Orchestration feature |
| networkPolicy.web.egress.extraPorts.tcp | list | `[22,53,80,389,443,636,7990,7999]` | the TCP ports allowed for egress from the web component |
| networkPolicy.web.egress.extraPorts.udp | list | `[53,389,636,3269]` | the UDP ports allowed for egress from the web component |
| openshift.createSCC | bool | `false` | whether to create SecurityContextConstraint resources, which is required when using OpenShift |
| to.caConfigMap | string | `nil` | the configmap name containing the CA cert with required field ca.crt |
| to.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the SRM Tool Orchestration Docker images |
| to.image.repository.helmPreDelete | string | `"codedx/codedx-cleanup"` | the Docker image repository name for the SRM cleanup workload |
| to.image.repository.newAnalysis | string | `"codedx/codedx-newanalysis"` | the Docker image repository name for the SRM new-analysis workload |
| to.image.repository.prepare | string | `"codedx/codedx-prepare"` | the Docker image repository name for the SRM prepare workload |
| to.image.repository.sendErrorResults | string | `"codedx/codedx-error-results"` | the Docker image repository name for the SRM send-error-results workload |
| to.image.repository.sendResults | string | `"codedx/codedx-results"` | the Docker image repository name for the SRM send-results workload |
| to.image.repository.toolService | string | `"codedx/codedx-tool-service"` | the Docker image repository name for the SRM tool service workload |
| to.image.repository.tools | string | `"codedx/codedx-tools"` | the Docker image repository name for the SRM tools workload |
| to.image.repository.toolsMono | string | `"codedx/codedx-toolsmono"` | the Docker image repository name for the SRM toolsmono workload |
| to.image.tag | string | `"v1.27.0"` | the Docker image version for the SRM Tool Orchestration workloads |
| to.logs.maxBackups | int | `20` | the maximum number of tool service log files to retain |
| to.logs.maxSizeMB | int | `10` | the maximum size of a tool service log file |
| to.minimumWorkflowStepRunTimeSeconds | int | `3` | the minimum seconds for an orchestrated analysis workflow step |
| to.nodeSelector | object | `{}` | the node selector to use for the tool service |
| to.podDisruptionBudget.enabled | bool | `true` | whether to create a pod disruption budget for the tool service |
| to.podDisruptionBudget.minAvailable | int | `1` | the minimum number of available instances of the tool service |
| to.priorityClass.serviceValue | int | `10100` | the tool service priority value, which must be set relative to other Tool Orchestration component priority values |
| to.priorityClass.workflowValue | int | `10000` | the tool workflow priority value, which must be set relative to other Tool Orchestration component priority values |
| to.resources.limits.cpu | string | `"1000m"` | the required CPU for the tool service workload |
| to.resources.limits.memory | string | `"1024Mi"` | the required memory for the tool service workload |
| to.service.numReplicas | int | `1` | the number of tool service replicas |
| to.service.toolServicePort | int | `3333` | the tool service port number |
| to.service.type | string | `"ClusterIP"` | the K8s service type for the tool service |
| to.serviceAccount.annotations | object | `{}` | the annotations to apply to the SRM tool service account |
| to.serviceAccount.create | bool | `true` | whether to create a service account for the tool service |
| to.serviceAccount.name | string | `nil` | the name of the service account to use; a name is generated using the fullname template when unset and create is true |
| to.tlsSecret | string | `nil` | the K8s secret name for tool service TLS with required fields tls.crt and tls.key Command: kubectl -n srm create secret tls to-tls-secret --cert=path/to/cert-file --key=path/to/key-file |
| to.toSecret | string | `nil` | the K8s secret name containing the API key for the tool service with required field api-key Command: kubectl -n srm create secret generic tool-service-pd --from-literal api-key=password |
| to.tolerations | list | `[]` | the pod tolerations for the tool service component |
| to.toolServicePort | int | `3333` | the port number for the tool service |
| to.tools.limits.tool.cpu | string | `"2"` | the default CPU limit for the tool workloads |
| to.tools.limits.tool.memory | string | `"2G"` | the default memory limit for the tool workloads |
| to.tools.nodeSelectorKey | string | `nil` | the node selector key to use for tool pods |
| to.tools.nodeSelectorValue | string | `nil` | the node selector key value to use for tool pods |
| to.tools.podTolerationKey | string | `nil` | the pod toleration key to use for tool pods |
| to.tools.podTolerationValue | string | `nil` | the pod toleration key value to use for tool pods |
| to.tools.requests.tool.cpu | string | `"500m"` | the default CPU request for the tool workloads |
| to.tools.requests.tool.memory | string | `"500Mi"` | the default memory request for the tool workloads |
| to.workflowStorage.bucketName | string | `"code-dx-storage"` | the name of workflow storage bucket that will store workflow files. This should be an existing bucket when the account associated  with the storage credentials cannot create the bucket on its own. |
| to.workflowStorage.configMapName | string | `""` | the K8s configmap name that contains certificate data that should be explicitly trusted when connecting to workflow storage. Use configMapName when the workflow storage server's certificate was not issued by a well known CA. |
| to.workflowStorage.configMapPublicCertKeyName | string | `""` | the key name in the configMapName ConfigMap containing the certificate data. |
| to.workflowStorage.endpoint | string | `nil` | the workflow storage endpoint to use, either an external endpoint (e.g., AWS, GCP) or the older, bundled MinIO instance. Specify the hostname and port (e.g., hostname:port). |
| to.workflowStorage.endpointSecure | string | `nil` | whether the endpoint is secured with HTTPS. |
| to.workflowStorage.existingSecret | string | `nil` | whether to use an existing secret, with fields access-key and secret-key, for the storage credential. The credential must be able to create and delete objects in the bucket given by the 'bucketName' parameter. |
| web.authentication.saml.appName | string | `nil` | the application/client name for the SRM SAML registration |
| web.authentication.saml.enabled | bool | `false` | whether to use SAML authentication |
| web.authentication.saml.hostBasePath | string | `nil` | the host base path for the SRM SAML registration (https://mysrmhost/srm) |
| web.authentication.saml.samlIdpXmlFileConfigMap | string | `nil` | the configmap name containing the IdP metadata file with required field saml-idp.xml |
| web.authentication.saml.samlSecret | string | `""` | the K8s secret name containing the SAML keystore passwords with required field saml-keystore.props that contains a HOCON-formatted file with SRM props auth.saml2.keystorePassword and auth.saml2.privateKeyPassword File: auth.saml2.keystorePassword = """keystore-password""" auth.saml2.privateKeyPassword = """private-key-password""" |
| web.cacertsSecret | string | `""` | the K8s secret name containing the Java keystore contents and its password with required fields cacerts and cacerts-password Note: cacerts must trust the database cert when using 'REQUIRE SSL' with an external database Command: kubectl -n srm create secret generic srm-web-cacerts-secret --from-file cacerts=./cacerts --from-literal cacerts-password=changeit |
| web.database.credentialSecret | string | `""` | the K8s secret name containing the database connection properties with required field db.props that contains a HOCON-formatted file with SRM props swa.db.user and swa.db.password File:  swa.db.user = """username""" swa.db.password = """password""" Command: kubectl -n srm create secret generic srm-web-db-cred-secret --from-file db.props=./db.props |
| web.database.externalDbUrl | string | `nil` | the URL for the external SRM web database (jdbc:mysql://my-srm-web-db-host:3306/my-srm-web-db-name?useSSL=true&requireSSL=true) |
| web.image.pullPolicy | string | `"IfNotPresent"` | the K8s Docker image pull policy for the SRM web workload |
| web.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the SRM web Docker image |
| web.image.repository | string | `"codedx/codedx-tomcat"` | the Docker image repository name for the SRM web workload |
| web.image.tag | string | `"v2023.8.4"` | the Docker image version for the SRM web workload |
| web.javaOpts | string | `"-XX:MaxRAMPercentage=90.0"` | the Java options for the SRM web workload |
| web.licenseSecret | string | `""` | the K8s secret name containing the SRM license password with required field license.lic Command: kubectl -n srm create secret generic srm-web-license-secret --from-file license.lic=./license.lic |
| web.loggingConfigMap | string | `""` | the K8s configmap containing the logging configuration file with required field logback.xml Command: kubectl -n srm create configmap srm-web-logging-cfgmap --from-file logback.xml=./logback.xml |
| web.nodeSelector | object | `{}` | the node selector to use for the SRM web workload |
| web.persistence.accessMode | string | `"ReadWriteOnce"` | the access mode for the AppData persistent volume |
| web.persistence.existingClaim | string | `""` | the existing claim to use for the AppData persistent volume; a new persistent volume is generated when unset |
| web.persistence.size | string | `"64Gi"` | the size of the AppData persistent volume  |
| web.persistence.storageClass | string | `nil` | the storage class name for the AppData persistent volume; the default storage class used when unset |
| web.podAnnotations | object | `{}` | the pod annotations to use for the SRM web pod |
| web.podDisruptionBudget.enabled | bool | `false` | whether to create a pod disruption budget for the web component |
| web.podSecurityContext.fsGroup | int | `1000` | the fsGroup for the SRM web pod |
| web.podSecurityContext.runAsGroup | int | `1000` | the gid for the SRM web pod |
| web.podSecurityContext.runAsUser | int | `1000` | the uid for the SRM web pod |
| web.priorityClass.create | bool | `false` | whether to create a PriorityClass resource for the web component |
| web.priorityClass.value | int | `10100` | the web component priority value, which must be set relative to other Tool Orchestration component priority values |
| web.props.extra | list | `[]` | the list of extra resources containing SRM prop settings |
| web.props.limits.analysis.concurrent | int | `2` | the value of the SRM prop analysis.concurrent-analysis-limit, which determines the maximum number of analyses to run concurrently |
| web.props.limits.database.poolSize | int | `5` | the size of the database connection pool |
| web.props.limits.database.timeout | int | `60000` | the maximum milliseconds that a client will wait for a database connection from the pool |
| web.props.limits.jobs.cpu | int | `2000` | the value of the SRM prop swa.jobs.cpu-limit, which determines the maximum available CPU |
| web.props.limits.jobs.database | int | `2000` | the value of the SRM prop swa.jobs.database-limit, which determines the maximum available database I/O |
| web.props.limits.jobs.disk | int | `2000` | the value of the SRM prop swa.jobs.disk-limit, which determins the maximum available disk I/O |
| web.props.limits.jobs.memory | int | `2000` | the value of the SRM prop swa.jobs.memory-limit, which determines the maximum available memory |
| web.resources.limits.cpu | string | `"2000m"` | the required CPU for the web workload (must be >= 2 vCPUs and >= 4 vCPUs when using Triage Assistant) |
| web.resources.limits.ephemeral-storage | string | `"2868Mi"` | the ephemeral storage for the web workload |
| web.resources.limits.memory | string | `"8192Mi"` | the required memory for the web workload (must be >= 8192Mi and >= 16384Mi when using Triage Assistant) |
| web.scanfarm.sast.version | string | `"2023.6.1"` | the SAST component version to use for build-less scans |
| web.scanfarm.sca.version | string | `"8.9.0"` | the SCA component version to use for build-less scans |
| web.securityContext.readOnlyRootFilesystem | bool | `true` | whether the SRM web workload uses a read-only filesystem |
| web.service.annotations | object | `{}` | the annotations to apply to the SRM web service |
| web.service.port | int | `9090` | the port number of the SRM web service |
| web.service.type | string | `"ClusterIP"` | the service type of the SRM web service |
| web.serviceAccount.annotations | object | `{}` | the annotations to apply to the SRM service account |
| web.serviceAccount.create | bool | `true` | whether to create a service account for the SRM web service |
| web.serviceAccount.name | string | `""` | the name of the service account to use; a name is generated using the fullname template when unset and create is true |
| web.tlsSecret | string | `nil` | the K8s secret name for web component TLS with required fields tls.crt and tls.key Command: kubectl -n srm create secret tls web-tls-secret --cert=path/to/cert-file --key=path/to/key-file |
| web.toSecret | string | `nil` | the K8s secret name containing the API key for the Tool Orchestration tool service with required field to-key.props that contains a HOCON-formatted file with SRM prop tws.api-key File: tws.api-key = """password""" Command: kubectl -n srm create secret generic to-key-secret --from-file to-key.props=./to-key.props |
| web.tolerations | list | `[]` | the pod tolerations for the web component |
| web.webSecret | string | `""` | the K8s secret name containing the administrator password with required field admin-password Command: kubectl -n srm create secret generic srm-web-secret --from-literal admin-password=password |

----------------------------------------------
Generated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
