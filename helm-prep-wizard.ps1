<#PSScriptInfo
.VERSION 1.0.0
.GUID 0ef2e57d-85d5-43e5-8ba5-b95e4d69c1af
.AUTHOR Synopsys
.DESCRIPTION Starts the SRM Helm Prep Wizard after conditionally helping with module installation.
#>

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

. $PSScriptRoot/.install-guided-setup-module.ps1

# Check for keytool (required for validating certs and cacerts file)
if ($null -eq (Get-AppCommandPath keytool)) {
	Write-ErrorMessageAndExit "Restart this script after adding Java JRE (specifically Java's keytool program) to your PATH environment variable."
}
. $PSScriptRoot/.helm-prep-wizard.ps1
