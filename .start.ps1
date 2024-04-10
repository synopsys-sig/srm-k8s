<#PSScriptInfo
.VERSION 1.0.0
.GUID cfd2621d-ea87-4cc3-b059-d065efeec238
.AUTHOR Synopsys
.DESCRIPTION Starts the specified script after testing pwsh requirements
and conditionally helping with module installation. Note that the 
$startScriptPath script must not include a startScriptPath parameter.
#>

param (
	[string] $startScriptPath # absolute path or path relative to .start.ps1
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

if ([string]::IsNullOrWhiteSpace($startScriptPath)) {

	# avoid use of [Parameter(Mandatory=$true)] for $startScriptPath because it affects parameter splatting in calling script
	Write-Host 'Missing required parameter -startScriptPath'
	Exit 1
}

# ensure pwsh environment meets requirements
. $PSScriptRoot/.pwsh-check.ps1
if (-not $?) {
	Exit $LASTEXITCODE
}

# install guided-setup module from pwsh gallery (see script for manual deployment instructions)
. $PSScriptRoot/.install-guided-setup-module.ps1

# unbound arguments are considered $startScriptPath arguments and
# bound arguments are considered parameters for this script
$unboundArguments = $MyInvocation.UnboundArguments

# relative paths are relative to script root
if (-not ([IO.Path]::IsPathRooted($startScriptPath))) {
	$startScriptPath = Join-Path $PSScriptRoot $startScriptPath
}

try {
	. $startScriptPath @unboundArguments
} catch {
	throw "Script '$startScriptPath' threw an exception with the following details: $_ ($($_.ScriptStackTrace))"
}
