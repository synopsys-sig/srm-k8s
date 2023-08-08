# SRM Helm Prep Script

The Helm Prep Wizard generates a config.json file used as input to the Helm Prep script. This page documents the fields of the JSON file and can give you a sense of the types of parameter values you may be asked to provide based on how you choose to install SRM.

The Feature column indicates the feature associated with the parameter. The Helm Prep script will ignore parameter for features you are not installing.

|Parameter|Feature|Description|Example|
|:---|:---|:---|:---|
|namespace|Core|namespace for SRM components|srm
|releaseName|Core|name of SRM helm release|srm
|||||
|workDir|Core|directory to store script-generated files|~/.k8s-srm
|||||
|srmLicenseFile|Core|file path to the SRM web license file|
|scanFarmSastLicenseFile|Scan Farm|file path to the SRM SAST license file|
|scanFarmScaLicenseFile|Scan Farm|file path to the SRM SCA license file|
|||
|sigRepoUsername|Scan Farm|username for the Synopsys SIG repo|
|sigRepoPwd|Scan Farm|password for the Synopsys SIG repo|
|||||
|scanFarmDatabaseHost|Scan Farm|hostname of the scan farm PostgreSQL database|
|scanFarmDatabasePort|Scan Farm|port number of the scan farm PostgreSQL database|
|scanFarmDatabaseUser|Scan Farm|username for the scan farm PostgreSQL database|
|scanFarmDatabasePwd|Scan Farm|password for the scan farm PostgreSQL database|
|scanFarmDatabaseSslMode|Scan Farm|type of SSL config|disable|verify-ca|verify-full
|scanFarmDatabaseServerCert|Scan Farm|path to PostgreSQL database certificate|
|scanFarmScanDatabaseCatalog|Scan Farm|scan svc PostgreSQL catalog name|
|scanFarmStorageDatabaseCatalog|Scan Farm|storage svc PostgreSQL catalog name|
|||||
|scanFarmRedisHost|Scan Farm|hostname of the scan farm Redis system|
|scanFarmRedisPort|Scan Farm|port number of the scan farm Redis system|
|scanFarmRedisDatabase|Scan Farm|database to use for the scan farm|"1"
|scanFarmRedisUseAuth|Scan Farm|whether the scan farm requires authentication|"true"
|scanFarmRedisPwd|Scan Farm|optional password for scan farm Redis system|
|scanFarmRedisSecure|Scan Farm|whether the redis connection is secure|"true"
|scanFarmRedisVerifyHostname|Scan Farm|whether the redis hostname is validated|"true"
|scanFarmRedisServerCert|Scan Farm|path to Redis server cert|
|||||
|scanFarmStorageType|Scan Farm|type of scan farm object storage|AwsS3|MinIO|Gcs|Azure
|scanFarmStorageBucketName|Scan Farm|object storage bucket/container for storage svc|
|scanFarmCacheBucketName|Scan Farm|object storage bucket/container for cache svc|
|||||
|scanFarmS3UseServiceAccountName|Scan Farm S3 Storage|whether to use AWS IRSA|"false"
|scanFarmS3AccessKey|Scan Farm S3 Storage|access key to AWS S3-compatible storage|
|scanFarmS3SecretKey|Scan Farm S3 Storage|secret key to AWS S3-compatible storage|
|scanFarmS3ServiceAccountName|Scan Farm S3 Storage|service account name for AWS IRSA|
|scanFarmS3Region|Scan Farm S3 Storage|region for AWS S3-compatible storage|us-east-1
|||||
|scanFarmGcsProjectName|Scan Farm GCS Storage|name of the GCP project for GCS storage|
|scanFarmGcsSvcAccountKey|Scan Farm GCS Storage|name of the GCP service account for GCS storage|
|||||
|scanFarmAzureStorageAccount|Scan Farm Blob Storage|name of storage account containing Azure blobs|"srmstoragetest"
|scanFarmAzureStorageAccountKey|Scan Farm Blob Storage|name of key for access to Azure storage account|"EjZdxX/H"
|scanFarmAzureSubscriptionId|Scan Farm Blob Storage|identifier of Azure subscription|"c4dcc882-b83d-47cf-8f9e-234b963736a2"
|scanFarmAzureTenantId|Scan Farm Blob Storage|identifier of Azure AD tenant|"6315cfb3-02f0-4651-828f-06a3ac065b32"
|scanFarmAzureResourceGroup|Scan Farm Blob Storage|resource group containing Azure storage account|"srmresourcegroup"
|scanFarmAzureEndpoint|Scan Farm Blob Storage|blob service URL for Azure storage account|https://srmstoragetest.blob.core.|windows.net/
|scanFarmAzureClientId|Scan Farm Blob Storage|client identifier of Azure AD app|"9b1f8b8d-db8f-4683-8023-2dd7962b1e96"
|scanFarmAzureClientSecret|Scan Farm Blob Storage|client secret for Azure AD app|"S.68Q~"
|||||
|scanFarmMinIOHostname|Scan Farm MinIO Storage|hostname of MinIO server|
|scanFarmMinIOPort|Scan Farm MinIO Storage|port of MinIO server|
|scanFarmMinIORootUsername|Scan Farm MinIO Storage|root username of MinIO server|
|scanFarmMinIORootPwd|Scan Farm MinIO Storage|root pwd of MinIO server|
|scanFarmMinIOSecure|Scan Farm MinIO Storage|whether the MinIO server connection is secure|
|scanFarmMinIOVerifyHostname|Scan Farm MinIO Storage|whether to verify the MinIO hostname|
|scanFarmMinIOServerCert|Scan Farm MinIO Storage|path to MinIO server certificate|
|||||
|scanFarmStorageHasInClusterUrl|Scan Farm MinIO Storage|whether the storage system has an in-cluster URL|
|scanFarmStorageInClusterUrl|Scan Farm MinIO Storage|the storage system in-cluster URL|
|||||
|useGeneratedPwds|Core|whether to generate specific SRM passwords|
|mariadbRootPwd|On-Cluster DB|root password for the on-cluster database|
|mariadbReplicatorPwd|On-Cluster DB|replicator password for the on-cluster database|
|srmDatabaseUserPwd|On-Cluster DB|srm web user password for the on-cluster database|
|adminPwd|Core|initial srm web admin password|
|toolServiceApiKey|Tool Orchestration|tool service API key|
|minioAdminPwd|Tool Orchestration|password for the workflow MinIO system|
|||||
|k8sProvider|Core|type of K8s provider|
|kubeApiTargetPort|Network Policy|port number for K8s API port|
|||||
|clusterCertificateAuthorityCertPath|TLS|path for the cluster certificate issuer|
|csrSignerName|TLS|signer name for the cert-manager CSR|
|||||
|createSCCs|OpenShift|whether to create Security Context Constraints (OpenShift)|
|||||
|scanFarmType|Scan Farm|type of Scan Farm deployment|None|Sast|Sca|All
|||||
|skipDatabase|Core|whether to use the on-cluster database|
|useTriageAssistant|ML|whether to use the SRM ML feature|
|skipScanFarm|Scan Farm|whether to install the SRM scan farm|
|skipToolOrchestration|Tool Orchestration|whether to install the Tool Orchestration feature|
|skipMinIO|Tool Orchestration|whether to use MinIO for workflow storage|
|skipNetworkPolicies|Network Policy|whether to use Network Policies for specific components|
|skipTls|TLS|whether to use TLS for specific components|
|||||
|toolServiceReplicas|Tool Orchestration|number of tool service replicas|
|||||
|dbSlaveReplicaCount|On-Cluster DB|number of on-cluster database replicas|
|||||
|externalDatabaseHost|External DB|hostname of the external database|
|externalDatabasePort|External DB|port number of the external database|
|externalDatabaseName|External DB|name of database catalog for the external database|
|externalDatabaseUser|External DB|username for external database|
|externalDatabasePwd|External DB|password for accessing external database|
|externalDatabaseSkipTls|External DB|whether to skip TLS configuration for external database|
|externalDatabaseTrustCert|External DB|whether to trust the external database certificate|
|externalDatabaseServerCert|External DB|path to the external database certificate|
|||||
|externalWorkflowStorageEndpoint|Tool Orchestration|endpoint for external workflow storage|
|externalWorkflowStorageEndpointSecure|Tool Orchestration|whether workflow storage endpoint is secure|
|externalWorkflowStorageUsername|Tool Orchestration|username for external workflow storage|
|externalWorkflowStoragePwd|Tool Orchestration|password for external workflow storage|
|externalWorkflowStorageBucketName|Tool Orchestration|name of bucket in external workflow storage|
|externalWorkflowStorageTrustCert|Tool Orchestration|whether to trust workflow storage certificate|
|externalWorkflowStorageCertChainPath|Tool Orchestration|path to the external workflow storage certificate|
|||||
|addExtraCertificates|Core|whether to trust extra certificates|
|extraTrustedCaCertPaths|Core|array of paths to certificates to trust|
|||||
|webServiceType|Core|type of K8s service for SRM web service|
|webServicePortNumber|Core|port number for SRM web service|
|webServiceAnnotations|Core|annotations for SRM web service|
|||||
|skipIngressEnabled|Ingress|whether to skip SRM ingress|
|ingressType|Ingress|type of SRM ingress|
|ingressClassName|Ingress|name of ingress class|
|ingressAnnotations|Ingress|annotations for SRM ingress|
|ingressHostname|Ingress|hostname associated with SRM ingress|
|ingressTlsSecretName|Ingress|name of K8s secret containing ingress TLS configuration|
|ingressTlsType|Ingress|type of TLS ingress configuration|None|CertManagerIssuer|CertManagerClusterIsser|ExternalSecret
|||||
|useSaml|SAML|whether to use SAML|
|useLdap|LDAP|whether to use LDAP|
|samlHostBasePath|SAML|base HTTP path for SRM web|https://www.codedx.io/srm
|samlIdentityProviderMetadataPath|SAML|path to the SAML IdP|
|samlAppName|SAML|name of SAML app/entity|
|samlKeystorePwd|SAML|password to protect SAML-related Java keystore|
|samlPrivateKeyPwd|SAML|password to protect SAML-related Java keystore key|
|||||
|skipDockerRegistryCredential|Core (Required w/ Scan Farm)|whether to create K8s Image Pull Secret|
|dockerImagePullSecretName|Core (Required w/ Scan Farm)|name of K8s Image Pull Secret|
|dockerRegistry|Core (Required w/ Scan Farm)|name of Docker registry|gcr.io
|dockerRegistryUser|Core (Required w/ Scan Farm)|username to access Docker registry|
|dockerRegistryPwd|Core (Required w/ Scan Farm)|password to access Docker registry|
|||||
|useDefaultDockerImages|Core|whether to use default Docker image versions|
|imageVersionWeb|Core|SRM web Docker image version|
|imageVersionMariaDB|Core|On-Cluster MariaDB Docker image version|
|imageVersionTo|Core|Tool Orchestration Docker image version|
|imageVersionMinio|Core|MinIO Docker image version|
|imageVersionWorkflow|Core|Argo workflow Docker image version|
|||||
|useDockerRedirection|Core (Required w/ Scan Farm)|whether to use private Docker registry|"true"
|useDockerRepositoryPrefix|Core|whether to include a private Docker registry prefix|"true"
|dockerRepositoryPrefix|Core|prefix for Docker registry|"my-srm"
|||||
|useDefaultCACerts|Core|whether to use default cacerts file|
|caCertsFilePath|Core|path to custom Java cacerts file|
|caCertsFilePwd|Core|password to access custom Java cacerts file|
|||||
|useCPUDefaults|Core|whether to use default CPU reservations|
|webCPUReservation|Core|reservation for SRM Web CPU|
|dbMasterCPUReservation|On-Cluster DB|reservation for On-Cluster primary database CPU|
|dbSlaveCPUReservation|On-Cluster DB|reservation for On-Cluster secondary database CPU|
|toolServiceCPUReservation|Tool Orchestration|reservation for Tool Service CPU|
|minioCPUReservation|Tool Orchestration|reservation for MinIO CPU|
|workflowCPUReservation|Tool Orchestration|reservation for Argo workflow CPU|
|||||
|useMemoryDefaults|Core|whether to use default memory reservations|
|webMemoryReservation|Core|reservation for SRM Web memory|
|dbMasterMemoryReservation|On-Cluster DB|reservation for On-Cluster primary database memory|
|dbSlaveMemoryReservation|On-Cluster DB|reservation for On-Cluster secondary database memory|
|toolServiceMemoryReservation|Tool Orchestration|reservation for Tool Service memory|
|minioMemoryReservation|Tool Orchestration|reservation for MinIO memory|
|workflowMemoryReservation|Tool Orchestration|reservation for Argo workflow memory|
|||||
|useEphemeralStorageDefaults|Core|whether to use default ephemeral storage reservations|
|webEphemeralStorageReservation|Core|reservation for SRM Web ephemeral storage|
|dbMasterEphemeralStorageReservation|On-Cluster DB|reservation for On-Cluster primary database ephemeral storage|
|dbSlaveEphemeralStorageReservation|On-Cluster DB|reservation for On-Cluster secondary database ephemeral storage|
|toolServiceEphemeralStorageReservation|Tool Orchestration|reservation for Tool Service ephemeral storage|
|minioEphemeralStorageReservation|Tool Orchestration|reservation for MinIO ephemeral storage|
|workflowEphemeralStorageReservation|Tool Orchestration|reservation for Argo workflow ephemeral storage|
|||||
|useVolumeSizeDefaults|Core|whether to use default Volume sizes|
|webVolumeSizeGiB|Core|size of SRM Web volume|
|dbVolumeSizeGiB|On-Cluster DB|size of On-Cluster primary database volume|
|dbSlaveVolumeSizeGiB|On-Cluster DB|size of On-Cluster replica database volume|
|dbSlaveBackupVolumeSizeGiB|On-Cluster DB|size of On-Cluster replica backup database volume|
|minioVolumeSizeGiB|Tool Orchestration|size of MinIO volume|
|storageClassName|Tool Orchestration|name of storage class for all volumes|
|||||
|useNodeSelectors|Core|whether to use node selectors|
|webNodeSelector|Core|node selector for SRM Web|
|masterDatabaseNodeSelector|On-Cluster DB|node selector for On-Cluster primary database|
|subordinateDatabaseNodeSelector|On-Cluster DB|node selector for On-Cluster replica database|
|toolServiceNodeSelector|Tool Orchestration|node selector for Tool Service|
|minioNodeSelector|Tool Orchestration|node selector for MinIO|
|workflowControllerNodeSelector|Tool Orchestration|node selector for Argo workflow controller|
|toolNodeSelector|Tool Orchestration|node selector for Tool Orchestration tools|
|||||
|useTolerations|Core|whether to use pod tolerations|
|webNoScheduleExecuteToleration|Core|pod toleration for SRM Web|
|masterDatabaseNoScheduleExecuteToleration|On-Cluster DB|pod toleration for On-Cluster primary database|
|subordinateDatabaseNoScheduleExecuteToleration|On-Cluster DB|pod toleration for On-Cluster replica database|
|toolServiceNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Tool Service|
|minioNoScheduleExecuteToleration|Tool Orchestration|pod toleration for MinIO|
|workflowControllerNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Argo workflow controller|
|toolNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Tool Orchestration tools|
|||||
|notes|Core|notes associated with deployment|
|||||
|scanFarmScaApiUrlOverride|Core (Dev/Test Only)|override for SCA scan farm endpoint|
