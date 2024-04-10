<#PSScriptInfo
.VERSION 1.0.0
.GUID a7ea4257-8b56-45fd-a518-d1e5b793311c
.AUTHOR Synopsys
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/config/.ps/.unlock-config.ps1' @PSBoundParameters