<#PSScriptInfo
.VERSION 1.1.0
.GUID 0ef2e57d-85d5-43e5-8ba5-b95e4d69c1af
.AUTHOR Synopsys
.DESCRIPTION Starts the SRM Helm Prep Wizard after conditionally helping with module installation.
#>

& "$PSScriptRoot/.start.ps1" -startScriptPath '.helm-prep-wizard.ps1'
