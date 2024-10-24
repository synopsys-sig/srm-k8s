<#PSScriptInfo
.VERSION 1.0.0
.GUID a7ea4257-8b56-45fd-a518-d1e5b793311c
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/config/.ps/.unlock-config.ps1' @PSBoundParameters