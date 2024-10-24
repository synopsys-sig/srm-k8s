<#PSScriptInfo
.VERSION 1.2.0
.GUID 46b422ab-4460-430e-912e-10133a0cf1be
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
.DESCRIPTION Move any project secrets and resource requirements from one namespace/cluster to another.
#>

param (
	[string] $codeDxNamespace = 'cdx-svc',
	[string] $srmNamespace = 'srm',
	[string] $srmKubeConfigPath,
	[string] $srmKubeContextName,
	[switch] $skipResourceRequirements
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

# ensure pwsh environment meets requirements
. $PSScriptRoot/../../.pwsh-check.ps1
if (-not $?) {
	Exit $LASTEXITCODE
}

$srmKubeParams = @()
if ($srmKubeConfigPath -ne '' -and $srmKubeContextName -ne '') {
	$srmKubeParams += '--kubeconfig'
	$srmKubeParams += Resolve-Path $srmKubeConfigPath | Select-Object -ExpandProperty 'Path'
	$srmKubeParams += '--context'
	$srmKubeParams += $srmKubeContextName
}

Write-Host "`nFetching project secrets from namespace $codeDxNamespace..."
$wfSecrets = kubectl -n $codeDxNamespace get secret -l codedx-orchestration.secretType=workflowSecret -o json | ConvertFrom-Json
$wfSecrets.items | ForEach-Object { 
	Write-Host "`nCopying resource $($_.metadata.name) from $codeDxNamespace to $srmNamespace..."
	$_.metadata.namespace=$srmNamespace; $_ | ConvertTo-Json | kubectl @srmKubeParams apply -f -
}

if (-not $skipResourceRequirements) {

	Write-Host "`nFetching resource requirement names from namespace $codeDxNamespace..."
	$rrNames = kubectl -n $codeDxNamespace get cm -o name | Where-Object { $_ -like '*resource-requirements' -and $_ -ne 'configmap/cdx-toolsvc-resource-requirements' }
	$rrNames | ForEach-Object { 
		Write-Host "`nFetching resource $_..."
		$rrJson = kubectl -n $codeDxNamespace get $_ -o json | ConvertFrom-Json
		Write-Host "Copying resource $_ from $codeDxNamespace to $srmNamespace..."
		$rrJson.metadata.namespace=$srmNamespace; $rrJson | ConvertTo-Json | kubectl @srmKubeParams apply -f -
	}
}