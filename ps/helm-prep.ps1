<#PSScriptInfo
.VERSION 1.0.0
.GUID 6ec2869a-938b-4b49-8e64-28f0ad5876dc
.AUTHOR Synopsys
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd,
	[switch] $skipYamlMerge
)

& "$PSScriptRoot/../.start.ps1" -startScriptPath 'ps/.helm-prep.ps1' @PSBoundParameters