<#PSScriptInfo
.VERSION 1.9
.GUID 31739033-88f1-425d-be17-ed5ad608d005
.AUTHOR Synopsys
#>

<# 
.DESCRIPTION 
This script generates Flux v2 artifacts from the output of the Helm Prep Script.
#>

param (
	[string]   $workDir = "$HOME/.k8s-srm",
	[Parameter(Mandatory=$true)][string] $namespace,
	[Parameter(Mandatory=$true)][string] $releaseName,
	[string]   $helmChartRepoUrl = 'https://synopsys-sig.github.io/srm-k8s',
	[string]   $helmChartVersion = '1.13.0',
	[string[]] $extraValuesFiles = @(),
	[switch]   $useSealedSecrets,
	[string]   $sealedSecretsNamespace = 'flux-system',
	[string]   $sealedSecretsControllerName = 'sealed-secrets-controller',
	[string]   $sealedSecretsPublicKeyPath
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

'../../.install-guided-setup-module.ps1',
'../../ps/external/powershell-algorithms/data-structures.ps1',
'../../ps/build/yaml.ps1',
'../../ps/keyvalue.ps1',
'../../ps/config.ps1' | ForEach-Object {
	$path = join-path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire GitHub repository and rerun the downloaded copy of this script."
	}
	. $path
}

function New-ResourceDirectory([string] $parentPath, [string] $name, [switch] $removeExisting) {

	$dir = Join-Path $parentPath $name
	if ((Test-Path $dir -Type Container) -and $removeExisting) {
		Remove-Item $dir -Recurse -Force | Out-Null
	}

	if (-not (Test-Path $dir -Type Container)) {
		New-Item -Path $dir -Type Directory | Out-Null
	}
	$dir
}

if ($useSealedSecrets) {
	Write-Verbose 'Searching for kubeseal program...'
    if ($null -eq (Get-AppCommandPath 'kubeseal')) {
		Write-ErrorMessageAndExit 'Expected to find kubeseal application - is it in your PATH?'
	}
}

$workDirChartResources = Join-Path $workDir 'chart-resources'
$workDirChartValuesCombined = Join-Path $workDir 'chart-values-combined'

$configJsonPath = Join-Path $workDir 'config.json'

if (-not (Test-Path $configJsonPath -PathType Leaf)) {
	Write-ErrorMessageAndExit "Unable to continue because a config.json file was not found in $workDir."
}

$config = [Config]::FromJsonFile($configJsonPath)

if (-not (Test-Path $workDirChartValuesCombined -PathType Container)) {
	Write-ErrorMessageAndExit "Unable to continue because an expected directory ($workDirChartValuesCombined) was not found."
}

# Flux v2 artifacts will be stored in the 'flux-v2' subdirectory
Write-Verbose "Creating flux-v2 directory at $workDir..."
$fluxDir = New-ResourceDirectory $workDir 'flux-v2' -removeExisting

# Optionally create files for CRD resources
if (-not $config.skipToolOrchestration) {

	$crd = New-ResourceDirectory $fluxDir 'CRD'

	'argoproj.io_clusterworkflowtemplates.yaml',
	'argoproj.io_cronworkflows.yaml',
	'argoproj.io_workfloweventbindings.yaml',
	'argoproj.io_workflows.yaml',
	'argoproj.io_workflowtemplates.yaml' | ForEach-Object {

		$url = "https://raw.githubusercontent.com/synopsys-sig/srm-k8s/main/crds/v1/$_"

		Write-Verbose "Downloading $url..."
		$response = Invoke-WebRequest $url
		$response.Content | Out-File (Join-Path $crd $_) -NoNewline
	}
}

