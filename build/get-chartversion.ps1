param (
	[Parameter(Mandatory=$true)][string] $repoDir
)

$ErrorActionPreference = 'Stop'
$VerbosePreference     = 'Continue'
Set-PSDebug -Strict

'./ps/chart.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

Get-HelmChartVersionString (Join-Path $repoDir 'chart/Chart.yaml')