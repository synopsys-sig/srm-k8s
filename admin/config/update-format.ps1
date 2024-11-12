<#PSScriptInfo
.VERSION 1.0.0
.GUID 9b72e210-51a0-422e-97c3-139648157efd
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/config/.ps/.update-format.ps1' @PSBoundParameters