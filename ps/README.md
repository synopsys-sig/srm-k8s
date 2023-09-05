# SRM Helm Prep Script

![config.json version: 1.1.0](https://img.shields.io/badge/config.json%20version-1.1.0-informational?style=flat-square)

The Helm Prep Wizard generates a config.json file used as input to the Helm Prep script. This page documents the fields of the JSON file and can give you a sense of the types of parameter values you may be asked to provide based on how you choose to install SRM.

The Feature column indicates the feature associated with the parameter. The Helm Prep script will ignore parameter for features you are not installing.

|Parameter|Feature|Description|Example|Since|
|:---|:---|:---|:---|:---|
|namespace|Core|namespace for SRM components|srm|1.0|
|releaseName|Core|name of SRM helm release|srm|1.0|
||||||
|workDir|Core|directory to store script-generated files|~/.k8s-srm|1.0|
||||||
|srmLicenseFile|Core|file path to the SRM web license file||1.0|
|scanFarmSastLicenseFile|Scan Farm|file path to the SRM SAST license file||1.0|
|scanFarmScaLicenseFile|Scan Farm|file path to the SRM SCA license file||1.0|
||||||
|sigRepoUsername|Scan Farm|username for the Synopsys SIG repo||1.0|
|sigRepoPwd|Scan Farm|password for the Synopsys SIG repo||1.0|
||||||
|scanFarmDatabaseHost|Scan Farm|hostname of the scan farm PostgreSQL database||1.0|
|scanFarmDatabasePort|Scan Farm|port number of the scan farm PostgreSQL database||1.0|
|scanFarmDatabaseUser|Scan Farm|username for the scan farm PostgreSQL database||1.0|
|scanFarmDatabasePwd|Scan Farm|password for the scan farm PostgreSQL database||1.0|
|scanFarmDatabaseSslMode|Scan Farm|type of SSL config|disable;verify-ca;verify-full|1.0|
|scanFarmDatabaseServerCert|Scan Farm|path to PostgreSQL database certificate||1.0|
|scanFarmScanDatabaseCatalog|Scan Farm|scan svc PostgreSQL catalog name||1.0|
|scanFarmStorageDatabaseCatalog|Scan Farm|storage svc PostgreSQL catalog name||1.0|
||||||
|scanFarmRedisHost|Scan Farm|hostname of the scan farm Redis system||1.0|
|scanFarmRedisPort|Scan Farm|port number of the scan farm Redis system||1.0|
|scanFarmRedisDatabase|Scan Farm|database to use for the scan farm|"1"|1.0|
|scanFarmRedisUseAuth|Scan Farm|whether the scan farm requires authentication|"true"|1.0|
|scanFarmRedisPwd|Scan Farm|optional password for scan farm Redis system||1.0|
|scanFarmRedisSecure|Scan Farm|whether the redis connection is secure|"true"|1.0|
|scanFarmRedisVerifyHostname|Scan Farm|whether the redis hostname is validated|"true"|1.0|
|scanFarmRedisServerCert|Scan Farm|path to Redis server cert||1.0|
||||||
|scanFarmStorageType|Scan Farm|type of scan farm object storage|AwsS3;MinIO;Gcs;Azure|1.0|
|scanFarmStorageBucketName|Scan Farm|object storage bucket/container for storage svc||1.0|
|scanFarmCacheBucketName|Scan Farm|object storage bucket/container for cache svc||1.0|
||||||
|scanFarmS3UseServiceAccountName|Scan Farm S3 Storage|whether to use AWS IRSA|"false"|1.0|
|scanFarmS3AccessKey|Scan Farm S3 Storage|access key to AWS S3-compatible storage||1.0|
|scanFarmS3SecretKey|Scan Farm S3 Storage|secret key to AWS S3-compatible storage||1.0|
|scanFarmS3ServiceAccountName|Scan Farm S3 Storage|service account name for AWS IRSA||1.0|
|scanFarmS3Region|Scan Farm S3 Storage|region for AWS S3-compatible storage|us-east-1|1.0|
||||||
|scanFarmGcsProjectName|Scan Farm GCS Storage|name of the GCP project for GCS storage||1.0|
|scanFarmGcsSvcAccountKey|Scan Farm GCS Storage|name of the GCP service account for GCS storage||1.0|
||||||
|scanFarmAzureStorageAccount|Scan Farm Blob Storage|name of storage account containing Azure blobs|"srmstoragetest"|1.0|
|scanFarmAzureStorageAccountKey|Scan Farm Blob Storage|name of key for access to Azure storage account|"EjZdxX/H"|1.0|
|scanFarmAzureSubscriptionId|Scan Farm Blob Storage|identifier of Azure subscription|"c4dcc882-b83d-47cf-8f9e-234b963736a2"|1.0|
|scanFarmAzureTenantId|Scan Farm Blob Storage|identifier of Azure AD tenant|"6315cfb3-02f0-4651-828f-06a3ac065b32"|1.0|
|scanFarmAzureResourceGroup|Scan Farm Blob Storage|resource group containing Azure storage account|"srmresourcegroup"|1.0|
|scanFarmAzureEndpoint|Scan Farm Blob Storage|blob service URL for Azure storage account|https://srmstoragetest.blob.core.|windows.net/1.0|
|scanFarmAzureClientId|Scan Farm Blob Storage|client identifier of Azure AD app|"9b1f8b8d-db8f-4683-8023-2dd7962b1e96"|1.0|
|scanFarmAzureClientSecret|Scan Farm Blob Storage|client secret for Azure AD app|"S.68Q~"|1.0|
||||||
|scanFarmMinIOHostname|Scan Farm MinIO Storage|hostname of MinIO server||1.0|
|scanFarmMinIOPort|Scan Farm MinIO Storage|port of MinIO server||1.0|
|scanFarmMinIORootUsername|Scan Farm MinIO Storage|root username of MinIO server||1.0|
|scanFarmMinIORootPwd|Scan Farm MinIO Storage|root pwd of MinIO server||1.0|
|scanFarmMinIOSecure|Scan Farm MinIO Storage|whether the MinIO server connection is secure||1.0|
|scanFarmMinIOVerifyHostname|Scan Farm MinIO Storage|whether to verify the MinIO hostname||1.0|
|scanFarmMinIOServerCert|Scan Farm MinIO Storage|path to MinIO server certificate||1.0|
||||||
|scanFarmStorageHasInClusterUrl|Scan Farm MinIO Storage|whether the storage system has an in-cluster URL||1.0|
|scanFarmStorageInClusterUrl|Scan Farm MinIO Storage|the storage system in-cluster URL||1.0|
||||||
|useGeneratedPwds|Core|whether to generate specific SRM passwords||1.0|
|mariadbRootPwd|On-Cluster DB|root password for the on-cluster database||1.0|
|mariadbReplicatorPwd|On-Cluster DB|replicator password for the on-cluster database||1.0|
|srmDatabaseUserPwd|On-Cluster DB|srm web user password for the on-cluster database||1.0|
|adminPwd|Core|initial srm web admin password||1.0|
|toolServiceApiKey|Tool Orchestration|tool service API key||1.0|
|minioAdminPwd|Tool Orchestration|password for the workflow MinIO system||1.0|
||||||
|k8sProvider|Core|type of K8s provider||1.0|
|kubeApiTargetPort|Network Policy|port number for K8s API port||1.0|
||||||
|clusterCertificateAuthorityCertPath|TLS|path for the cluster certificate issuer||1.0|
|csrSignerName|TLS|signer name for the cert-manager CSR||1.0|
||||||
|createSCCs|OpenShift|whether to create Security Context Constraints (OpenShift)||1.0|
||||||
|scanFarmType|Scan Farm|type of Scan Farm deployment|None;Sast;Sca;All|1.0|
||||||
|skipDatabase|Core|whether to use the on-cluster database||1.0|
|useTriageAssistant|ML|whether to use the SRM ML feature||1.0|
|skipScanFarm|Scan Farm|whether to install the SRM scan farm||1.0|
|skipToolOrchestration|Tool Orchestration|whether to install the Tool Orchestration feature||1.0|
|skipMinIO|Tool Orchestration|whether to use MinIO for workflow storage||1.0|
|skipNetworkPolicies|Network Policy|whether to use Network Policies for specific components||1.0|
|skipTls|TLS|whether to use TLS for specific components||1.0|
||||||
|toolServiceReplicas|Tool Orchestration|number of tool service replicas||1.0|
||||||
|dbSlaveReplicaCount|On-Cluster DB|number of on-cluster database replicas||1.0|
||||||
|externalDatabaseHost|External DB|hostname of the external database||1.0|
|externalDatabasePort|External DB|port number of the external database||1.0|
|externalDatabaseName|External DB|name of database catalog for the external database||1.0|
|externalDatabaseUser|External DB|username for external database||1.0|
|externalDatabasePwd|External DB|password for accessing external database||1.0|
|externalDatabaseSkipTls|External DB|whether to skip TLS configuration for external database||1.0|
|externalDatabaseTrustCert|External DB|whether to trust the external database certificate||1.0|
|externalDatabaseServerCert|External DB|path to the external database certificate||1.0|
||||||
|externalWorkflowStorageEndpoint|Tool Orchestration|endpoint for external workflow storage||1.0|
|externalWorkflowStorageEndpointSecure|Tool Orchestration|whether workflow storage endpoint is secure||1.0|
|externalWorkflowStorageUsername|Tool Orchestration|username for external workflow storage||1.0|
|externalWorkflowStoragePwd|Tool Orchestration|password for external workflow storage||1.0|
|externalWorkflowStorageBucketName|Tool Orchestration|name of bucket in external workflow storage||1.0|
|externalWorkflowStorageTrustCert|Tool Orchestration|whether to trust workflow storage certificate||1.0|
|externalWorkflowStorageCertChainPath|Tool Orchestration|path to the external workflow storage certificate||1.0|
||||||
|addExtraCertificates|Core|whether to trust extra certificates||1.0|
|extraTrustedCaCertPaths|Core|array of paths to certificates to trust||1.0|
||||||
|webServiceType|Core|type of K8s service for SRM web service||1.0|
|webServicePortNumber|Core|port number for SRM web service||1.0|
|webServiceAnnotations|Core|annotations for SRM web service||1.0|
||||||
|skipIngressEnabled|Ingress|whether to skip SRM ingress||1.0|
|ingressType|Ingress|type of SRM ingress||1.0|
|ingressClassName|Ingress|name of ingress class||1.0|
|ingressAnnotations|Ingress|annotations for SRM ingress||1.0|
|ingressHostname|Ingress|hostname associated with SRM ingress||1.0|
|ingressTlsSecretName|Ingress|name of K8s secret containing ingress TLS configuration||1.0|
|ingressTlsType|Ingress|type of TLS ingress configuration|None;CertManagerIssuer;CertManagerClusterIssuer;ExternalSecret|1.0|
||||||
|useSaml|SAML|whether to use SAML||1.0|
|useLdap|LDAP|whether to use LDAP||1.0|
|samlHostBasePath|SAML|base HTTP path for SRM web|https://www.codedx.io/srm|1.0|
|samlIdentityProviderMetadataPath|SAML|path to the SAML IdP||1.0|
|samlAppName|SAML|name of SAML app/entity||1.0|
|samlKeystorePwd|SAML|password to protect SAML-related Java keystore||1.0|
|samlPrivateKeyPwd|SAML|password to protect SAML-related Java keystore key||1.0|
||||||
|skipDockerRegistryCredential|Core (Required w/ Scan Farm)|whether to create K8s Image Pull Secret||1.0|
|dockerImagePullSecretName|Core (Required w/ Scan Farm)|name of K8s Image Pull Secret||1.0|
|dockerRegistry|Core (Required w/ Scan Farm)|name of Docker registry|gcr.io|1.0|
|dockerRegistryUser|Core (Required w/ Scan Farm)|username to access Docker registry||1.0|
|dockerRegistryPwd|Core (Required w/ Scan Farm)|password to access Docker registry||1.0|
||||||
|useDefaultDockerImages|Core|whether to use default Docker image versions||1.0|
|imageVersionWeb|Core|SRM web Docker image version||1.0|
|imageVersionMariaDB|Core|On-Cluster MariaDB Docker image version||1.0|
|imageVersionTo|Core|Tool Orchestration Docker image version||1.0|
|imageVersionMinio|Core|MinIO Docker image version||1.0|
|imageVersionWorkflow|Core|Argo workflow Docker image version||1.0|
||||||
|useDockerRedirection|Core (Required w/ Scan Farm)|whether to use private Docker registry|"true"|1.0|
|useDockerRepositoryPrefix|Core|whether to include a private Docker registry prefix|"true"|1.0|
|dockerRepositoryPrefix|Core|prefix for Docker registry|"my-srm"|1.0|
||||||
|useDefaultCACerts|Core|whether to use default cacerts file||1.0|
|caCertsFilePath|Core|path to custom Java cacerts file||1.0|
|caCertsFilePwd|Core|password to access custom Java cacerts file||1.0|
||||||
|useCPUDefaults|Core|whether to use default CPU reservations||1.0|
|webCPUReservation|Core|reservation for SRM Web CPU||1.0|
|dbMasterCPUReservation|On-Cluster DB|reservation for On-Cluster primary database CPU||1.0|
|dbSlaveCPUReservation|On-Cluster DB|reservation for On-Cluster secondary database CPU||1.0|
|toolServiceCPUReservation|Tool Orchestration|reservation for Tool Service CPU||1.0|
|minioCPUReservation|Tool Orchestration|reservation for MinIO CPU||1.0|
|workflowCPUReservation|Tool Orchestration|reservation for Argo workflow CPU||1.0|
||||||
|useMemoryDefaults|Core|whether to use default memory reservations||1.0|
|webMemoryReservation|Core|reservation for SRM Web memory||1.0|
|dbMasterMemoryReservation|On-Cluster DB|reservation for On-Cluster primary database memory||1.0|
|dbSlaveMemoryReservation|On-Cluster DB|reservation for On-Cluster secondary database memory||1.0|
|toolServiceMemoryReservation|Tool Orchestration|reservation for Tool Service memory||1.0|
|minioMemoryReservation|Tool Orchestration|reservation for MinIO memory||1.0|
|workflowMemoryReservation|Tool Orchestration|reservation for Argo workflow memory||1.0|
||||||
|useEphemeralStorageDefaults|Core|whether to use default ephemeral storage reservations||1.0|
|webEphemeralStorageReservation|Core|reservation for SRM Web ephemeral storage||1.0|
|dbMasterEphemeralStorageReservation|On-Cluster DB|reservation for On-Cluster primary database ephemeral storage||1.0|
|dbSlaveEphemeralStorageReservation|On-Cluster DB|reservation for On-Cluster secondary database ephemeral storage||1.0|
|toolServiceEphemeralStorageReservation|Tool Orchestration|reservation for Tool Service ephemeral storage||1.0|
|minioEphemeralStorageReservation|Tool Orchestration|reservation for MinIO ephemeral storage||1.0|
|workflowEphemeralStorageReservation|Tool Orchestration|reservation for Argo workflow ephemeral storage||1.0|
||||||
|useVolumeSizeDefaults|Core|whether to use default Volume sizes||1.0|
|webVolumeSizeGiB|Core|size of SRM Web volume||1.0|
|dbVolumeSizeGiB|On-Cluster DB|size of On-Cluster primary database volume||1.0|
|dbSlaveVolumeSizeGiB|On-Cluster DB|size of On-Cluster replica database volume||1.0|
|dbSlaveBackupVolumeSizeGiB|On-Cluster DB|size of On-Cluster replica backup database volume||1.0|
|minioVolumeSizeGiB|Tool Orchestration|size of MinIO volume||1.0|
|storageClassName|Tool Orchestration|name of storage class for all volumes||1.0|
||||||
|useNodeSelectors|Core|whether to use node selectors||1.0|
|webNodeSelector|Core|node selector for SRM Web||1.0|
|masterDatabaseNodeSelector|On-Cluster DB|node selector for On-Cluster primary database||1.0|
|subordinateDatabaseNodeSelector|On-Cluster DB|node selector for On-Cluster replica database||1.0|
|toolServiceNodeSelector|Tool Orchestration|node selector for Tool Service||1.0|
|minioNodeSelector|Tool Orchestration|node selector for MinIO||1.0|
|workflowControllerNodeSelector|Tool Orchestration|node selector for Argo workflow controller||1.0|
|toolNodeSelector|Tool Orchestration|node selector for Tool Orchestration tools||1.0|
||||||
|useTolerations|Core|whether to use pod tolerations||1.0|
|webNoScheduleExecuteToleration|Core|pod toleration for SRM Web||1.0|
|masterDatabaseNoScheduleExecuteToleration|On-Cluster DB|pod toleration for On-Cluster primary database||1.0|
|subordinateDatabaseNoScheduleExecuteToleration|On-Cluster DB|pod toleration for On-Cluster replica database||1.0|
|toolServiceNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Tool Service||1.0|
|minioNoScheduleExecuteToleration|Tool Orchestration|pod toleration for MinIO||1.0|
|workflowControllerNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Argo workflow controller||1.0|
|toolNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Tool Orchestration tools||1.0|
||||||
|notes|Core|notes associated with deployment||1.0|
||||||
|scanFarmScaApiUrlOverride|Core (Dev/Test Only)|override for SCA scan farm endpoint||1.0|
|configVersion|Config|config.json file format version||1.1|
|isLocked|Config|whether some config.json field values are encrypted||1.1|
|salts|Config|salts used to encrypt specific config.json field values||1.1|


