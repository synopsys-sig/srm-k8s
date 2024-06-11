<#PSScriptInfo
.VERSION 1.0.0
.GUID c5f424a7-7d68-483a-80b8-f842815e72b7
.AUTHOR Synopsys
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

$ErrorActionPreference = 'Stop'
Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

$VerbosePreference = 'Continue'

$yaml = @'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {3}
  namespace: {0}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: {2}
---
apiVersion: v1
kind: Pod
metadata:
  name: {1}
  namespace: {0}
spec:
  securityContext:
    runAsUser: {4}
    fsGroup: {5}
  containers:
    - image: busybox
      name: busybox
      command: ["sh","-c","echo 'test' > /data/test; while [ -f /data/test ]; do sleep 1; done;"]
      volumeMounts:
      - mountPath: "/data"
        name: code-dx-test-vol
  volumes:
    - name: code-dx-test-vol
      persistentVolumeClaim:
        claimName: {3}
'@ -f $namespace, $podName, $storageClassName, $pvcName, $securityContextRunAsUserID, $securityContextFsGroupID

Write-Host "Testing for pod $podName in namespace $namespace..."
if (Test-Pod $namespace $podName) {
	Write-Host "Removing pod $podName in namespace $namespace..."
	Remove-Pod $namespace $podName
}

$file = [io.path]::GetTempFileName()
$yaml | out-file $file -Encoding ascii

Write-Host "Creating pod $podName in namespace $namespace..."
New-NamespacedResource $namespace 'pod' $podName $file
Remove-Item -path $file

Wait-RunningPod "Waiting for pod $podName in namespace $namespace..." 300 $namespace $podName

$testFile = '/data/test'
$success = $true
@('cat', $testFile),@('chmod', 700, $testFile),@('rm', $testFile) | ForEach-Object {

	$cmd = $_
	Write-Host "Test -> $([string]::join(' ', $cmd))"
	kubectl -n $namespace exec $podName -- @cmd
	$success = $success -and $LASTEXITCODE -eq 0
}

Write-Host "Removing pod $podName in namespace $namespace..."
Remove-Pod $namespace $podName
Write-Host "Removing pvc $pvcName in namespace $namespace..."
Remove-KubernetesPvc $namespace $pvcName

Write-Host ($success ? 'Done' : 'Failed')
