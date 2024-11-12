<#PSScriptInfo
.VERSION 1.0.0
.GUID 2327ad0b-6d8a-4900-be5a-ff40681dabf4
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'ps/features/.ps/.set-passwords.ps1' @PSBoundParameters
