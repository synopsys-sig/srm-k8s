function Get-ScanFarmCacheAuthSecretName($config) {
	"$($config.releaseName)-sf-cache-auth-secret"
}

function Get-ScanFarmCacheCertSecretName($config) {
	"$($config.releaseName)-sf-cache-cert-secret"
}

function New-ScanFarmCacheAuthSecret($config) {

	New-GenericSecret $config.namespace (Get-ScanFarmCacheAuthSecretName $config) -keyValues @{
		"password"=$config.scanFarmRedisPwd
	} -dryRun | Out-File (Get-ScanFarmCacheAuthSecretK8sPath $config)
}

function New-ScanFarmCacheAuthConfig($config) {

	New-ScanFarmCacheAuthSecret $config
	@"
cnc:
  cnc-cache-service:
    redis:
      authEnabled: true
      passwordSecret: $(Get-ScanFarmCacheAuthSecretName $config)
"@ | Out-File (Get-ScanFarmCacheAuthValuesPath $config)
}

function New-ScanFarmCacheCertSecret($config) {

	New-GenericSecret $config.namespace (Get-ScanFarmCacheCertSecretName $config) -fileKeyValues @{
		"ca.crt"=$config.scanFarmRedisServerCert
	} -dryRun | Out-File (Get-ScanFarmCacheTlsK8sPath $config)`
}

function New-ScanFarmCacheTlsConfig($config) {

	New-ScanFarmCacheCertSecret $config
	@"
cnc:
  cnc-cache-service:
    redis:
      cacertSecret: $(Get-ScanFarmCacheCertSecretName $config)
      verifyHostName: $(ConvertTo-Json ($config.scanFarmRedisVerifyHostname))
"@ | Out-File (Get-ScanFarmCacheTlsValuesPath $config)
}

function New-ScanFarmCacheConfig($config) {

	@"
cnc:
  cnc-cache-service:
    redis:
      host: $($config.scanFarmRedisHost)
      port: $($config.scanFarmRedisPort)
      database: "$($config.scanFarmRedisDatabase)"
      secure: $(ConvertTo-Json $config.scanFarmRedisSecure)
"@ | Out-File (Get-ScanFarmCacheValuesPath $config)

	if ($config.scanFarmRedisUseAuth) {
		New-ScanFarmCacheAuthConfig $config
	}

	if ($config.scanFarmRedisSecure) {
		New-ScanFarmCacheTlsConfig $config
	}
}