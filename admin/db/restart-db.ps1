<#PSScriptInfo
.VERSION 1.0.0
.GUID e3f56093-60e5-4035-8e61-f4bad1bebae9
.AUTHOR Synopsys
#>

<# 
.DESCRIPTION 
This script automates the process of restarting the MariaDB databases.
#>

param (
	[string] $namespace = 'srm',
	[string] $releaseName = 'srm',
	[int]    $waitSeconds = 600,
	[switch] $skipWebRestart
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

'../../.install-guided-setup-module.ps1' | ForEach-Object {
	$path = join-path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire GitHub repository and rerun the downloaded copy of this script."
	}
	. $path
}

if (-not (Test-HelmRelease $namespace $releaseName)) {
	Write-Error "Unable to find Helm release named $releaseName in namespace $namespace."
}

$deploymentSRM = "$(Get-HelmChartFullname $releaseName 'srm')-web"
$statefulSetMariaDBMaster = "$releaseName-mariadb-master"
$statefulSetMariaDBSlave = "$releaseName-mariadb-slave"

# identify the number of replicas
$statefulSetMariaDBSlaveCount = 0
if ($values.mariadb.replication.enabled) {
	$statefulSetMariaDBSlaveCount = $values.mariadb.slave.replicas
	if ($null -eq $statefulSetMariaDBSlaveCount) {
		$statefulSetMariaDBSlaveCount = 1 # 1 is the default value
	}
}

if ($statefulSetMariaDBSlaveCount -eq 0) {
	$statefulSetMariaDBMaster = "$releaseName-mariadb"
	$statefulSetMariaDBSlave = ''
}

if (-not (Test-Deployment $namespace $deploymentSRM)) {
	Write-Error "Unable to find Deployment named $deploymentSRM in namespace $namespace."
}

if (-not (Test-StatefulSet $namespace $statefulSetMariaDBMaster)) {
	Write-Error "Unable to find StatefulSet named $statefulSetMariaDBMaster in namespace $namespace."
}

if ($statefulSetMariaDBSlaveCount -ne 0 -and (-not (Test-StatefulSet $namespace $statefulSetMariaDBSlave))) {
	Write-Error "Unable to find StatefulSet named $statefulSetMariaDBSlave in namespace $namespace."
}

Write-Host @"

Using the following configuration:

SRM Web Deployment Name: $deploymentSRM
MariaDB Master StatefulSet Name: $statefulSetMariaDBMaster
MariaDB Slave StatefulSet Name: $statefulSetMariaDBSlave
MariaDB Slave Replica Count: $statefulSetMariaDBSlaveCount

"@

Write-Verbose "Stopping SRM Web deployment named $deploymentSRM..."
Set-DeploymentReplicas  $namespace $deploymentSRM 0 $waitSeconds

Write-Verbose "Stopping $statefulSetMariaDBMaster statefulset replica..."
Set-StatefulSetReplicas $namespace $statefulSetMariaDBMaster 0 $waitSeconds

if ($statefulSetMariaDBSlaveCount -ne 0) {
	Write-Verbose "Stopping $statefulSetMariaDBSlave statefulset replica(s)..."
	Set-StatefulSetReplicas $namespace $statefulSetMariaDBSlave 0 $waitSeconds
}

Write-Verbose "Starting $statefulSetMariaDBMaster statefulset replica..."
Set-StatefulSetReplicas $namespace $statefulSetMariaDBMaster 1 $waitSeconds

if ($statefulSetMariaDBSlaveCount -ne 0) {
	Write-Verbose "Starting $statefulSetMariaDBSlave statefulset replica(s)..."
	Set-StatefulSetReplicas $namespace $statefulSetMariaDBSlave $statefulSetMariaDBSlaveCount $waitSeconds
}

if (-not $skipWebRestart) {
	Write-Verbose "Starting SRM Web deployment named $deploymentSRM..."
	Set-DeploymentReplicas  $namespace $deploymentSRM 1 $waitSeconds
}

Write-Host 'Done'
