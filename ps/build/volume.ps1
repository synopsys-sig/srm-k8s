function New-WebVolumeSizeConfig($config) {
	@"
web:
  persistence:
    size: $($config.webVolumeSizeGiB)Gi
"@ | Out-File (Get-WebVolumeSizeValuesPath $config)
}

function New-MasterDatabaseVolumeSizeConfig($config) {

	$storageSizeGiB = $config.dbVolumeSizeGiB
	if (-not $storageSizeGiB -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$storageSizeGiB = "96"
			}
			([SystemSize]::Small) {
				$storageSizeGiB = "192"
			}
			([SystemSize]::Medium) {
				$storageSizeGiB = "384"
			}
			([SystemSize]::Large) {
				$storageSizeGiB = "768"
			}
			([SystemSize]::ExtraLarge) {
				$storageSizeGiB = "1536"
			}
		}
	}

	@"
mariadb:
  master:
    persistence:
      size: $($storageSizeGiB)Gi
"@ | Out-File (Get-MasterDatabaseVolumeSizeValuesPath $config)
}

function New-SubordinateDatabaseVolumeSizeConfig($config) {

	$storageSizeGiB = $config.dbSlaveVolumeSizeGiB
	if (-not $storageSizeGiB -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$storageSizeGiB = "96"
			}
			([SystemSize]::Small) {
				$storageSizeGiB = "192"
			}
			([SystemSize]::Medium) {
				$storageSizeGiB = "384"
			}
			([SystemSize]::Large) {
				$storageSizeGiB = "768"
			}
			([SystemSize]::ExtraLarge) {
				$storageSizeGiB = "1536"
			}
		}
	}

	$backupStorageSizeGiB = $config.dbSlaveBackupVolumeSizeGiB
	if (-not $backupStorageSizeGiB -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$backupStorageSizeGiB = "288"
			}
			([SystemSize]::Small) {
				$backupStorageSizeGiB = "576"
			}
			([SystemSize]::Medium) {
				$backupStorageSizeGiB = "1152"
			}
			([SystemSize]::Large) {
				$backupStorageSizeGiB = "2304"
			}
			([SystemSize]::ExtraLarge) {
				$backupStorageSizeGiB = "4608"
			}
		}
	}

	@"
mariadb:
  slave:
    persistence:
      backup:
        size: $($backupStorageSizeGiB)Gi
      size: $($storageSizeGiB)Gi
"@ | Out-File (Get-SubordinateDatabaseVolumeSizeValuesPath $config)
}

function New-StorageVolumeSizeConfig($config) {

	$storageSizeGiB = $config.minioVolumeSizeGiB
	if (-not $storageSizeGiB -and $config.IsSystemSizeSpecified()) {
		switch ($config.systemSize) {
			([SystemSize]::ExtraSmall) {
				$storageSizeGiB = "32"
			}
			([SystemSize]::Small) {
				$storageSizeGiB = "64"
			}
			([SystemSize]::Medium) {
				$storageSizeGiB = "128"
			}
			([SystemSize]::Large) {
				$storageSizeGiB = "256"
			}
			([SystemSize]::ExtraLarge) {
				$storageSizeGiB = "512"
			}
		}
	}

	@"
minio:
  persistence:
    size: $($storageSizeGiB)Gi
"@ | Out-File (Get-StorageVolumeSizeValuesPath $config)
}

function New-VolumeSizeConfig($config) {

	$hasSystemSize = $config.IsSystemSizeSpecified()

	# note: explicit volume reservation will override system size
	New-ComponentConfig $config `
		{ $config.webVolumeSizeGiB } New-WebVolumeSizeConfig `
		{ $hasSystemSize -or $config.dbVolumeSizeGiB } New-MasterDatabaseVolumeSizeConfig `
		{ $hasSystemSize -or $config.dbSlaveVolumeSizeGiB } New-SubordinateDatabaseVolumeSizeConfig `
		{ $false } {} `
		{ $false } {} `
		{ $hasSystemSize -or $config.minioVolumeSizeGiB } New-StorageVolumeSizeConfig `
		{ $false } {}
}

function New-WebVolumeStorageClassConfig($config) {
	@"
web:
  persistence:
    storageClass: $($config.storageClassName)
"@ | Out-File (Get-WebVolumeStorageClassValuesPath $config)
}

function New-MasterDatabaseVolumeStorageClassConfig($config) {
	@"
mariadb:
  master:
    persistence:
      storageClass: $($config.storageClassName)
"@ | Out-File (Get-MasterDatabaseVolumeStorageClassValuesPath $config)
}

function New-SubordinateDatabaseVolumeStorageClassConfig($config) {
	@"
mariadb:
  slave:
    persistence:
      storageClass: $($config.storageClassName)
"@ | Out-File (Get-SubordinateDatabaseVolumeStorageClassValuesPath $config)
}

function New-StorageVolumeStorageClassConfig($config) {
	@"
minio:
  persistence:
    storageClass: $($config.storageClassName)
"@ | Out-File (Get-StorageVolumeStorageClassValuesPath $config)
}

function New-VolumeStorageClassConfig($config) {

	New-ComponentConfig $config `
		{ $config.storageClassName } New-WebVolumeStorageClassConfig `
		{ $config.storageClassName } New-MasterDatabaseVolumeStorageClassConfig `
		{ $config.storageClassName } New-SubordinateDatabaseVolumeStorageClassConfig `
		{ $false } {} `
		{ $false } {} `
		{ $config.storageClassName } New-StorageVolumeStorageClassConfig `
		{ $false } {}
}
