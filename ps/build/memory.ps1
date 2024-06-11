function New-WebMemoryConfig($config) {
	@"
web:
  resources:
    limits:
      memory: $($config.webMemoryReservation)
"@ | Out-File (Get-WebMemoryValuesPath $config)
}

function New-MasterDatabaseMemoryConfig($config) {

	$memory = $config.dbMasterMemoryReservation
	if (-not $memory -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$memory = "8192Mi"
			}
			([SystemSize]::Small) {
				$memory = "16384Mi"
			}
			([SystemSize]::Medium) {
				$memory = "32768Mi"
			}
			([SystemSize]::Large) {
				$memory = "65536Mi"
			}
			([SystemSize]::ExtraLarge) {
				$memory = "131072Mi"
			}
		}
	}

	@"
mariadb:
  master:
    resources:
      limits:
        memory: $memory
"@ | Out-File (Get-MasterDatabaseMemoryValuesPath $config)
}

function New-SubordinateDatabaseMemoryConfig($config) {

	$memory = $config.dbSlaveMemoryReservation
	if (-not $memory -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$memory = "4096Mi"
			}
			([SystemSize]::Small) {
				$memory = "8192Mi"
			}
			([SystemSize]::Medium) {
				$memory = "16384Mi"
			}
			([SystemSize]::Large) {
				$memory = "32768Mi"
			}
			([SystemSize]::ExtraLarge) {
				$memory = "65536Mi"
			}
		}
	}

	@"
mariadb:
  slave:
    resources:
      limits:
        memory: $memory
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

	$memory = $config.minioMemoryReservation
	if (-not $memory -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$memory = "2560Mi"
			}
			([SystemSize]::Small) {
				$memory = "5120Mi"
			}
			([SystemSize]::Medium) {
				$memory = "10240Mi"
			}
			([SystemSize]::Large) {
				$memory = "20480Mi"
			}
			([SystemSize]::ExtraLarge) {
				$memory = "40960Mi"
			}
		}
	}

	@"
minio:
  resources:
    limits:
      memory: $memory
"@ | Out-File (Get-StorageMemoryValuesPath $config)
}

function New-WorkflowMemoryConfig($config) {

	$memory = $config.workflowMemoryReservation
	if (-not $memory -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$memory = "250Mi"
			}
			([SystemSize]::Small) {
				$memory = "500Mi"
			}
			([SystemSize]::Medium) {
				$memory = "1000Mi"
			}
			([SystemSize]::Large) {
				$memory = "1500Mi"
			}
			([SystemSize]::ExtraLarge) {
				$memory = "2000Mi"
			}
		}
	}

	@"
argo-workflows:
  controller:
    resources:
      limits:
        memory: $memory
"@ | Out-File (Get-WorkflowMemoryValuesPath $config)
}

function New-MemoryConfig($config) {

	$hasSystemSize = $config.IsSystemSizeSpecified()

	# note: explicit memory reservation will override system size
	New-ComponentConfig $config `
		{ $config.webMemoryReservation } New-WebMemoryConfig `
		{ $hasSystemSize -or $config.dbMasterMemoryReservation } New-MasterDatabaseMemoryConfig `
		{ $hasSystemSize -or $config.dbSlaveMemoryReservation } New-SubordinateDatabaseMemoryConfig `
		{ $false } {} `
		{ $config.toolServiceMemoryReservation } New-ToMemoryConfig `
		{ $hasSystemSize -or $config.minioMemoryReservation } New-StorageMemoryConfig `
		{ $hasSystemSize -or $config.workflowMemoryReservation } New-WorkflowMemoryConfig
}
