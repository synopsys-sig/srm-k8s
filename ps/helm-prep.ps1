<#PSScriptInfo
.VERSION 1.5.0
.GUID 11157c15-18d1-42c4-9d13-fa66ef61d5b2
.AUTHOR Synopsys
#>

using module @{ModuleName='guided-setup'; RequiredVersion='1.16.0' }
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd,
	[switch] $skipYamlMerge
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-PSDebug -Strict

Write-Host 'Loading...' -NoNewline

'./external/powershell-algorithms/data-structures.ps1',
'./keyvalue.ps1',
'./config.ps1',
'./build/component.ps1',
'./build/cpu.ps1',
'./build/auth.ps1',
'./build/database.ps1',
'./build/ephemeralstorage.ps1',
'./build/image.ps1',
'./build/ingress.ps1',
'./build/java.ps1',
'./build/license.ps1',
'./build/memory.ps1',
'./build/netpol.ps1',
'./build/paths.ps1',
'./build/protect.ps1',
'./build/provider.ps1',
'./build/reg.ps1',
'./build/scanfarm.ps1',
'./build/scanfarm-cache.ps1',
'./build/scanfarm-db.ps1',
'./build/scanfarm-storage.ps1',
'./build/schedule.ps1',
'./build/to.ps1',
'./build/volume.ps1',
'./build/web.ps1',
'./build/yaml.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

