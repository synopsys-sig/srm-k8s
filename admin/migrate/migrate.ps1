<#PSScriptInfo
.VERSION 1.0.0
.GUID b50a27fd-f6dc-4467-881f-7e8faa15f27a
.AUTHOR Synopsys
.DESCRIPTION Starts the SRM Helm Prep Wizard after conditionally helping with module installation.
#>

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

. $PSScriptRoot/../../.install-guided-setup-module.ps1
. $PSScriptRoot/ps/.migrate.ps1 @args

