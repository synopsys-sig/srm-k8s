enum ProviderType {
	Minikube
	Aks
	Eks
	OpenShift
	Other
}

enum IngressType {
	NginxIngress
	NginxIngressCommunity
	OtherIngress
	ClusterIP
	NodePort
	LoadBalancer
	ClassicElb
	NetworkElb
	InternalClassicElb
}

enum IngressTlsType {
	None
	CertManagerIssuer
	CertManagerClusterIssuer
	ExternalSecret
}

enum ScanFarmLicenseType {
	None
	Sast
	Sca
	All
}

enum ScanFarmStorageType {
	AwsS3
	MinIO
	Gcs
	Azure
}

class Config {

	static [int]   $kubeApiTargetPortDefault = 443
	static [int]   $toolServiceReplicasDefault = 1
	static [int]   $volumeSizeGiBDefault = 64
	static [int]   $externalDatabasePortDefault = 3306

	[string]       $configVersion

	[string]       $namespace                                # formerly namespaceCodeDx
	[string]       $releaseName                              # formerly releaseNameCodeDx

	[string]       $workDir

	[string]       $srmLicenseFile
	[string]       $scanFarmSastLicenseFile
	[string]       $scanFarmScaLicenseFile

	[string]       $sigRepoUsername
	[string]       $sigRepoPwd

	[string]       $scanFarmDatabaseHost
	[string]       $scanFarmDatabasePort
	[string]       $scanFarmDatabaseUser
	[string]       $scanFarmDatabasePwd
	[string]       $scanFarmDatabaseSslMode
	[string]       $scanFarmDatabaseServerCert
	[string]       $scanFarmScanDatabaseCatalog
	[string]       $scanFarmStorageDatabaseCatalog

	[string]       $scanFarmRedisHost
	[string]       $scanFarmRedisPort
	[string]       $scanFarmRedisDatabase
	[bool]         $scanFarmRedisUseAuth
	[string]       $scanFarmRedisPwd
	[bool]         $scanFarmRedisSecure
	[bool]         $scanFarmRedisVerifyHostname
	[string]       $scanFarmRedisServerCert

	[string]       $scanFarmStorageType
	[string]       $scanFarmStorageBucketName
	[string]       $scanFarmCacheBucketName

	[bool]         $scanFarmS3UseServiceAccountName
	[string]       $scanFarmS3AccessKey
	[string]       $scanFarmS3SecretKey
	[string]       $scanFarmS3ServiceAccountName
	[string]       $scanFarmS3Region

	[string]       $scanFarmGcsProjectName
	[string]       $scanFarmGcsSvcAccountKey

	[string]       $scanFarmAzureStorageAccount
	[string]       $scanFarmAzureStorageAccountKey
	[string]       $scanFarmAzureSubscriptionId
	[string]       $scanFarmAzureTenantId
	[string]       $scanFarmAzureResourceGroup
	[string]       $scanFarmAzureEndpoint
	[string]       $scanFarmAzureClientId
	[string]       $scanFarmAzureClientSecret

	[string]       $scanFarmMinIOHostname
	[string]       $scanFarmMinIOPort
	[string]       $scanFarmMinIORootUsername
	[string]       $scanFarmMinIORootPwd
	[bool]         $scanFarmMinIOSecure
	[bool]         $scanFarmMinIOVerifyHostname
	[string]       $scanFarmMinIOServerCert

	[bool]         $scanFarmStorageHasInClusterUrl
	[string]       $scanFarmStorageInClusterUrl

	[bool]         $useGeneratedPwds
	[string]       $mariadbRootPwd
	[string]       $mariadbReplicatorPwd
	[string]       $srmDatabaseUserPwd                       # formerly codedxDatabaseUserPwd
	[string]       $adminPwd                                 # formerly codedxAdminPwd
	[string]       $toolServiceApiKey
	[string]       $minioAdminPwd

	[string]       $k8sProvider
	[string]       $kubeApiTargetPort

	[string]       $clusterCertificateAuthorityCertPath
	[string]       $csrSignerName                            # formerly csrSignerNameCodeDx

	[bool]         $createSCCs

	[ScanFarmLicenseType] $scanFarmType

	[bool]         $skipDatabase
	[bool]         $useTriageAssistant
	[bool]         $skipScanFarm
	[bool]         $skipToolOrchestration
	[bool]         $skipMinIO
	[bool]         $skipNetworkPolicies
	[bool]         $skipTls

	[int]          $toolServiceReplicas

	[int]          $dbSlaveReplicaCount

	[string]       $externalDatabaseHost
	[int]          $externalDatabasePort
	[string]       $externalDatabaseName
	[string]       $externalDatabaseUser
	[string]       $externalDatabasePwd
	[bool]         $externalDatabaseSkipTls
	[bool]         $externalDatabaseTrustCert
	[string]       $externalDatabaseServerCert

