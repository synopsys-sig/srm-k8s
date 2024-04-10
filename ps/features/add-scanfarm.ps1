<#PSScriptInfo
.VERSION 1.0.0
.GUID aea3e946-e322-4ba0-8fb6-2c41e18bc6bf
.AUTHOR Synopsys
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'ps/features/.ps/.add-scanfarm.ps1' @PSBoundParameters