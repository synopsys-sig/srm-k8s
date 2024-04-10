<#PSScriptInfo
.VERSION 1.1.0
.GUID e3f56093-60e5-4035-8e61-f4bad1bebae9
.AUTHOR Synopsys
#>

<# 
.DESCRIPTION 
This script automates the process of restarting the MariaDB databases.
#>

param (
	[string] $namespace = 'srm',
	[string] $releaseName = 'srm',
	[int]    $waitSeconds = 600,
	[switch] $skipWebRestart
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/db/.ps/.restart-db.ps1' @PSBoundParameters