	[string]       $externalWorkflowStorageEndpoint
	[bool]         $externalWorkflowStorageEndpointSecure
	[string]       $externalWorkflowStorageUsername
	[string]       $externalWorkflowStoragePwd
	[string]       $externalWorkflowStorageBucketName
	[bool]         $externalWorkflowStorageTrustCert
	[string]       $externalWorkflowStorageCertChainPath

	[bool]         $addExtraCertificates
	[string[]]     $extraTrustedCaCertPaths                  # formely extraCodeDxTrustedCaCertPaths

	[string]       $webServiceType                           # formerly serviceTypeCodeDx
	[string]       $webServicePortNumber                     # formerly codeDxServicePortNumber/codeDxTlsServicePortNumber
	[KeyValue[]]   $webServiceAnnotations = @()              # formerly serviceAnnotationsCodeDx

	[bool]         $skipIngressEnabled
	[string]       $ingressType
	[string]       $ingressClassName                         # formerly ingressClassNameCodeDx
	[KeyValue[]]   $ingressAnnotations = @()                 # formerly ingressAnnotationsCodeDx
	[string]       $ingressHostname                          # formerly codeDxDnsName
	[string]       $ingressTlsSecretName                     # formerly ingressTlsSecretNameCodeDx
	[string]       $ingressTlsType

	[bool]         $useSaml
	[bool]         $useLdap
	[string]       $samlHostBasePath                         # formerly samlHostBasePathOverride
	[string]       $samlIdentityProviderMetadataPath
	[string]       $samlAppName
	[string]       $samlKeystorePwd
	[string]       $samlPrivateKeyPwd

	[bool]         $skipDockerRegistryCredential             # formely skipPrivateDockerRegistry
	[string]       $dockerImagePullSecretName
	[string]       $dockerRegistry
	[string]       $dockerRegistryUser
	[string]       $dockerRegistryPwd

	[bool]         $useDefaultDockerImages
	[string]       $imageVersionWeb
	[string]       $imageVersionMariaDB
	[string]       $imageVersionTo
	[string]       $imageVersionMinio
	[string]       $imageVersionWorkflow

	[bool]         $useDockerRedirection
	[bool]         $useDockerRepositoryPrefix
	[string]       $dockerRepositoryPrefix                   # formerly redirectDockerHubReferencesTo

	[bool]         $useDefaultCACerts
	[string]       $caCertsFilePath
	[string]       $caCertsFilePwd

	[bool]         $useCPUDefaults
	[string]       $webCPUReservation                        # formerly codeDxCPUReservation
	[string]       $dbMasterCPUReservation
	[string]       $dbSlaveCPUReservation
	[string]       $toolServiceCPUReservation
	[string]       $minioCPUReservation
	[string]       $workflowCPUReservation

	[bool]         $useMemoryDefaults
	[string]       $webMemoryReservation                     # formerly codeDxMemoryReservation
	[string]       $dbMasterMemoryReservation
	[string]       $dbSlaveMemoryReservation
	[string]       $toolServiceMemoryReservation
	[string]       $minioMemoryReservation
	[string]       $workflowMemoryReservation

	[bool]         $useEphemeralStorageDefaults
	[string]       $webEphemeralStorageReservation           # formerly codeDxEphemeralStorageReservation
	[string]       $dbMasterEphemeralStorageReservation
	[string]       $dbSlaveEphemeralStorageReservation
	[string]       $toolServiceEphemeralStorageReservation
	[string]       $minioEphemeralStorageReservation
	[string]       $workflowEphemeralStorageReservation

	[bool]         $useVolumeSizeDefaults
	[int]          $webVolumeSizeGiB                         # formerly codeDxVolumeSizeGiB
	[int]          $dbVolumeSizeGiB
	[int]          $dbSlaveVolumeSizeGiB
	[int]          $dbSlaveBackupVolumeSizeGiB
	[int]          $minioVolumeSizeGiB
	[string]       $storageClassName

	[bool]         $useNodeSelectors
	[KeyValue]     $webNodeSelector                          # formerly codeDxNodeSelector
	[KeyValue]     $masterDatabaseNodeSelector
	[KeyValue]     $subordinateDatabaseNodeSelector
	[KeyValue]     $toolServiceNodeSelector
	[KeyValue]     $minioNodeSelector
	[KeyValue]     $workflowControllerNodeSelector
	[KeyValue]     $toolNodeSelector

	[bool]         $useTolerations
	[KeyValue]     $webNoScheduleExecuteToleration           # formerly codeDxNoScheduleExecuteToleration
	[KeyValue]     $masterDatabaseNoScheduleExecuteToleration
	[KeyValue]     $subordinateDatabaseNoScheduleExecuteToleration
	[KeyValue]     $toolServiceNoScheduleExecuteToleration
	[KeyValue]     $minioNoScheduleExecuteToleration
	[KeyValue]     $workflowControllerNoScheduleExecuteToleration
	[KeyValue]     $toolNoScheduleExecuteToleration

