function New-WebCPUConfig($config) {

	$cpuCount = Get-VirtualCpuCountFromReservation $config.webCPUReservation
  if ($cpuCount -lt 2) {
    throw "Unable to continue with the CPU reservation $($config.webCPUReservation) because the web component's CPU reservation must be >= 2 vCPUs"
  }
	
	# https://community.synopsys.com/s/article/Code-Dx-Hikari-connection-pooling-settings-and-connection-timeout
	$poolSize = $cpuCount * 3

	# https://community.synopsys.com/s/article/Code-Dx-Notes-on-Performance
	$limit = $cpuCount * 1000

	@"
web:
  props:
    limits:
      database:
        poolSize: $poolSize
      jobs:
        cpu: $limit
        memory: $limit
        database: $limit
        disk: $limit
  resources:
    limits:
      cpu: $($config.webCPUReservation)
"@ | Out-File (Get-WebCPUValuesPath $config)
}

function New-MasterDatabaseCPUConfig($config) {
	@"
mariadb:
  master:
    resources:
      limits:
        cpu: $($config.dbMasterCPUReservation)
"@ | Out-File (Get-MasterDatabaseCPUValuesPath $config)
}

function New-SubordinateDatabaseCPUConfig($config) {
	@"
mariadb:
  slave:
    resources:
      limits:
        cpu: $($config.dbSlaveCPUReservation)
"@ | Out-File (Get-SubordinateDatabaseCPUValuesPath $config)
}

function New-ToCPUConfig($config) {
	@"
to:
  resources:
    limits:
      cpu: $($config.toolServiceCPUReservation)
"@ | Out-File (Get-ToCPUValuesPath $config)
}

function New-StorageCPUConfig($config) {
	@"
minio:
  resources:
    limits:
      cpu: $($config.minioCPUReservation)
"@ | Out-File (Get-StorageCPUValuesPath $config)
}

function New-WorkflowCPUConfig($config) {
	@"
argo:
  controller:
    resources:
      limits:
        cpu: $($config.workflowCPUReservation)
"@ | Out-File (Get-WorkflowCPUValuesPath $config)
}

function New-CPUConfig($config) {

	New-ComponentConfig $config `
		{ $config.webCPUReservation } New-WebCPUConfig `
		{ $config.dbMasterCPUReservation } New-MasterDatabaseCPUConfig `
		{ $config.dbSlaveCPUReservation } New-SubordinateDatabaseCPUConfig `
		{ $false } {} `
		{ $config.toolServiceCPUReservation } New-ToCPUConfig `
		{ $config.minioCPUReservation } New-StorageCPUConfig `
		{ $config.workflowCPUReservation } New-WorkflowCPUConfig
}

