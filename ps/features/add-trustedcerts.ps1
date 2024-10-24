<#PSScriptInfo
.VERSION 1.0.0
.GUID 48677363-824b-491f-8b95-caa9a9c03e82
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'ps/features/.ps/.add-trustedcerts.ps1' @PSBoundParameters