	[KeyValue[]]  $notes = @()
	
	[string] $scanFarmScaApiUrlOverride # used for dev/test/support only

	Config() {
		$this.configVersion = "1.0"
		$this.toolServiceReplicas = [Config]::toolServiceReplicasDefault
		$this.kubeApiTargetPort = [Config]::kubeApiTargetPortDefault
		$this.webVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.dbVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.dbSlaveVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.minioVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.externalDatabasePort = [Config]::externalDatabasePortDefault
		$this.skipDockerRegistryCredential = $true
		$this.useDefaultDockerImages = $true
		$this.skipTls = $true
		$this.webServicePortNumber = 9090
	}

	static [Config] FromJson($configJson) {

		if (-not ($null -eq $configJson.configVersion -or $configJson.configVersion -eq "1.0")) {
			throw "Unable to handle config version: $($configJson.configVersion)"
		}
		return [Config]$configJson
	}

	[bool]IsElbIngress() {
		return $this.ingressType -eq [IngressType]::ClassicElb -or `
			$this.ingressType -eq [IngressType]::NetworkElb -or `
			$this.ingressType -eq [IngressType]::InternalClassicElb
	}

	[bool]IsElbInternalIngress() {
		return $this.ingressType -eq [IngressType]::InternalClassicElb
	}

	[bool]IsIngress() {
		return $this.ingressType -eq [IngressType]::NginxIngressCommunity -or `
			$this.ingressType -eq [IngressType]::OtherIngress
	}

	[bool]IsIngressTls() {
		return $this.ingressTlsType -eq [IngressTlsType]::ExternalSecret -or `
			$this.ingressTlsType -eq [IngressTlsType]::CertManagerIssuer -or `
			$this.ingressTlsType -eq [IngressTlsType]::CertManagerClusterIssuer
	}

	[bool]IsIngressCertManagerTls() {
		return $this.ingressTlsType -eq [IngressTlsType]::CertManagerIssuer -or `
			$this.ingressTlsType -eq [IngressTlsType]::CertManagerClusterIssuer
	}

	[string]GetFullName() {
		$fullName = Get-HelmChartFullname $this.releaseName 'srm'
		$fullName.substring(0, [math]::min($fullName.length, 63)).TrimEnd('-')
		return $fullName
	}

	[string]GetFullNameWithSuffix([string] $suffix) {
		$suffixLength = $suffix.Length
		$fullNameWithSuffix = $this.GetFullName() + $suffix
		$fullNameWithSuffix = $fullNameWithSuffix.substring(0, [math]::min($fullNameWithSuffix.length, 63-$suffixLength)).TrimEnd('-')
		return $fullNameWithSuffix
	}

	[string]GetWebServiceName() {
		return $this.GetFullNameWithSuffix("-web")
	}

	[string]GetScanServiceName() {
		return "$($this.releaseName)-cnc-scan-service"
	}

	[string]GetStorageServiceName() {
		return "$($this.releaseName)-cnc-storage-service"
	}

	[string]GetCacheServiceName() {
		return "$($this.releaseName)-cnc-cache-service"
	}

	SetNote([string] $key, [string] $value) {
		$this.notes = $this.GetAllExcept($this.notes, $key) + [KeyValue]::new($key, $value)
	}

	RemoveNote([string] $key) {
		$this.notes = $this.GetAllExcept($this.notes, $key)
	}

	[Hashtable]GetIngressAnnotations() {
		return $this.BuildTable($this.ingressAnnotations)
	}

	SetIngressAnnotation([string] $key, [string] $value) {
		$this.ingressAnnotations = $this.GetAllExcept($this.ingressAnnotations, $key) + [KeyValue]::new($key, $value)
	}

	RemoveIngressAnnotation([string] $key) {
		$this.ingressAnnotations = $this.GetAllExcept($this.ingressAnnotations, $key)
	}

	[Hashtable]GetWebServiceAnnotations() {
		return $this.BuildTable($this.webServiceAnnotations)
	}

	SetWebServiceAnnotation([string] $key, [string] $value) {
		$this.webServiceAnnotations = $this.GetAllExcept($this.webServiceAnnotations, $key) + [KeyValue]::new($key, $value)
	}

	[string]GetValuesWorkDir() {
		return Join-Path $this.workDir 'chart-values'
	}

	[string]GetK8sWorkDir() {
		return Join-Path $this.workDir 'chart-resources'
	}

	[string]GetTempWorkDir() {
		return Join-Path $this.workDir 'chart-temp'
	}

	[KeyValue[]]GetAllExcept([KeyValue[]] $keyValues, [string] $key) {
		return $keyValues | Where-Object {
			$_.key -ne $key
		}
	}

	[Hashtable]BuildTable([KeyValue[]] $keyValues) {
		$table = @{}
		if ($null -ne $keyValues) {
			$keyValues | ForEach-Object {
				$table[$_.key] = $_.value
			}
		}
		return $table
	}
}