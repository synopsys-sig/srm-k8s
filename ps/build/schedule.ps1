function New-WebNodeSelectorConfig($config) {
	@"
web:
  nodeSelector: $(Format-NodeSelector $config.webNodeSelector.ToTuple())
"@ | Out-File (Get-WebNodeSelectorValuesPath $config)
}

function New-MasterDatabaseNodeSelectorConfig($config) {
	@"
mariadb:
  master:
    nodeSelector: $(Format-NodeSelector $config.masterDatabaseNodeSelector.ToTuple())
"@ | Out-File (Get-MasterDatabaseNodeSelectorValuesPath $config)
}

function New-SubordinateDatabaseNodeSelectorConfig($config) {
	@"
mariadb:
  slave:
    nodeSelector: $(Format-NodeSelector $config.subordinateDatabaseNodeSelector.ToTuple())
"@ | Out-File (Get-SubordinateDatabaseNodeSelectorValuesPath $config)
}

function New-ToNodeSelectorConfig($config) {
	@"
to:
  nodeSelector: $(Format-NodeSelector $config.toolServiceNodeSelector.ToTuple())
"@ | Out-File (Get-ToNodeSelectorValuesPath $config)
}

function New-StorageNodeSelectorConfig($config) {
	@"
minio:
  nodeSelector: $(Format-NodeSelector $config.minioNodeSelector.ToTuple())
"@ | Out-File (Get-StorageNodeSelectorValuesPath $config)
}

function New-WorkflowNodeSelectorConfig($config) {
	@"
argo-workflows:
  controller:
    nodeSelector: $(Format-NodeSelector $config.workflowControllerNodeSelector.ToTuple())
"@ | Out-File (Get-WorkflowNodeSelectorValuesPath $config)
}

function New-NodeSelectorConfig($config) {

	New-ComponentConfig $config `
		{ $config.webNodeSelector } New-WebNodeSelectorConfig `
		{ $config.masterDatabaseNodeSelector } New-MasterDatabaseNodeSelectorConfig `
		{ $config.subordinateDatabaseNodeSelector } New-SubordinateDatabaseNodeSelectorConfig `
		{ $false } {} `
		{ $config.toolServiceNodeSelector } New-ToNodeSelectorConfig `
		{ $config.minioNodeSelector } New-StorageNodeSelectorConfig `
		{ $config.workflowControllerNodeSelector } New-WorkflowNodeSelectorConfig

    if (-not $config.skipToolOrchestration -and $config.toolNodeSelector) {
        @"
to:
  tools:
    nodeSelectorKey: $($config.toolNodeSelector.key)
    nodeSelectorValue: $($config.toolNodeSelector.value)
"@ | Out-File (Get-ToolsNodeSelectorValuesPath $config)
    }
}

function New-WebTolerationConfig($config) {
	@"
web:
  tolerations: $(Format-PodTolerationNoScheduleNoExecute $config.webNoScheduleExecuteToleration.ToTuple())
"@ | Out-File (Get-WebTolerationValuesPath $config)
}

function New-MasterDatabaseTolerationConfig($config) {
	@"
mariadb:
  master:
    tolerations: $(Format-PodTolerationNoScheduleNoExecute $config.masterDatabaseNoScheduleExecuteToleration.ToTuple())
"@ | Out-File (Get-MasterDatabaseTolerationValuesPath $config)
}

function New-SubordinateDatabaseTolerationConfig($config) {
	@"
mariadb:
  slave:
    tolerations: $(Format-PodTolerationNoScheduleNoExecute $config.subordinateDatabaseNoScheduleExecuteToleration.ToTuple())
"@ | Out-File (Get-SubordinateDatabaseTolerationValuesPath $config)
}

function New-ToTolerationConfig($config) {
	@"
to:
  tolerations: $(Format-PodTolerationNoScheduleNoExecute $config.toolServiceNoScheduleExecuteToleration.ToTuple())
"@ | Out-File (Get-ToTolerationValuesPath $config)
}

function New-StorageTolerationConfig($config) {
	@"
minio:
  tolerations: $(Format-PodTolerationNoScheduleNoExecute $config.minioNoScheduleExecuteToleration.ToTuple())
"@ | Out-File (Get-StorageTolerationValuesPath $config)
}

function New-WorkflowTolerationConfig($config) {
	@"
argo-workflows:
  controller:
    tolerations: $(Format-PodTolerationNoScheduleNoExecute $config.workflowControllerNoScheduleExecuteToleration.ToTuple())
"@ | Out-File (Get-WorkflowTolerationValuesPath $config)
}

function New-TolerationConfig($config) {

	New-ComponentConfig $config `
		{ $config.webNoScheduleExecuteToleration } New-WebTolerationConfig `
		{ $config.masterDatabaseNoScheduleExecuteToleration } New-MasterDatabaseTolerationConfig `
		{ $config.subordinateDatabaseNoScheduleExecuteToleration } New-SubordinateDatabaseTolerationConfig `
		{ $false } {} `
		{ $config.toolServiceNoScheduleExecuteToleration } New-ToTolerationConfig `
		{ $config.minioNoScheduleExecuteToleration } New-StorageTolerationConfig `
		{ $config.workflowControllerNoScheduleExecuteToleration } New-WorkflowTolerationConfig

    if (-not $config.skipToolOrchestration -and $config.toolNoScheduleExecuteToleration) {
        @"
to:
  tools:
    podTolerationKey: $($config.toolNoScheduleExecuteToleration.key)
    podTolerationValue: $($config.toolNoScheduleExecuteToleration.value)
"@ | Out-File (Get-ToolsTolerationValuesPath $config)
    }
}