# Organize resources into kind directories
Write-Verbose "Organizing K8s resources..."
Get-ChildItem $workDirChartResources -Filter '*.yaml' | ForEach-Object {

	$yaml = Get-Yaml $_

	$kindKey = $yaml.nodeGraph.vertices | ForEach-Object { $_.keys } | Where-Object { $yaml.nodeGraph.vertices[$_].key -eq 'kind' } | ForEach-Object { $_ }
	if ($null -eq $kindKey) {
		Write-ErrorMessageAndExit "Unable to find kind property for resource in file $_"
	}
	$kindValue = $yaml.nodeGraph.vertices[$kindKey].keyValue

	$kindDir = New-ResourceDirectory $fluxDir $kindValue
	Copy-Item -LiteralPath $_ -Destination $kindDir
}

# Optionally use Bitnami's Sealed Secrets, replacing related resources
if ($useSealedSecrets) {
	
	Get-ChildItem (Join-Path $fluxDir 'Secret') -Filter '*.yaml' | ForEach-Object {

		Write-Verbose "Running kubeseal on $_..."
		$sealedSecretsDir = New-ResourceDirectory $fluxDir 'SealedSecret'
		$sealedSecretsPath = Join-Path $sealedSecretsDir (Split-Path $_ -Leaf)
		kubeseal --controller-name=$sealedSecretsControllerName --controller-namespace=$sealedSecretsNamespace --secret-file $_ --format yaml --cert $sealedSecretsPublicKeyPath > $sealedSecretsPath
		if ($LASTEXITCODE -ne 0) {
			Write-ErrorMessageAndExit "Unexpected exit code ($LASTEXITCODE) from kubeseal while processing '$_'"
		}

		Write-Verbose "Removing $_..."
		Remove-Item $_ -Force # Replace $_ with SealedSecret resource
	}
}
$valuesFiles = @()

# Optionally include tool orchestration configuration
if (-not $config.skipToolOrchestration) {
	$valuesFiles += [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../chart/values/values-to.yaml'))
}

# Optionally TLS configuration (a $config.notes msg will request doing the prework in the comments of values-tls.yaml)
if (-not $config.skipTls) {
	$valuesFiles += [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../chart/values/values-tls.yaml'))
}

$valuesFiles += (Join-Path $workDirChartValuesCombined 'values-combined.yaml')

$valuesFiles += $extraValuesFiles

$configMapDir = New-ResourceDirectory $fluxDir 'ConfigMap'

$valuesConfigMapReferences = @()
$valuesFileCount = 0
$valuesFiles | ForEach-Object {

	Write-Verbose "Processing values file $_..."
	$valuesId = $valuesFileCount++
	@"
kind: ConfigMap
apiVersion: v1
metadata:
  name: helmrelease-values-$valuesId
  namespace: $namespace
data:
  values.yaml: |
    $([string]::join("`n    ", (Get-Content $_)))
"@ | Out-File (Join-Path $configMapDir "helmrelease-values-$valuesId.yaml") -NoNewline

	$valuesConfigMapReferences += '- kind: ConfigMap'
	$valuesConfigMapReferences += "  name: helmrelease-values-$valuesId"
}

@"
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: srm
  namespace: $namespace
spec:
  interval: 1m
  url: $helmChartRepoUrl
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'HelmRepository') 'repo.yaml') -NoNewline

@"
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: srm
  namespace: $namespace
spec:
  releaseName: $releaseName
  timeout: 30m0s
  chart:
    spec:
      chart: srm
      version: $helmChartVersion
      sourceRef:
        kind: HelmRepository
        name: srm
        namespace: $namespace
  valuesFrom:
    $([string]::join("`n    ",$valuesConfigMapReferences))
  interval: 1m0s
  install:
    skipCRDs: true
# values:
#   web:
#     image:
#       tag: web-tag
#   mariadb:
#     image:
#       tag: db-tag
#   to:
#     image:
#       tag: tool-orchestration-tag
#   minio:
#     image:
#       tag: minio-tag
#   argo:
#     images:
#       tag: workflow-tag
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'HelmRelease') 'release.yaml') -NoNewline

@"
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'Namespace') 'namespace.yaml') -NoNewline

