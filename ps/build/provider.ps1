function New-OpenShiftConfig($config) {
	@'
openshift:
  createSCC: true
'@ | Out-File (Get-OpenShiftValuesPath $config)
}
