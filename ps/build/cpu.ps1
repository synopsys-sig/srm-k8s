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

	$cpu = $config.dbMasterCPUReservation
	if (-not $cpu -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$cpu = "2000m"
			}
			([SystemSize]::Small) {
				$cpu = "4000m"
			}
			([SystemSize]::Medium) {
				$cpu = "8000m"
			}
			([SystemSize]::Large) {
				$cpu = "16000m"
			}
			([SystemSize]::ExtraLarge) {
				$cpu = "32000m"
			}
		}
	}

	@"
mariadb:
  master:
    resources:
      limits:
        cpu: $cpu
"@ | Out-File (Get-MasterDatabaseCPUValuesPath $config)
}

function New-SubordinateDatabaseCPUConfig($config) {

	$cpu = $config.dbSlaveCPUReservation
	if (-not $cpu -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$cpu = "1000m"
			}
			([SystemSize]::Small) {
				$cpu = "2000m"
			}
			([SystemSize]::Medium) {
				$cpu = "4000m"
			}
			([SystemSize]::Large) {
				$cpu = "8000m"
			}
			([SystemSize]::ExtraLarge) {
				$cpu = "16000m"
			}
		}
	}

	@"
mariadb:
  slave:
    resources:
      limits:
        cpu: $cpu
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

	$cpu = $config.minioCPUReservation
	if (-not $cpu -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$cpu = "1000m"
			}
			([SystemSize]::Small) {
				$cpu = "2000m"
			}
			([SystemSize]::Medium) {
				$cpu = "4000m"
			}
			([SystemSize]::Large) {
				$cpu = "8000m"
			}
			([SystemSize]::ExtraLarge) {
				$cpu = "16000m"
			}
		}
	}

	@"
minio:
  resources:
    limits:
      cpu: $cpu
"@ | Out-File (Get-StorageCPUValuesPath $config)
}

function New-WorkflowCPUConfig($config) {

	$cpu = $config.workflowCPUReservation
	if (-not $cpu -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$cpu = "250m"
			}
			([SystemSize]::Small) {
				$cpu = "500m"
			}
			([SystemSize]::Medium) {
				$cpu = "1000m"
			}
			([SystemSize]::Large) {
				$cpu = "2000m"
			}
			([SystemSize]::ExtraLarge) {
				$cpu = "4000m"
			}
		}
	}

	@"
argo:
  controller:
    resources:
      limits:
        cpu: $cpu
"@ | Out-File (Get-WorkflowCPUValuesPath $config)
}

function New-CPUConfig($config) {

	$hasSystemSize = $config.IsSystemSizeSpecified()

	# note: explicit CPU reservation will override system size
	New-ComponentConfig $config `
		{ $config.webCPUReservation } New-WebCPUConfig `
		{ $hasSystemSize -or $config.dbMasterCPUReservation } New-MasterDatabaseCPUConfig `
		{ $hasSystemSize -or $config.dbSlaveCPUReservation } New-SubordinateDatabaseCPUConfig `
		{ $false } {} `
		{ $config.toolServiceCPUReservation } New-ToCPUConfig `
		{ $hasSystemSize -or $config.minioCPUReservation } New-StorageCPUConfig `
		{ $hasSystemSize -or $config.workflowCPUReservation } New-WorkflowCPUConfig
}

