<#PSScriptInfo
.VERSION 1.4.0
.GUID 62c5091b-7337-44aa-a87b-f9828ae1013a
.AUTHOR Code Dx
.DESCRIPTION This script helps you migrate from Code Dx to SRM (w/o the scan farm feature enabled)
#>

using module @{ModuleName='guided-setup'; RequiredVersion='1.16.0' }

param (
	[string]                 $workDir = "$HOME/.k8s-codedx",
	[string]                 $kubeContextName,

	[string]                 $clusterCertificateAuthorityCertPath,
	[string]                 $codeDxDnsName,
	[int]                    $codeDxServicePortNumber = 9090,
	[int]                    $codeDxTlsServicePortNumber = 9443,
	[int]                    $waitTimeSeconds = 900,

	[int]                    $dbVolumeSizeGiB = 32,
	[int]                    $dbSlaveReplicaCount = 1,
	[int]                    $dbSlaveVolumeSizeGiB = 32,
	[int]                    $minioVolumeSizeGiB = 32,
	[int]                    $codeDxVolumeSizeGiB = 32,

	[string]                 $storageClassName,
	[string]                 $codeDxAppDataStorageClassName,
	[string]                 $dbStorageClassName,
	[string]                 $minioStorageClassName,

	[string]                 $codeDxMemoryReservation,
	[string]                 $dbMasterMemoryReservation,
	[string]                 $dbSlaveMemoryReservation,
	[string]                 $toolServiceMemoryReservation,
	[string]                 $minioMemoryReservation,
	[string]                 $workflowMemoryReservation,

	[string]                 $codeDxCPUReservation,
	[string]                 $dbMasterCPUReservation,
	[string]                 $dbSlaveCPUReservation,
	[string]                 $toolServiceCPUReservation,
	[string]                 $minioCPUReservation,
	[string]                 $workflowCPUReservation,

	[string]                 $codeDxEphemeralStorageReservation = '2868Mi',
	[string]                 $dbMasterEphemeralStorageReservation,
	[string]                 $dbSlaveEphemeralStorageReservation,
	[string]                 $toolServiceEphemeralStorageReservation,
	[string]                 $minioEphemeralStorageReservation,
	[string]                 $workflowEphemeralStorageReservation,

	[int]                    $toolServiceReplicas = 3,

	[switch]                 $skipTLS,
	[switch]                 $skipServiceTLS,
	[string]                 $csrSignerNameCodeDx            = 'kubernetes.io/legacy-unknown',
	[string]                 $csrSignerNameToolOrchestration = 'kubernetes.io/legacy-unknown',

	[switch]                 $skipPSPs,
	[switch]                 $skipNetworkPolicies,

	[int]                    $proxyPort,
	[int[]]                  $egressPortsTCP = @(22,7990,7999),
	[int[]]                  $egressPortsUDP,

	[string]                 $serviceTypeCodeDx,
	[hashtable]              $serviceAnnotationsCodeDx = @{},

	[switch]                 $skipIngressEnabled,
	[string]                 $ingressClassNameCodeDx = 'nginx',
	[string]                 $ingressTlsSecretNameCodeDx = 'ingress-tls-secret',
	[hashtable]              $ingressAnnotationsCodeDx = @{},

	[string]                 $namespaceToolOrchestration = 'cdx-svc',
	[string]                 $namespaceCodeDx = 'cdx-app',
	[string]                 $releaseNameCodeDx = 'codedx',
	[string]                 $releaseNameToolOrchestration = 'codedx-tool-orchestration',

	[string]                 $toolServiceApiKey,

	[string]                 $codedxAdminPwd,
	[string]                 $minioAdminUsername = 'admin',
	[string]                 $minioAdminPwd,
	[string]                 $mariadbRootPwd,
	[string]                 $mariadbReplicatorPwd,

	[switch]                 $skipUseRootDatabaseUser,
	[string]                 $codedxDatabaseUserPwd,

	[string]                 $caCertsFilePath,
	[string]                 $caCertsFilePwd,
	[string]                 $caCertsFileNewPwd,
	
	[string[]]               $extraCodeDxTrustedCaCertPaths = @(),

	[string]                 $dockerImagePullSecretName,
	[string]                 $dockerRegistry,
	[string]                 $dockerRegistryUser,
	[string]                 $dockerRegistryPwd,
	
	[string]                 $redirectDockerHubReferencesTo,

	[string]                 $codedxHelmRepo = 'https://codedx.github.io/codedx-kubernetes',

	[string]                 $helmTimeoutCodeDx = '5m0s',
	[string]                 $helmTimeoutToolOrchestration = '15m0s',
	
	[string]                 $codedxGitRepo = 'https://github.com/codedx/codedx-kubernetes.git',
	[string]                 $codedxGitRepoBranch = 'charts-2.50.0',

	[int]                    $kubeApiTargetPort = 443,

	[string[]]               $extraCodeDxValuesPaths = @(),
	[string[]]               $extraToolOrchestrationValuesPath = @(),

	[switch]                 $skipDatabase,
	[string]                 $externalDatabaseHost,
	[int]                    $externalDatabasePort = 3306,
	[string]                 $externalDatabaseName,
	[string]                 $externalDatabaseUser,
	[string]                 $externalDatabasePwd,
	[string]                 $externalDatabaseServerCert,
	[switch]                 $externalDatabaseSkipTls,

	[switch]                 $skipMinIO,
	[string]                 $externalWorkflowStorageEndpoint,
	[switch]                 $externalWorkflowStorageEndpointSecure,
	[string]                 $externalWorkflowStorageUsername = 'admin',
	[string]                 $externalWorkflowStoragePwd,
	[string]                 $externalWorkflowStorageBucketName = 'code-dx-storage',
	[string]                 $externalWorkflowStorageCertChainPath,

	[switch]                 $skipToolOrchestration,

	[switch]                 $useSaml,
	[string]                 $samlAppName,
	[string]                 $samlIdentityProviderMetadataPath,
	[string]                 $samlKeystorePwd,
	[string]                 $samlPrivateKeyPwd,
	[string]                 $samlHostBasePathOverride,

	[Tuple`2[string,string]] $codeDxNodeSelector,
	[Tuple`2[string,string]] $masterDatabaseNodeSelector,
	[Tuple`2[string,string]] $subordinateDatabaseNodeSelector,
	[Tuple`2[string,string]] $toolServiceNodeSelector,
	[Tuple`2[string,string]] $minioNodeSelector,
	[Tuple`2[string,string]] $workflowControllerNodeSelector,
	[Tuple`2[string,string]] $toolNodeSelector,

	[Tuple`2[string,string]] $codeDxNoScheduleExecuteToleration,
	[Tuple`2[string,string]] $masterDatabaseNoScheduleExecuteToleration,
	[Tuple`2[string,string]] $subordinateDatabaseNoScheduleExecuteToleration,
	[Tuple`2[string,string]] $toolServiceNoScheduleExecuteToleration,
	[Tuple`2[string,string]] $minioNoScheduleExecuteToleration,
	[Tuple`2[string,string]] $workflowControllerNoScheduleExecuteToleration,
	[Tuple`2[string,string]] $toolNoScheduleExecuteToleration,

	[switch]                 $pauseAfterGitClone,

	[switch]                 $useHelmOperator,
	[switch]                 $useHelmController,
	[switch]                 $useHelmManifest,
	[switch]                 $useHelmCommand,
	[switch]                 $skipSealedSecrets,
	[string]                 $sealedSecretsNamespace,
	[string]                 $sealedSecretsControllerName,
	[string]                 $sealedSecretsPublicKeyPath,

	[string]                 $backupType,
	[string]                 $namespaceVelero = 'velero',
	[string]                 $backupScheduleCronExpression = '0 3 * * *',
	[int]                    $backupDatabaseTimeoutMinutes = 30,
	[int]                    $backupTimeToLiveHours = 720,

	[int]                    $workflowStepMinimumRunTimeSeconds = 3,
	[switch]                 $createSCCs,

	[int]                    $connectionPoolEffectiveSpindleCount,
	[int]                    $connectionPoolTimeoutMilliseconds = 30000,
	[int]                    $concurrentAnalysisLimit,
	[int]                    $jobsLimitCpu,
	[int]                    $jobsLimitMemory,
	[int]                    $jobsLimitDatabase,
	[int]                    $jobsLimitDisk,

	[switch]                 $skipNamespaceConfiguration
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

# Use "Legacy" argument passing to avoid errors from conditional empty string arguments
$global:PSNativeCommandArgumentPassing='Legacy'

'../../../ps/keyvalue.ps1',
'../../../ps/build/protect.ps1',
'../../../ps/config.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-kubernetes GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

function Get-FilePath([string] $prompt) {
	$q = new-object PathQuestion($prompt, $false, $false)
	$q.Prompt()
	$q.Response
}

function Get-DirectoryPath([string] $prompt) {
	$q = new-object PathQuestion($prompt, $true, $false)
	$q.Prompt()
	$q.Response
}

function Get-QuestionResponse([string] $prompt, [string[]] $blockedList, [switch] $isSecure) {
	$q = new-object Question($prompt)
	$q.blacklist = $blockedList
	$q.isSecure = $isSecure
	$q.Prompt()
	$q.Response
}

function Get-KeyValuesFromTable([hashtable] $table) {

	$table.Keys | ForEach-Object {
		$key = $_
		$val = $table[$key]
		[KeyValue]::New($key, $val)
	}
}

function New-KeyValueFromTuple([Tuple`2[string,string]] $tuple) {

	if ($null -eq $tuple) {
		return $null
	}
	[KeyValue]::New($tuple.Item1, $tuple.Item2)
}

Write-Host "Your Code Dx work directory is $workDir"
do {
	$newWorkDirectory = Get-DirectoryPath "Enter a new SRM work directory that differs from the old one"
} while ([io.path]::GetFullPath($newWorkDirectory) -eq [io.path]::GetFullPath($workDir))

$workDir = $newWorkDirectory
$config = new-object Config

$config.namespace = Get-QuestionResponse "Enter your SRM namespace (do not reuse your Code Dx namespace)" @($namespaceCodeDx,$namespaceToolOrchestration)
$config.releaseName = Get-QuestionResponse "Enter your SRM release (do not reuse your Code Dx release name)" @($releaseNameCodeDx,$releaseNameToolOrchestration)

if ($skipDatabase) {

	$config.externalDatabaseHost = Get-QuestionResponse 'Enter the name of your external database host' @($externalDatabaseHost)
	$config.externalDatabaseName = Get-QuestionResponse 'Enter the name of your SRM database (e.g., srmdb)' @($externalDatabaseName)
	$config.externalDatabaseUser = Get-QuestionResponse 'Enter the SRM database username (e.g., srm)' @($externalDatabaseUser)
	$config.externalDatabasePwd = Get-QuestionResponse 'Enter the SRM database password' @() -isSecure

	Read-Host @"
---
Before invoking helm to install SRM, you must provision your external database by following the
guidance at https://github.com/synopsys-sig/srm-k8s/tree/main/docs/db. Your SRM deployment will
fail if your $($config.externalDatabaseHost) host does not have an 
empty '$($config.externalDatabaseName)' database that the user '$($config.externalDatabaseUser)' can access.
---
Press Enter to continue...
"@ | Out-Null
}

$config.workDir = $workDir

$config.srmLicenseFile = Get-FilePath 'Enter the path to your SRM license file'

$config.mariadbRootPwd = $mariadbRootPwd
$config.mariadbReplicatorPwd = $mariadbReplicatorPwd
$config.srmDatabaseUserPwd = $codedxDatabaseUserPwd
$config.adminPwd = $codedxAdminPwd
$config.toolServiceApiKey = $toolServiceApiKey
$config.minioAdminPwd = $minioAdminPwd

$config.k8sProvider = 'unknown'
$config.kubeApiTargetPort = $kubeApiTargetPort

$config.clusterCertificateAuthorityCertPath = $clusterCertificateAuthorityCertPath
$config.csrSignerName = $csrSignerNameCodeDx

$config.createSCCs = $createSCCs
$config.skipDatabase = $skipDatabase
$config.skipToolOrchestration = $skipToolOrchestration
$config.skipMinIO = $skipMinIO
$config.skipNetworkPolicies = $skipNetworkPolicies
$config.skipTls = $skipTls

if (-not $config.skipTLS) {
	$valuesTlsFilePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../chart/values/values-tls.yaml'))
	$config.SetNote('UseTlsOption', "- You must do the prework in the comments at the top of '$valuesTlsFilePath' before invoking helm")
}

$config.skipScanFarm = $true

$config.toolServiceReplicas = $toolServiceReplicas

$config.dbSlaveReplicaCount = $dbSlaveReplicaCount

$config.externalDatabasePort = $externalDatabasePort
$config.externalDatabaseSkipTls = $externalDatabaseSkipTls
$config.externalDatabaseTrustCert = -not [string]::IsNullOrEmpty($externalDatabaseServerCert)
$config.externalDatabaseServerCert = $externalDatabaseServerCert

$config.externalWorkflowStorageEndpoint = $externalWorkflowStorageEndpoint
$config.externalWorkflowStorageEndpointSecure = $externalWorkflowStorageEndpointSecure
$config.externalWorkflowStorageUsername = $externalWorkflowStorageUsername
$config.externalWorkflowStoragePwd = $externalWorkflowStoragePwd
$config.externalWorkflowStorageBucketName = $externalWorkflowStorageBucketName
$config.externalWorkflowStorageTrustCert = -not [string]::IsNullOrEmpty($externalWorkflowStorageCertChainPath)
$config.externalWorkflowStorageCertChainPath = $externalWorkflowStorageCertChainPath

$config.addExtraCertificates = $extraCodeDxTrustedCaCertPaths.Length -gt 0
$config.extraTrustedCaCertPaths = $extraCodeDxTrustedCaCertPaths

$config.webServiceType = $serviceTypeCodeDx
$config.webServicePortNumber = $skipServiceTLS ? $codeDxServicePortNumber : $codeDxTlsServicePortNumber
$config.webServiceAnnotations = Get-KeyValuesFromTable $serviceAnnotationsCodeDx

$config.skipIngressEnabled = $skipIngressEnabled
$config.ingressType = "NginxIngressCommunity"
$config.ingressClassName = $ingressClassNameCodeDx
$config.ingressAnnotations = Get-KeyValuesFromTable $ingressAnnotationsCodeDx
if (-not $config.skipIngressEnabled) {
	$config.ingressHostname = Get-QuestionResponse "Enter your SRM DNS name (do not reuse your Code Dx hostname - you can switch back post-migration)" @($codeDxDnsName)
}
$config.ingressTlsSecretName = $ingressTlsSecretNameCodeDx

$config.useSaml = $useSaml

$samlHostBasePathQuestion = @'
Specify the SAML hostBasePath name to associate with the SRM web application. The SAML 
IdP will connect to your SRM instance using the SRM Assertion Consumer Service (ACS) 
endpoint, which will be a URL that is based on your SRM DNS name.

If your DNS name will be my-srm.synopsys.com accessed via HTTPS, enter this hostBasePath:

https://my-srm.synopsys.com/srm

Enter your SAML hostBasePath
'@

if ($config.useSaml) {
	if ([string]::IsNullOrEmpty($samlHostBasePathOverride)) {
		$config.samlHostBasePath = Get-QuestionResponse($samlHostBasePathQuestion)
	} else {
		$config.samlHostBasePath = $config.samlHostBasePathOverride.replace("/codedx","/srm")
	}
}

$config.samlIdentityProviderMetadataPath = $samlIdentityProviderMetadataPath
$config.samlAppName = $samlAppName
$config.samlKeystorePwd = $samlKeystorePwd
$config.samlPrivateKeyPwd = $samlPrivateKeyPwd

$config.skipDockerRegistryCredential = [string]::IsNullOrEmpty($dockerRegistryUser)
$config.dockerImagePullSecretName = $dockerImagePullSecretName
$config.dockerRegistry = $dockerRegistry
$config.dockerRegistryUser = $dockerRegistryUser
$config.dockerRegistryPwd = $dockerRegistryPwd

$config.useDefaultDockerImages = $true

# $redirectDockerHubReferencesTo is '$dockerRegistryName/$dockerPrefix'
if (-not [string]::IsNullOrEmpty($redirectDockerHubReferencesTo)) {
	$config.useDockerRepositoryPrefix = $true
	$config.dockerRepositoryPrefix = $redirectDockerHubReferencesTo.Replace($dockerRegistry).TrimStart("/")
}

$config.useDefaultCACerts = -not [string]::IsNullOrEmpty($caCertsFilePath)
$config.caCertsFilePath = $caCertsFilePath
$config.caCertsFilePwd = $caCertsFilePwd

$config.webCPUReservation = $codeDxCPUReservation
$config.dbMasterCPUReservation = $dbMasterCPUReservation
$config.dbSlaveCPUReservation = $dbSlaveCPUReservation
$config.toolServiceCPUReservation = $toolServiceCPUReservation
$config.minioCPUReservation = $minioCPUReservation
$config.workflowCPUReservation = $workflowCPUReservation

$config.webMemoryReservation = $codeDxMemoryReservation
$config.dbMasterMemoryReservation = $dbMasterMemoryReservation
$config.dbSlaveMemoryReservation = $dbSlaveMemoryReservation
$config.toolServiceMemoryReservation = $toolServiceMemoryReservation
$config.minioMemoryReservation = $minioMemoryReservation
$config.workflowMemoryReservation = $workflowMemoryReservation

$config.webEphemeralStorageReservation = $codeDxEphemeralStorageReservation
$config.dbMasterEphemeralStorageReservation = $dbMasterEphemeralStorageReservation
$config.dbSlaveEphemeralStorageReservation = $dbSlaveEphemeralStorageReservation
$config.toolServiceEphemeralStorageReservation = $toolServiceEphemeralStorageReservation
$config.minioEphemeralStorageReservation = $minioEphemeralStorageReservation
$config.workflowEphemeralStorageReservation = $workflowEphemeralStorageReservation

$config.webVolumeSizeGiB = $codeDxVolumeSizeGiB
$config.dbVolumeSizeGiB = $dbVolumeSizeGiB
$config.dbSlaveVolumeSizeGiB = $dbSlaveVolumeSizeGiB
$config.dbSlaveBackupVolumeSizeGiB = $dbSlaveVolumeSizeGiB
$config.minioVolumeSizeGiB = $minioVolumeSizeGiB
$config.storageClassName = $storageClassName

$config.webNodeSelector = New-KeyValueFromTuple $codeDxNodeSelector
$config.masterDatabaseNodeSelector = New-KeyValueFromTuple $masterDatabaseNodeSelector
$config.subordinateDatabaseNodeSelector = New-KeyValueFromTuple $subordinateDatabaseNodeSelector
$config.toolServiceNodeSelector = New-KeyValueFromTuple $toolServiceNodeSelector
$config.minioNodeSelector = New-KeyValueFromTuple $minioNodeSelector
$config.workflowControllerNodeSelector = New-KeyValueFromTuple $workflowControllerNodeSelector
$config.toolNodeSelector = New-KeyValueFromTuple $toolNodeSelector

$config.webNoScheduleExecuteToleration = New-KeyValueFromTuple $codeDxNoScheduleExecuteToleration
$config.masterDatabaseNoScheduleExecuteToleration = New-KeyValueFromTuple $masterDatabaseNoScheduleExecuteToleration
$config.subordinateDatabaseNoScheduleExecuteToleration = New-KeyValueFromTuple $subordinateDatabaseNoScheduleExecuteToleration
$config.toolServiceNoScheduleExecuteToleration = New-KeyValueFromTuple $toolServiceNoScheduleExecuteToleration
$config.minioNoScheduleExecuteToleration = New-KeyValueFromTuple $minioNoScheduleExecuteToleration
$config.workflowControllerNoScheduleExecuteToleration = New-KeyValueFromTuple $workflowControllerNoScheduleExecuteToleration
$config.toolNoScheduleExecuteToleration = New-KeyValueFromTuple $toolNoScheduleExecuteToleration

$configFilePwd = Read-HostSecureText -Prompt "`nEnter config file password"

if ($config.ShouldLock()) {
	$config.Lock($configFilePwd)
}

$configJson = [IO.Path]::GetFullPath((Join-Path $config.workDir 'config.json'))

Write-Host "Writing $configJson..."
$config | ConvertTo-Json | Out-File $configJson

$helmPrepSetup = [IO.Path]::GetFullPath((Join-Path $config.workDir 'run-helm-prep.ps1'))
Write-Host "Writing $helmPrepSetup..."

$setupScript = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../ps/helm-prep.ps1'))
"$setupScript -configPath '$configJson'" | Out-File $helmPrepSetup

if ('' -ne $backupType) {
	Write-Host "`n---`nWARNING: Your backup configuration cannot be migrated automatically.`n"
}

$extraValuesFiles = $extraCodeDxValuesPaths + $extraToolOrchestrationValuesPath
if ($extraValuesFiles.Length -gt 0) {
	Write-Host "`n---`nWARNING: You must map these files to the new deployment because they cannot be migrated automatically. Refer to https://github.com/synopsys-sig/srm-k8s/blob/docs/deploy/docs/DeploymentGuide.md#customizing-software-risk-manager-props for details on how to specify SRM properties. For extra value files referencing legacy chart values, refer to the new chart's values documentation at https://github.com/synopsys-sig/srm-k8s/tree/main/chart. Remember to reference your migrated files with the '-f' parameter when invoking the helm command that will be generated for you by the Helm Prep script. Contact Synopsys for help with this task.`n"
	$extraValuesFiles | ForEach-Object {
		Write-Host "  - $_"
	}
	Write-Host "---"
}

Write-Host "Run the following to generate K8s/helm resources: pwsh $helmPrepSetup"
