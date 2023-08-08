function New-WebSecretConfig($config) {

	$webSecretName = "$($config.releaseName)-web-secret"
	New-GenericSecret $config.namespace $webSecretName -keyValues @{
		'admin-password' = $config.adminPwd
	} -dryRun | Out-File (Get-WebK8sPath $config)

	@"
web:
  webSecret: $webSecretName
"@ | Out-File (Get-WebValuesPath $config)
}