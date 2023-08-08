function New-WebEphemeralStorageConfig($config) {
	@"
web:
  resources:
    limits:
      ephemeral-storage: $($config.webEphemeralStorageReservation)
"@ | Out-File (Get-WebEphemeralStorageValuesPath $config)
}

function New-MasterDatabaseEphemeralStorageConfig($config) {
	@"
mariadb:
  master:
    resources:
      limits:
        ephemeral-storage: $($config.dbMasterEphemeralStorageReservation)
"@ | Out-File (Get-MasterDatabaseEphemeralStorageValuesPath $config)
}

function New-SubordinateDatabaseEphemeralStorageConfig($config) {
	@"
mariadb:
  slave:
    resources:
      limits:
        ephemeral-storage: $($config.dbSlaveEphemeralStorageReservation)
"@ | Out-File (Get-SubordinateDatabaseEphemeralStorageValuesPath $config)
}

function New-ToEphemeralStorageConfig($config) {
	@"
to:
  resources:
    limits:
      ephemeral-storage: $($config.toolServiceEphemeralStorageReservation)
"@ | Out-File (Get-ToEphemeralStorageValuesPath $config)
}

function New-StorageEphemeralStorageConfig($config) {
	@"
minio:
  resources:
    limits:
      ephemeral-storage: $($config.minioEphemeralStorageReservation)
"@ | Out-File (Get-StorageEphemeralStorageValuesPath $config)
}

function New-WorkflowEphemeralStorageConfig($config) {
	@"
argo:
  controller:
    resources:
      limits:
        ephemeral-storage: $($config.workflowEphemeralStorageReservation)
"@ | Out-File (Get-WorkflowEphemeralStorageValuesPath $config)
}

function New-EphemeralStorageConfig($config) {

	New-ComponentConfig $config `
		{ $config.webEphemeralStorageReservation } New-WebEphemeralStorageConfig `
		{ $config.dbMasterEphemeralStorageReservation } New-MasterDatabaseEphemeralStorageConfig `
		{ $config.dbSlaveEphemeralStorageReservation } New-SubordinateDatabaseEphemeralStorageConfig `
		{ $false } {} `
		{ $config.toolServiceEphemeralStorageReservation } New-ToEphemeralStorageConfig `
		{ $config.minioEphemeralStorageReservation } New-StorageEphemeralStorageConfig `
		{ $config.workflowEphemeralStorageReservation } New-WorkflowEphemeralStorageConfig
}
