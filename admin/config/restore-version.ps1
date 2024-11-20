<#PSScriptInfo
.VERSION 1.0.0
.GUID 2a0a3d49-beb5-43d0-9f0e-c00437c61113
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/config/.ps/.restore-version.ps1' @PSBoundParameters