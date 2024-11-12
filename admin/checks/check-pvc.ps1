<#PSScriptInfo
.VERSION 1.0.0
.GUID c5f424a7-7d68-483a-80b8-f842815e72b7
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>

<# 
.DESCRIPTION 
This script runs a test using a pod and PVC.
#>

param (
	[string] $namespace = 'default',
	[string] $podName = 'code-dx-test-pod',
	[string] $pvcName = 'code-dx-test-pvc',
	[Parameter(Mandatory=$true)][string] $storageClassName,
	[Parameter(Mandatory=$true)][int]    $securityContextRunAsUserID,
	[Parameter(Mandatory=$true)][int]    $securityContextFsGroupID
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/checks/.ps/.check-pvc.ps1' @PSBoundParameters