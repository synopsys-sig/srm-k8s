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

function New-ToStorageSecret($config, $storageUsername, $storagePwd) {

	New-GenericSecret $config.namespace (Get-ToStorageSecretName $config) -keyValues @{
		"access-key"=$storageUsername
		"secret-key"=$storagePwd
	} -dryRun | Out-File (Get-ToWorkflowStorageSecretK8sPath $config)
}

function New-ExternalWorkflowStorage($config) {

	New-ToStorageSecret $config $config.externalWorkflowStorageUsername $config.externalWorkflowStoragePwd

	$yaml = @"
to:
  workflowStorage:
    endpoint: $($config.externalWorkflowStorageEndpoint)
    endpointSecure: $(ConvertTo-Json $config.externalWorkflowStorageEndpointSecure)
    existingSecret: $(Get-ToStorageSecretName $config)
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

	New-ToStorageSecret $config 'admin' $config.minioAdminPwd
	@"
minio:
  global:
    minio:
      existingSecret: $(Get-ToStorageSecretName $config)
"@ | Out-File (Get-ToWorkflowStoragePath $config)
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
"@ | Out-File (Get-ToConfigMinIOValuesPath $config)

	if ($config.toolServiceReplicas -gt 0) {
		@"
to:
  service:
    numReplicas: $($config.toolServiceReplicas)
"@ | Out-File (Get-ToConfigValuesPath $config)
	}
}