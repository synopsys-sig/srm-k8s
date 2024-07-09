param (
	[Parameter(Mandatory=$true)][string] $repoDir,
	[Parameter(Mandatory=$true)][string] $webTag,
	[Parameter(Mandatory=$true)][string] $dbTag,
	[Parameter(Mandatory=$true)][string] $toTag,
	[Parameter(Mandatory=$true)][string] $dbRestoreTag
)

$ErrorActionPreference = 'Stop'
$VerbosePreference     = 'Continue'
Set-PSDebug -Strict

'./ps/chart.ps1',
'./ps/common.ps1',
'./ps/db.ps1',
'./ps/path.ps1',
'./ps/script.ps1',
'./ps/to.ps1',
'./ps/web.ps1',
'./ps/yaml.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

Get-Command 'yq' -CommandType Application -ErrorAction SilentlyContinue | Out-Null
if (-not $?) {
	throw "Expected to find the 'yq' program in your PATH"
}

Push-Location (Join-Path $PSScriptRoot '..')

Set-WebChartTag $repoDir $webTag
Set-WebRegistryDocTag $repoDir $webTag
Set-WebDeploymentGuideTag $repoDir $webTag

Set-DatabaseChartTag $repoDir $dbTag
Set-DatabaseDocTag $repoDir $dbTag
Set-DatabaseDeploymentGuideTag $repoDir $dbTag

Set-ToolOrchestrationChartTag $repoDir $toTag
Set-ToolOrchestrationRegistryDocTag $repoDir $toTag
Set-ToolOrchestrationDeploymentGuideTag $repoDir $toTag

if (-not (Test-RestoreDatabaseTag $repoDir $dbRestoreTag)) {
	Set-RestoreDatabaseTag $repoDir $dbRestoreTag
}
