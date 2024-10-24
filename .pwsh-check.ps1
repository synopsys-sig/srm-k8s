<#PSScriptInfo
.VERSION 1.0.0
.GUID 7f63d41a-acd4-470e-9fc2-b8c99208d17d
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
.DESCRIPTION Tests PowerShell edition and version requirements.
#>

# link to PowerShell install instructions for Windows, macOS, and Linux
$powerShellInstallLink = 'https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell'

$requiredEdition = 'Core' # Windows PowerShell is unsupported

if ($PSVersionTable.PSEdition -ne $requiredEdition) {

	$PSVersionTable.Keys | ForEach-Object {
		Write-Host "  $_`: $($PSVersionTable[$_])"
	}
	Write-Host "`nThis PowerShell edition ($($PSVersionTable.PSEdition)) is unsupported. You must install PowerShell Core by following the instructions at $powerShellInstallLink.`n"
	Exit 2
}

# The Core PSEdition includes the SemanticVersion type, which is unavailable on Windows PowerShell
$minimumVersion = New-Object System.Management.Automation.SemanticVersion('7.0.0')

if ($PSVersionTable.PSVersion -lt $minimumVersion) {

	Write-Host "This version of PowerShell ($($PSVersionTable.PSVersion)) is too old (the minimum version is $minimumVersion). Install a newer version by following the instructions at $powerShellInstallLink.`n"
	Exit 3
}