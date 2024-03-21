<#PSScriptInfo
.VERSION 1.0.0
.GUID cfd2621d-ea87-4cc3-b059-d065efeec238
.AUTHOR Synopsys
.DESCRIPTION Starts the specified script after testing pwsh requirements
and conditionally helping with module installation. Note that the 
$scriptPath script must not include a scriptPath parameter.
#>

param (
	[string] $scriptPath # absolute path or path relative to .script-wrapper.ps1
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

if ([string]::IsNullOrWhiteSpace($scriptPath)) {

	# avoid use of [Parameter(Mandatory=$true)] for $scriptPath because it affects parameter splatting in calling script
	Write-Host 'Missing required parameter -scriptPath'
	Exit 1
}

# ensure pwsh environment meets requirements
. $PSScriptRoot/.pwsh-check.ps1
if (-not $?) {
	Exit $LASTEXITCODE
}

# install guided-setup module from pwsh gallery (see script for manual deployment instructions)
. $PSScriptRoot/.install-guided-setup-module.ps1

# unbound arguments are considered $scriptPath arguments
$unboundArguments = $MyInvocation.UnboundArguments

# relative paths are relative to script root
if (-not ([IO.Path]::IsPathRooted($scriptPath))) {
	$scriptPath = Join-Path $PSScriptRoot $scriptPath
}

. $scriptPath @unboundArguments
