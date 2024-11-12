<#PSScriptInfo
.VERSION 1.0.0
.GUID 6c23e31b-f893-45e3-928a-d35d859918bc
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/config/.ps/.lock-config.ps1' @PSBoundParameters