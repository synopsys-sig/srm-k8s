function New-WebVolumeSizeConfig($config) {
	@"
web:
  persistence:
    size: $($config.webVolumeSizeGiB)Gi
"@ | Out-File (Get-WebVolumeSizeValuesPath $config)
}

function New-MasterDatabaseVolumeSizeConfig($config) {
	@"
mariadb:
  master:
    persistence:
      size: $($config.dbVolumeSizeGiB)Gi
"@ | Out-File (Get-MasterDatabaseVolumeSizeValuesPath $config)
}

function New-SubordinateDatabaseVolumeSizeConfig($config) {
	@"
mariadb:
  slave:
    persistence:
      backup:
        size: $($config.dbSlaveBackupVolumeSizeGiB)Gi
      size: $($config.dbSlaveVolumeSizeGiB)Gi
"@ | Out-File (Get-SubordinateDatabaseVolumeSizeValuesPath $config)
}

function New-StorageVolumeSizeConfig($config) {
	@"
minio:
  persistence:
    size: $($config.minioVolumeSizeGiB)Gi
"@ | Out-File (Get-StorageVolumeSizeValuesPath $config)
}

function New-VolumeSizeConfig($config) {

	New-ComponentConfig $config `
		{ $config.webVolumeSizeGiB } New-WebVolumeSizeConfig `
		{ $config.dbVolumeSizeGiB } New-MasterDatabaseVolumeSizeConfig `
		{ $config.dbSlaveVolumeSizeGiB } New-SubordinateDatabaseVolumeSizeConfig `
		{ $false } {} `
		{ $false } {} `
		{ $config.minioVolumeSizeGiB } New-StorageVolumeSizeConfig `
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
