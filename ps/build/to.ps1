function Get-ToStorageSecretName($config) {
	"$($config.releaseName)-to-storage-secret"
}
function Get-ToStorageCertConfigMapName($config) {
	"$($config.releaseName)-to-storage-configmap"
}

function Get-ToKeyPropsSecretName($config) {
	"$($config.releaseName)-to-key-props-secret"
}

function Get-ToKeySecretName($config) {
	"$($config.releaseName)-to-key-secret"
}

function New-ToKeyPropsFile($config) {

	@"
tws.api-key = """$($config.toolServiceApiKey)"""
"@ | Out-File (Get-ToKeyPropsPath $config)
}

function New-ToKeyPropsSecret($config) {

	New-ToKeyPropsFile $config
	New-GenericSecret $config.namespace (Get-ToKeyPropsSecretName $config) -fileKeyValues @{
		"to-key.props"=$(Get-ToKeyPropsPath $config)
	} -dryRun | Out-File (Get-ToKeyK8sPath $config)
}

function New-ToKeySecret($config) {

	New-GenericSecret $config.namespace (Get-ToKeySecretName $config) -keyValues @{
		"api-key"=$config.toolServiceApiKey
	} -dryRun | Out-File (Get-ToCredentialK8sPath $config)

	@"
to:
  toSecret: $(Get-ToKeySecretName $config)
web:
  toSecret: $(Get-ToKeyPropsSecretName $config)
"@ | Out-File (Get-ToCredentialValuesPath $config)
}

function New-ExternalWorkflowStorage($config) {

	$wfSecretName = Get-ToStorageSecretName $config
	New-GenericSecret $config.namespace $wfSecretName -keyValues @{
		"access-key"=$config.externalWorkflowStorageUsername
		"secret-key"=$config.externalWorkflowStoragePwd
	} -dryRun | Out-File (Get-ToExternalWorkflowStorageSecretK8sPath $config)

	$yaml = @"
to:
  workflowStorage:
    endpoint: $($config.externalWorkflowStorageEndpoint)
    endpointSecure: $(ConvertTo-Json $config.externalWorkflowStorageEndpointSecure)
    existingSecret: $wfSecretName
    bucketName: $($config.externalWorkflowStorageBucketName)
"@ | Out-File (Get-ToExternalWorkflowStoragePath $config)
	
	if (-not $config.externalWorkflowStorageTrustCert) {
		return
	}

	$wfConfigMapName = Get-ToStorageCertConfigMapName $config
	New-ConfigMap $config.namespace $wfConfigMapName -fileKeyValues @{
		"wf-storage.pem"=$config.externalWorkflowStorageCertChainPath
	} -dryRun | Out-File (Get-ToExternalWorkflowStorageCertK8sPath $config)

	$yaml += @"
to:
  workflowStorage:
    configMapName: $wfConfigMapName
    configMapPublicCertKeyName: wf-storage.pem
"@ | Out-File (Get-ToExternalCertWorkflowStoragePath $config)
}

function New-InternalWorkflowStorage($config) {

	if ($config.useGeneratedPwds) {
		return
	}

	New-ToKeyPropsSecret $config
	New-ToKeySecret $config
}

function New-ToolOrchestrationConfig($config) {

	if ($config.skipMinIO) {
		New-ExternalWorkflowStorage $config
	} else {
		New-InternalWorkflowStorage $config
	}

	$minioEnabled = $(ConvertTo-Json (-not $config.skipMinIO))
	@"
features:
  minio: $minioEnabled
minio:
  enabled: $minioEnabled
to:
  service:
    numReplicas: $($config.toolServiceReplicas)
"@ | Out-File (Get-ToConfigValuesPath $config)
}