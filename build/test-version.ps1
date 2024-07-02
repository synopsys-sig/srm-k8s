param (
	[Parameter(Mandatory=$true)][string] $repoDir,
	[Parameter(Mandatory=$true)][string] $webTag,
	[Parameter(Mandatory=$true)][string] $dbTag,
	[Parameter(Mandatory=$true)][string] $toTag,
	[Parameter(Mandatory=$true)][string] $workflowTag,
	[Parameter(Mandatory=$true)][string] $dbRestoreTag
)

$ErrorActionPreference = 'Stop'
$VerbosePreference     = 'Continue'
Set-PSDebug -Strict

'./ps/common.ps1',
'./ps/db.ps1',
'./ps/path.ps1',
'./ps/to.ps1',
'./ps/web.ps1',
'./ps/yaml.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

$registryDocPath = Get-RegistryDocPath $repoDir
$restoreDbPath = Get-RestoreDatabaseScriptPath $repoDir
$deploymentGuideDocPath = Get-DeploymentGuidePath $repoDir

(Test-WebChartTag $repoDir $webTag) -and
(Test-DatabaseChartTag $repoDir $dbTag) -and
(Test-ToolOrchestrationChartTag $repoDir $toTag) -and
(Test-WorkflowChartTag $repoDir $workflowTag) -and
(Test-RestoreDatabaseTag $repoDir $dbRestoreTag) -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-tomcat:$webTag") -eq 11 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-tools:$webTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-toolsmono:$webTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-mariadb:$dbTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-prepare:$toTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-newanalysis:$toTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-results:$toTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-tool-service:$toTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-cleanup:$toTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-workflow-controller:$workflowTag") -eq 3 -and
(Get-ReferenceCount $registryDocPath "codedx/codedx-argoexec:$workflowTag") -eq 3 -and
(Get-ReferenceCount $restoreDbPath   "codedx/codedx-dbrestore:$dbRestoreTag") -eq 1 -and
(Get-ReferenceCount $deploymentGuideDocPath "| web.image.tag | string | ``""$webTag""`` | the Docker image version for the SRM web workload |") -eq 1 -and
(Get-ReferenceCount $deploymentGuideDocPath "| mariadb.image.tag | string | ``""$dbTag""`` | the Docker image version for the MariaDB workload |") -eq 1 -and
(Get-ReferenceCount $deploymentGuideDocPath "| to.image.tag | string | ``""$toTag""`` | the Docker image version for the SRM Tool Orchestration workloads (tools and toolsMono use the web.image.tag version)|") -eq 1 -and
(Get-ReferenceCount $deploymentGuideDocPath "| argo-workflows.images.tag | string | ``""$workflowTag""`` | the Docker image version for the Argo workload |") -eq 1