try {
	# Check for required parameters
	if (-not (Test-Path $configPath -PathType Leaf)) {
		Write-ErrorMessageAndExit "Unable to find config file at $configPath"
	}

	$config = [Config]::FromJsonFile($configPath)

	if ($config.isLocked) {

		if ($configFilePwd -eq '') {
			$configFilePwd = $Env:HELM_PREP_CONFIGFILEPWD

			if ([string]::IsNullOrEmpty($configFilePwd)) {
				$configFilePwd = Read-HostSecureText -Prompt "`nEnter config file password"
			}
		}
		$config.Unlock($configFilePwd)	
	}

	# Check for kubectl (required to create YAML resources)
	if ($null -eq (Get-AppCommandPath kubectl)) {
		Write-ErrorMessageAndExit "Restart this script after adding kubectl to your PATH environment variable."
	}

	$useCustomCacerts = -not [string]::IsNullOrEmpty($config.caCertsFilePath)

	# Check for keytool (required for updating cacerts)
	if ($useCustomCacerts -and $null -eq (Get-AppCommandPath keytool)) {
		Write-ErrorMessageAndExit "Restart this script after adding Java JRE (specifically Java's keytool program) to your PATH environment variable."
	}

	# Validate work directory
	if (-not (Test-Path $config.workDir -PathType Container)) {
		Write-ErrorMessageAndExit "Unable to find work directory at $($config.workDir). Does the work directory exist?"
	}

	# Validate files
	'clusterCertificateAuthorityCertPath',
	'externalWorkflowStorageCertChainPath',
	'samlIdentityProviderMetadataPath',
	'caCertsFilePath',
	'srmLicenseFile',
	'scanFarmSastLicenseFile',
	'scanFarmScaLicenseFile',
	'caCertsFilePath' | ForEach-Object {
		$fileValue = $config.$_
		if ((-not ([String]::IsNullOrEmpty($fileValue))) -and 
			(-not (Test-Path $fileValue -PathType Leaf))) {
			Write-ErrorMessageAndExit "Unable to find file '$fileValue' for '$_' config parameter. Does the file exist?"
		}
	}
	$config.extraTrustedCaCertPaths | ForEach-Object {
		if ((-not ([String]::IsNullOrEmpty($_))) -and 
			(-not (Test-Path $_ -PathType Leaf))) {
			Write-ErrorMessageAndExit "Unable to find file '$_' in the 'extraTrustedCaCertPaths' config parameter. Does the file exist?"
		}
	}

	# Reset work directory
	$config.GetValuesWorkDir(),$config.GetK8sWorkDir(),$config.GetTempWorkDir(),$config.GetValuesCombinedWorkDir() | ForEach-Object {
		if (Test-Path $_ -PathType Container) {
			Remove-Item $_ -Force -Confirm:$false -Recurse
		}
		New-Item $_ -ItemType Directory | Out-Null
	}

	# A list of built-in values files that may be overriden by specified deployment configuration
	$builtInValues = @()

	# Stage cacerts
	if (-not [string]::IsNullOrEmpty($config.caCertsFilePath)) {
		Copy-Item $config.caCertsFilePath (Get-CertsPath $config)
	}

	# Handle tool orchestration configuration
	if (-not $config.skipToolOrchestration) {
		$builtInValues += [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../chart/values/values-to.yaml'))
		New-ToolOrchestrationConfig $config
	}

	# Handle TLS configuration (a $config.notes msg will request doing the prework in the comments of values-tls.yaml)
	if (-not $config.skipTls) {
		$builtInValues += [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../chart/values/values-tls.yaml'))
	}

	# Handle network policy configuration
	if (-not $config.skipNetworkPolicies) {
		New-NetworkPolicyConfig $config
	}

	# Handle Docker registry requiring a credential
	if (-not $config.skipDockerRegistryCredential) {
		New-DockerImagePullSecretConfig $config
	}

	if ($config.k8sProvider -eq 'OpenShift') {
		New-OpenShiftConfig $config
	}

	New-LicenseConfig $config
	New-DatabaseConfig $config

	if (-not $config.useGeneratedPwds) {
		New-WebSecretConfig $config
	}

	if ($config.useSaml) {
		New-SamlConfig $config
	}

	# Handle cacerts configuration
	if ($useCustomCacerts) {
		New-CacertsConfig $config
	}

	# Handle Docker registry and repository source that may differ from the default (Docker Hub)
	if (-not $config.skipScanFarm -or $config.useDockerRedirection) {
		New-DockerImageLocationConfig $config
	}

	# Handle Docker image version that may differ from what's in chart
	if (-not $config.useDefaultDockerImages) {
		New-DockerImageVersionConfig $config
	}

	New-ServiceConfig $config

	if (-not $config.skipIngressEnabled) {
		New-IngressConfig $config
	}

	if (-not $config.skipScanFarm) {
		New-ScanFarmConfig $config
	}

	New-CPUConfig $config
	New-MemoryConfig $config
	New-EphemeralStorageConfig $config
	New-VolumeSizeConfig $config
	New-VolumeStorageClassConfig $config

	New-NodeSelectorConfig $config
	New-TolerationConfig $config

	# Print Notes:
	if ($config.notes.Count -gt 0) {
		Write-Host "`n`n----------------------`nK8s Installation Notes`n----------------------"
		$config.notes | ForEach-Object {
			Write-Host $_.value
		}
	}

	# Print K8s namespace
	Write-Host "`n`n----------------------`nRequired K8s Namespace`n----------------------"
	Write-Host "kubectl create namespace $($config.namespace)"

	if (-not $config.skipToolOrchestration) {
		# Print K8s CRDs
		Write-Host "`n`n----------------------`nRequired K8s CRDs`n----------------------"
		$crdsPath = Join-Path $PSScriptRoot '..' 'crds/v1'
		Write-Host "kubectl apply -f ""$([io.path]::GetFullPath($crdsPath))"""
	}

	# Print K8s resources
	$k8sWorkDir = $config.GetK8sWorkDir()
	$resourceCount = (Get-ChildItem $k8sWorkDir).Length
	if ($resourceCount -gt 0) {
		Write-Host "`n----------------------`nRequired K8s Resources`n----------------------"
		Write-Host "kubectl apply -f ""$k8sWorkDir"""
	}

	# Print helm commands
	$chartPath = Join-Path $PSScriptRoot '../chart'
	$chartFullPath = [IO.Path]::GetFullPath($chartPath)
	Write-Host "`n----------------------`nRequired Helm Commands`n----------------------"
	Write-Host "helm repo add codedx https://codedx.github.io/codedx-kubernetes"
	Write-Host "helm repo add cnc https://sig-repo.synopsys.com/artifactory/sig-cloudnative"
	Write-Host "helm repo update"
	Write-Host "helm dependency update ""$chartFullPath"""
	Write-Host "helm -n $($config.namespace) upgrade --reset-values --install $($config.releaseName)" -NoNewline

	$allValuesFiles = $builtInValues

	$postscript = @()
	$generatedValuesFiles = Get-ChildItem $config.GetValuesWorkDir()
	if ($generatedValuesFiles.Length -gt 0) {

		if ($skipYamlMerge) {
			$allValuesFiles += $generatedValuesFiles
		} else {
			try {
				$mergedYaml = Merge-YamlFiles $generatedValuesFiles

				$mergedValuesPath = Join-Path ($config.GetValuesCombinedWorkDir()) 'values-combined.yaml'
				$mergedYaml.ToYamlString() | Out-File $mergedValuesPath -NoNewline

				$allValuesFiles += $mergedValuesPath
			} catch {
				$postscript += "Warning: YAML merge failed with error '$_' - your helm command references generated values files instead.`n"
				$allValuesFiles += $generatedValuesFiles
			}
		}
	}

	$allValuesFiles | ForEach-Object {
		Write-Host " -f ""$_""" -NoNewline
	}

	# SRM upgrades can take a really long time (e.g., 30 minutes), so we must allow the upgrade hook to finish
	if (-not $config.skipScanFarm) {
		Write-Host " --timeout 30m0s" -NoNewline
	}
	Write-Host " ""$chartFullPath""`n`n"

	$postscript | ForEach-Object {
		Write-Host "$_`n"
	}
} catch {
	Write-Host "`n`nAn unexpected error occurred: $_`n"
	Write-Host $_.ScriptStackTrace
}