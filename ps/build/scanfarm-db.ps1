function Get-ScanFarmDatabaseSecretName($config) {
	"$($config.releaseName)-sf-db-secret"
}

function Get-ScanFarmDatabaseCertConfigMapName($config) {
	"$($config.releaseName)-sf-db-cert-configmap"
}

function New-ScanFarmDatabaseSecret($config) {

	New-GenericSecret $config.namespace (Get-ScanFarmDatabaseSecretName $config) -keyValues @{
		"host"=$config.scanFarmDatabaseHost
		"port"=$config.scanFarmDatabasePort
		"username"=$config.scanFarmDatabaseUser
		"password"=$config.scanFarmDatabasePwd
	} -dryRun | Out-File (Get-ScanFarmDatabaseSecretK8sPath $config)
}

function New-ScanFarmDatabaseCertConfigMap($config) {

	New-ConfigMap $config.namespace (Get-ScanFarmDatabaseCertConfigMapName $config) -fileKeyValues @{
		"postgres-root.pem"=$config.scanFarmDatabaseServerCert
	} -dryRun | Out-File (Get-ScanFarmDatabaseCertK8sPath $config)`
}

function New-ScanFarmDatabaseTlsConfig($config) {

	New-ScanFarmDatabaseCertConfigMap $config
	@"
cnc:
  trust-stores:
    configmapName: $(Get-ScanFarmDatabaseCertConfigMapName $config)
    enabled: true
"@ | Out-File (Get-ScanFarmDatabaseTlsValuesPath $config)
}

function New-ScanFarmDatabaseConfig($config) {

	New-ScanFarmDatabaseSecret $config
	@"
cnc:
  cnc-scan-service:
    postgres:
      database: $($config.scanFarmScanDatabaseCatalog)
  cnc-storage-service:
    postgres:
      database: $($config.scanFarmStorageDatabaseCatalog)
  postgres:
    existingSecret: $(Get-ScanFarmDatabaseSecretName $config)
    sslmode: $($config.scanFarmDatabaseSslMode)
"@ | Out-File (Get-ScanFarmDatabaseValuesPath $config)

	if ($config.scanFarmDatabaseSslMode -eq 'verify-ca' -or $config.scanFarmDatabaseSslMode -eq 'verify-full') {
		New-ScanFarmDatabaseTlsConfig $config
	}
}
