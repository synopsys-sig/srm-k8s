<#PSScriptInfo
.VERSION 1.5.0
.GUID 5f30b324-9305-4a7c-bd68-f9845d30659e
.AUTHOR SRM
#>

<# 
.DESCRIPTION 
This script automates the process of restoring the MariaDB master database with
a backup generated by a MariaDB slave database and reestablishes data replication.
#>

param (
	[string] $workDirectory = '~',
	[string] $backupToRestore,
	[string] $rootPwd,
	[string] $replicationPwd,
	[string] $namespace = 'srm',
	[string] $releaseName = 'srm',
	[int]    $waitSeconds = 600,
	[string] $imageDatabaseRestore = 'codedx/codedx-dbrestore:v1.12.0',
	[string] $dockerImagePullSecretName,
	[switch] $skipSRMWebRestart
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/db/.ps/.restore-db.ps1' @PSBoundParameters
