param (
	[Parameter(Mandatory=$true)][string] $repoDir,
	[Parameter(Mandatory=$true)][string] $chartVersion,
	[Parameter(Mandatory=$true)][string] $webTag
)

$ErrorActionPreference = 'Stop'
$VerbosePreference     = 'Continue'
Set-PSDebug -Strict

'./ps/chart.ps1',
'./ps/common.ps1',
'./ps/path.ps1',
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

$chartYamlPath = Join-Path (Get-ChartPath $repoDir) 'Chart.yaml'
Set-HelmChartVersion $chartYamlPath $chartVersion $webTag
