$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

. (Join-Path $PSScriptRoot '../../keyvalue.ps1')
. (Join-Path $PSScriptRoot '../../build/protect.ps1')
. (Join-Path $PSScriptRoot '../../config.ps1')

Describe 'Parsing config' -Tag 'upgrade' {

	It 'should upgrade to v1.4 from on-cluster v1.3' {

		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.3",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "C:\\tmp",
			"srmLicenseFile": "C:\\tmp\\srm-web-license.txt",
			"scanFarmSastLicenseFile": null,
			"scanFarmScaLicenseFile": null,
			"sigRepoUsername": null,
			"sigRepoPwd": null,
			"scanFarmDatabaseHost": null,
			"scanFarmDatabasePort": null,
			"scanFarmDatabaseUser": null,
			"scanFarmDatabasePwd": null,
			"scanFarmDatabaseSslMode": null,
			"scanFarmDatabaseServerCert": null,
			"scanFarmScanDatabaseCatalog": null,
			"scanFarmStorageDatabaseCatalog": null,
			"scanFarmRedisHost": null,
			"scanFarmRedisPort": null,
			"scanFarmRedisDatabase": null,
			"scanFarmRedisUseAuth": false,
			"scanFarmRedisPwd": null,
			"scanFarmRedisSecure": false,
			"scanFarmRedisVerifyHostname": false,
			"scanFarmRedisServerCert": null,
			"scanFarmStorageType": null,
			"scanFarmStorageBucketName": null,
			"scanFarmCacheBucketName": null,
			"scanFarmS3UseServiceAccountName": false,
			"scanFarmS3AccessKey": null,
			"scanFarmS3SecretKey": null,
			"scanFarmS3ServiceAccountName": null,
			"scanFarmS3Region": null,
			"scanFarmGcsProjectName": null,
			"scanFarmGcsSvcAccountKey": null,
			"scanFarmAzureStorageAccount": null,
			"scanFarmAzureStorageAccountKey": null,
			"scanFarmAzureSubscriptionId": null,
			"scanFarmAzureTenantId": null,
			"scanFarmAzureResourceGroup": null,
			"scanFarmAzureEndpoint": null,
			"scanFarmAzureClientId": null,
			"scanFarmAzureClientSecret": null,
			"scanFarmMinIOHostname": null,
			"scanFarmMinIOPort": null,
			"scanFarmMinIORootUsername": null,
			"scanFarmMinIORootPwd": null,
			"scanFarmMinIOSecure": false,
			"scanFarmMinIOVerifyHostname": false,
			"scanFarmMinIOServerCert": null,
			"scanFarmStorageHasInClusterUrl": false,
			"scanFarmStorageInClusterUrl": null,
			"scanFarmStorageIsProxied": true,
			"scanFarmStorageContextPath": "upload",
			"scanFarmStorageExternalUrl": "",
			"useGeneratedPwds": true,
			"mariadbRootPwd": null,
			"mariadbReplicatorPwd": null,
			"srmDatabaseUserPwd": null,
			"adminPwd": null,
			"toolServiceApiKey": null,
			"minioAdminPwd": null,
			"k8sProvider": "Other",
			"kubeApiTargetPort": "443",
			"clusterCertificateAuthorityCertPath": null,
			"csrSignerName": null,
			"createSCCs": false,
			"scanFarmType": 0,
			"skipDatabase": false,
			"useTriageAssistant": true,
			"skipScanFarm": true,
			"skipToolOrchestration": false,
			"skipMinIO": false,
			"skipNetworkPolicies": true,
			"skipTls": true,
			"toolServiceReplicas": 0,
			"dbSlaveReplicaCount": 0,
			"externalDatabaseHost": null,
			"externalDatabasePort": 3306,
			"externalDatabaseName": null,
			"externalDatabaseUser": null,
			"externalDatabasePwd": null,
			"externalDatabaseSkipTls": false,
			"externalDatabaseTrustCert": false,
			"externalDatabaseServerCert": null,
			"externalWorkflowStorageEndpoint": null,
			"externalWorkflowStorageEndpointSecure": false,
			"externalWorkflowStorageUsername": null,
			"externalWorkflowStoragePwd": null,
			"externalWorkflowStorageBucketName": null,
			"externalWorkflowStorageTrustCert": false,
			"externalWorkflowStorageCertChainPath": null,
			"addExtraCertificates": false,
			"extraTrustedCaCertPaths": null,
			"webServiceType": "ClusterIP",
			"webServicePortNumber": "9090",
			"webServiceAnnotations": [],
			"skipIngressEnabled": true,
			"ingressType": "ClusterIP",
			"ingressClassName": null,
			"ingressAnnotations": [],
			"ingressHostname": null,
			"ingressTlsSecretName": null,
			"ingressTlsType": null,
			"useSaml": false,
			"useLdap": false,
			"samlHostBasePath": null,
			"samlIdentityProviderMetadataPath": null,
			"samlAppName": null,
			"samlKeystorePwd": null,
			"samlPrivateKeyPwd": null,
			"skipDockerRegistryCredential": true,
			"dockerImagePullSecretName": null,
			"dockerRegistry": null,
			"dockerRegistryUser": null,
			"dockerRegistryPwd": null,
			"useDefaultDockerImages": true,
			"imageVersionWeb": null,
			"imageVersionMariaDB": null,
			"imageVersionTo": null,
			"imageVersionMinio": null,
			"imageVersionWorkflow": null,
			"useDockerRedirection": false,
			"useDockerRepositoryPrefix": false,
			"dockerRepositoryPrefix": null,
			"useDefaultCACerts": true,
			"caCertsFilePath": null,
			"caCertsFilePwd": null,
			"useCPUDefaults": false,
			"webCPUReservation": null,
			"dbMasterCPUReservation": null,
			"dbSlaveCPUReservation": null,
			"toolServiceCPUReservation": null,
			"minioCPUReservation": null,
			"workflowCPUReservation": null,
			"useMemoryDefaults": false,
			"webMemoryReservation": null,
			"dbMasterMemoryReservation": null,
			"dbSlaveMemoryReservation": null,
			"toolServiceMemoryReservation": null,
			"minioMemoryReservation": null,
			"workflowMemoryReservation": null,
			"useEphemeralStorageDefaults": false,
			"webEphemeralStorageReservation": null,
			"dbMasterEphemeralStorageReservation": null,
			"dbSlaveEphemeralStorageReservation": null,
			"toolServiceEphemeralStorageReservation": null,
			"minioEphemeralStorageReservation": null,
			"workflowEphemeralStorageReservation": null,
			"useVolumeSizeDefaults": false,
			"webVolumeSizeGiB": 0,
			"dbVolumeSizeGiB": 0,
			"dbSlaveVolumeSizeGiB": 0,
			"dbSlaveBackupVolumeSizeGiB": 0,
			"minioVolumeSizeGiB": 0,
			"storageClassName": "",
			"systemSize": "Small",
			"useNodeSelectors": false,
			"webNodeSelector": null,
			"masterDatabaseNodeSelector": null,
			"subordinateDatabaseNodeSelector": null,
			"toolServiceNodeSelector": null,
			"minioNodeSelector": null,
			"workflowControllerNodeSelector": null,
			"toolNodeSelector": null,
			"useTolerations": false,
			"webNoScheduleExecuteToleration": null,
			"masterDatabaseNoScheduleExecuteToleration": null,
			"subordinateDatabaseNoScheduleExecuteToleration": null,
			"toolServiceNoScheduleExecuteToleration": null,
			"minioNoScheduleExecuteToleration": null,
			"workflowControllerNoScheduleExecuteToleration": null,
			"toolNoScheduleExecuteToleration": null,
			"notes": [],
			"salts": [],
			"isLocked": false,
			"scanFarmScaApiUrlOverride": null
		  }
'@ | Out-file $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)

		$v1Dot3 = new-object Management.Automation.SemanticVersion('1.3')
		$version = new-object Management.Automation.SemanticVersion($config.configVersion)

		$version -gt $v1Dot3 | Should -BeTrue

		$config.workflowStorageType | Should -BeExactly 'OnCluster'
		$config.serviceAccountToolService | Should -BeExactly ''
		$config.serviceAccountWorkflow | Should -BeExactly ''
		$config.skipMinIO | Should -BeFalse
	}

	It 'should upgrade to v1.4 from access-key v1.3' {

		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.3",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "C:\\tmp",
			"srmLicenseFile": "C:\\tmp\\srm-web-license.txt",
			"scanFarmSastLicenseFile": "",
			"scanFarmScaLicenseFile": "",
			"sigRepoUsername": "",
			"sigRepoPwd": "",
			"scanFarmDatabaseHost": "",
			"scanFarmDatabasePort": "",
			"scanFarmDatabaseUser": "",
			"scanFarmDatabasePwd": "",
			"scanFarmDatabaseSslMode": "",
			"scanFarmDatabaseServerCert": "",
			"scanFarmScanDatabaseCatalog": "",
			"scanFarmStorageDatabaseCatalog": "",
			"scanFarmRedisHost": "",
			"scanFarmRedisPort": "",
			"scanFarmRedisDatabase": "",
			"scanFarmRedisUseAuth": false,
			"scanFarmRedisPwd": "",
			"scanFarmRedisSecure": false,
			"scanFarmRedisVerifyHostname": false,
			"scanFarmRedisServerCert": "",
			"scanFarmStorageType": "",
			"scanFarmStorageBucketName": "",
			"scanFarmCacheBucketName": "",
			"scanFarmS3UseServiceAccountName": false,
			"scanFarmS3AccessKey": "",
			"scanFarmS3SecretKey": "",
			"scanFarmS3ServiceAccountName": "",
			"scanFarmS3Region": "",
			"scanFarmGcsProjectName": "",
			"scanFarmGcsSvcAccountKey": "",
			"scanFarmAzureStorageAccount": "",
			"scanFarmAzureStorageAccountKey": "",
			"scanFarmAzureSubscriptionId": "",
			"scanFarmAzureTenantId": "",
			"scanFarmAzureResourceGroup": "",
			"scanFarmAzureEndpoint": "",
			"scanFarmAzureClientId": "",
			"scanFarmAzureClientSecret": "",
			"scanFarmMinIOHostname": "",
			"scanFarmMinIOPort": "",
			"scanFarmMinIORootUsername": "",
			"scanFarmMinIORootPwd": "",
			"scanFarmMinIOSecure": false,
			"scanFarmMinIOVerifyHostname": false,
			"scanFarmMinIOServerCert": "",
			"scanFarmStorageHasInClusterUrl": false,
			"scanFarmStorageInClusterUrl": "",
			"scanFarmStorageIsProxied": true,
			"scanFarmStorageContextPath": "upload",
			"scanFarmStorageExternalUrl": "",
			"useGeneratedPwds": true,
			"mariadbRootPwd": "",
			"mariadbReplicatorPwd": "",
			"srmDatabaseUserPwd": "",
			"adminPwd": "",
			"toolServiceApiKey": "",
			"minioAdminPwd": "",
			"k8sProvider": "Other",
			"kubeApiTargetPort": "443",
			"clusterCertificateAuthorityCertPath": "",
			"csrSignerName": "",
			"createSCCs": false,
			"scanFarmType": 0,
			"skipDatabase": false,
			"useTriageAssistant": true,
			"skipScanFarm": true,
			"skipToolOrchestration": false,
			"skipMinIO": true,
			"skipNetworkPolicies": true,
			"skipTls": true,
			"toolServiceReplicas": 0,
			"dbSlaveReplicaCount": 0,
			"externalDatabaseHost": "",
			"externalDatabasePort": 3306,
			"externalDatabaseName": "",
			"externalDatabaseUser": "",
			"externalDatabasePwd": "",
			"externalDatabaseSkipTls": false,
			"externalDatabaseTrustCert": false,
			"externalDatabaseServerCert": "",
			"externalWorkflowStorageEndpoint": "endpoint",
			"externalWorkflowStorageEndpointSecure": true,
			"externalWorkflowStorageUsername": "username",
			"externalWorkflowStoragePwd": "password",
			"externalWorkflowStorageBucketName": "bucket",
			"externalWorkflowStorageTrustCert": false,
			"externalWorkflowStorageCertChainPath": "",
			"addExtraCertificates": false,
			"extraTrustedCaCertPaths": null,
			"webServiceType": "ClusterIP",
			"webServicePortNumber": "9090",
			"webServiceAnnotations": [],
			"skipIngressEnabled": true,
			"ingressType": "ClusterIP",
			"ingressClassName": "",
			"ingressAnnotations": [],
			"ingressHostname": "",
			"ingressTlsSecretName": "",
			"ingressTlsType": "",
			"useSaml": false,
			"useLdap": false,
			"samlHostBasePath": "",
			"samlIdentityProviderMetadataPath": "",
			"samlAppName": "",
			"samlKeystorePwd": "",
			"samlPrivateKeyPwd": "",
			"skipDockerRegistryCredential": true,
			"dockerImagePullSecretName": "",
			"dockerRegistry": "",
			"dockerRegistryUser": "",
			"dockerRegistryPwd": "",
			"useDefaultDockerImages": true,
			"imageVersionWeb": "",
			"imageVersionMariaDB": "",
			"imageVersionTo": "",
			"imageVersionMinio": "",
			"imageVersionWorkflow": "",
			"useDockerRedirection": false,
			"useDockerRepositoryPrefix": false,
			"dockerRepositoryPrefix": "",
			"useDefaultCACerts": true,
			"caCertsFilePath": "",
			"caCertsFilePwd": "",
			"useCPUDefaults": false,
			"webCPUReservation": "",
			"dbMasterCPUReservation": "",
			"dbSlaveCPUReservation": "",
			"toolServiceCPUReservation": "",
			"minioCPUReservation": "",
			"workflowCPUReservation": "",
			"useMemoryDefaults": false,
			"webMemoryReservation": "",
			"dbMasterMemoryReservation": "",
			"dbSlaveMemoryReservation": "",
			"toolServiceMemoryReservation": "",
			"minioMemoryReservation": "",
			"workflowMemoryReservation": "",
			"useEphemeralStorageDefaults": false,
			"webEphemeralStorageReservation": "",
			"dbMasterEphemeralStorageReservation": "",
			"dbSlaveEphemeralStorageReservation": "",
			"toolServiceEphemeralStorageReservation": "",
			"minioEphemeralStorageReservation": "",
			"workflowEphemeralStorageReservation": "",
			"useVolumeSizeDefaults": false,
			"webVolumeSizeGiB": 0,
			"dbVolumeSizeGiB": 0,
			"dbSlaveVolumeSizeGiB": 0,
			"dbSlaveBackupVolumeSizeGiB": 0,
			"minioVolumeSizeGiB": 0,
			"storageClassName": "",
			"systemSize": "Small",
			"useNodeSelectors": false,
			"webNodeSelector": null,
			"masterDatabaseNodeSelector": null,
			"subordinateDatabaseNodeSelector": null,
			"toolServiceNodeSelector": null,
			"minioNodeSelector": null,
			"workflowControllerNodeSelector": null,
			"toolNodeSelector": null,
			"useTolerations": false,
			"webNoScheduleExecuteToleration": null,
			"masterDatabaseNoScheduleExecuteToleration": null,
			"subordinateDatabaseNoScheduleExecuteToleration": null,
			"toolServiceNoScheduleExecuteToleration": null,
			"minioNoScheduleExecuteToleration": null,
			"workflowControllerNoScheduleExecuteToleration": null,
			"toolNoScheduleExecuteToleration": null,
			"notes": null,
			"salts": [],
			"isLocked": false,
			"scanFarmScaApiUrlOverride": ""
		  }	  
'@ | Out-file $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)

		$v1Dot3 = new-object Management.Automation.SemanticVersion('1.3')
		$version = new-object Management.Automation.SemanticVersion($config.configVersion)

		$version -gt $v1Dot3 | Should -BeTrue

		$config.workflowStorageType | Should -BeExactly 'AccessKey'
		$config.serviceAccountToolService | Should -BeExactly ''
		$config.serviceAccountWorkflow | Should -BeExactly ''
		$config.externalWorkflowStorageEndpoint | Should -BeExactly 'endpoint'
		$config.externalWorkflowStorageEndpointSecure | Should -BeTrue
		$config.externalWorkflowStorageBucketName | Should -BeExactly 'bucket'
		$config.externalWorkflowStorageUsername | Should -BeExactly 'username'
		$config.externalWorkflowStoragePwd | Should -BeExactly 'password'
		$config.skipMinIO | Should -BeTrue
	}
}