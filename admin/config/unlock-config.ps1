using module @{ModuleName='guided-setup'; RequiredVersion='1.15.0' }
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

$ErrorActionPreference = 'Stop'
Set-PSDebug -Strict

'../../ps/keyvalue.ps1',
'../../ps/build/protect.ps1',
'../../ps/config.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

$config = [Config]::FromJsonFile($configPath)

if (-not $config.isLocked) {
	Write-Error "Config file '$configPath' is already unlocked."
}

if ([string]::IsNullOrEmpty($configFilePwd)) {
	$configFilePwd = Read-HostSecureText -Prompt 'Enter config file password'
}

$config.Unlock($configFilePwd)
$config | ConvertTo-Json | Out-File $configPath