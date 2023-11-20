function Get-SigRepoSecretName($config) {
	"$($config.releaseName)-sig-repo-secret"
}

function New-SigRepoSecret($config) {

	New-GenericSecret $config.namespace (Get-SigRepoSecretName $config) -keyValues @{
		"username"=$config.sigRepoUsername
		"password"=$config.sigRepoPwd
	} -dryRun | Out-File (Get-SigRepoSecretK8sPath $config)
}

function New-ScanFarmInternalStorageConfig($config) {

	@"
cnc:
  cnc-storage-service:
    endpoint:
      internal:
        url: $($config.scanFarmStorageInClusterUrl)
"@ | Out-File (Get-ScanFarmInternalUrlValuesPath $config)
}

function New-ScanFarmExternalProxiedStorageConfig($config) {

  $externalWebSvcProtocol = "http"
	if ($config.ingressTlsSecretName) {
		$externalWebSvcProtocol = "https"
	}
  $externalWebSvcUrl = "$externalWebSvcProtocol`://$($config.ingressHostname)"

	@"
cnc:
  cnc-storage-service:
    endpoint:
      external:
        proxyPath: '$($config.scanFarmStorageContextPath)'
        url: $externalWebSvcUrl
"@ | Out-File (Get-ScanFarmStorageExternalProxiedUrlValuesPath $config)
}

function New-ScanFarmExternalStorageConfig($config) {

	@"
cnc:
  cnc-storage-service:
    endpoint:
      external:
        url: $($config.scanFarmStorageExternalUrl)
"@ | Out-File (Get-ScanFarmStorageExternalUrlValuesPath $config)
}

function New-ScanFarmConfig($config) {

  New-SigRepoSecret $config
	New-ScanFarmDatabaseConfig $config
	New-ScanFarmCacheConfig $config
	New-ScanFarmStorageConfig $config

	$webSvcName = $config.GetWebServiceName()
	$webSvcUrl = "http://$webSvcName`:$($config.webServicePortNumber)/srm"


	@"
features:
  scanfarm: true
cnc:
  cnc-cache-service:
    javaOpts: "-Dcom.synopsys.coverity.cache.srm.secure=false"
  scanfarm:
    enabled: true
    http:
      enabled: true
    mode: "SRM"
    srm:
      url: $webSvcUrl
    tools:
      sync:
        enabled: true
        existingSecret: $(Get-SigRepoSecretName $config)

"@ | Out-File (Get-ScanFarmValuesPath $config)

	if ($config.scanFarmStorageHasInClusterUrl) {
		New-ScanFarmInternalStorageConfig $config
	}
}