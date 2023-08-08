function New-WebMemoryConfig($config) {
	@"
web:
  resources:
    limits:
      memory: $($config.webMemoryReservation)
"@ | Out-File (Get-WebMemoryValuesPath $config)
}

function New-MasterDatabaseMemoryConfig($config) {
	@"
mariadb:
  master:
    resources:
      limits:
        memory: $($config.dbMasterMemoryReservation)
"@ | Out-File (Get-MasterDatabaseMemoryValuesPath $config)
}

function New-SubordinateDatabaseMemoryConfig($config) {
	@"
mariadb:
  slave:
    resources:
      limits:
        memory: $($config.dbSlaveMemoryReservation)
"@ | Out-File (Get-SubordinateDatabaseMemoryValuesPath $config)
}

function New-ToMemoryConfig($config) {
	@"
to:
  resources:
    limits:
      memory: $($config.toolServiceMemoryReservation)
"@ | Out-File (Get-ToMemoryValuesPath $config)
}

function New-StorageMemoryConfig($config) {
	@"
minio:
  resources:
    limits:
      memory: $($config.minioMemoryReservation)
"@ | Out-File (Get-StorageMemoryValuesPath $config)
}

function New-WorkflowMemoryConfig($config) {
	@"
argo:
  controller:
    resources:
      limits:
        memory: $($config.workflowMemoryReservation)
"@ | Out-File (Get-WorkflowMemoryValuesPath $config)
}

function New-MemoryConfig($config) {

	New-ComponentConfig $config `
		{ $config.webMemoryReservation } New-WebMemoryConfig `
		{ $config.dbMasterMemoryReservation } New-MasterDatabaseMemoryConfig `
		{ $config.dbSlaveMemoryReservation } New-SubordinateDatabaseMemoryConfig `
		{ $false } {} `
		{ $config.toolServiceMemoryReservation } New-ToMemoryConfig `
		{ $config.minioMemoryReservation } New-StorageMemoryConfig `
		{ $config.workflowMemoryReservation } New-WorkflowMemoryConfig
}
