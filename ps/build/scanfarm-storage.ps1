function Get-ScanFarmMinIOSecretName($config) {
	"$($config.releaseName)-sf-minio-secret"
}

function Get-ScanFarmAwsS3CredentialName($config) {
	"$($config.releaseName)-sf-aws-s3-secret"
}

function Get-ScanFarmGcsCredentialName($config) {
	"$($config.releaseName)-sf-gcs-secret"
}

function Get-ScanFarmAzureCredentialName($config) {
	"$($config.releaseName)-sf-azure-secret"
}

function Get-ScanFarmMinIOCertConfigMapName($config) {
	"$($config.releaseName)-sf-minio-cert-configmap"
}

function New-ScanFarmMinIOCertConfigMap($config) {

	New-ConfigMap $config.namespace (Get-ScanFarmMinIOCertConfigMapName $config) -fileKeyValues @{
		"ca.crt"=$config.scanFarmMinIOServerCert
	} -dryRun | Out-File (Get-ScanFarmMinIOTlsK8sPath $config)`
}

function New-ScanFarmMinIOTlsConfig($config) {

	New-ScanFarmMinIOCertConfigMap $config
	@"
scan-services:
  cache-service:
    minio:
      cacert: $(Get-ScanFarmMinIOCertConfigMapName $config)
"@ | Out-File (Get-ScanFarmMinIOTlsValuesPath $config)
}

function New-ScanFarmMinIORootSecretName($config) {

	New-GenericSecret $config.namespace (Get-ScanFarmMinIOSecretName $config) -keyValues @{
		"root-user"=$($config.scanFarmMinIORootUsername)
		"root-password"=$($config.scanFarmMinIORootPwd)
	} -dryRun | Out-File (Get-ScanFarmMinIORootK8sPath $config)
}

function New-ScanFarmAwsS3SecretName($config) {

	New-GenericSecret $config.namespace (Get-ScanFarmAwsS3CredentialName $config) -keyValues @{
		"aws_access_key"=$($config.scanFarmS3AccessKey)
		"aws_secret_key"=$($config.scanFarmS3SecretKey)
	} -dryRun | Out-File (Get-ScanFarmAwsS3K8sPath $config)
}

function New-ScanFarmGcsSecretName($config) {

	New-GenericSecret $config.namespace (Get-ScanFarmGcsCredentialName $config) -fileKeyValues @{
		"key.json"=$($config.scanFarmGcsSvcAccountKey)
	} -dryRun | Out-File (Get-ScanFarmGcsK8sPath $config)
}

function New-ScanFarmAzureSecretName($config) {

	New-GenericSecret $config.namespace (Get-ScanFarmAzureCredentialName $config) -keyValues @{
    "azure_account_key"=$($config.scanFarmAzureStorageAccountKey)
		"azure_client_id"=$($config.scanFarmAzureClientId)
		"azure_client_secret"=$($config.scanFarmAzureClientSecret)
		"azure_endpoint"=$($config.scanFarmAzureEndpoint)
		"azure_resource_group"=$($config.scanFarmAzureResourceGroup)
		"azure_subscription_id"=$($config.scanFarmAzureSubscriptionId)
		"azure_tenant_id"=$($config.scanFarmAzureTenantId)
	} -dryRun | Out-File (Get-ScanFarmAzureK8sPath $config)
}

function New-ScanFarmMinIOConfig($config) {

	$credentialSecretName = Get-ScanFarmMinIOSecretName $config
	New-ScanFarmMinIORootSecretName $config
	@"
scan-services:
  cache-service:
    aws:
      secret: $credentialSecretName
    bucketName: $($config.scanFarmCacheBucketName)
    minio:
      host: $($config.scanFarmMinIOHostname)
      port: $($config.scanFarmMinIOPort)
      secret: $credentialSecretName
      secure: $(ConvertTo-Json ($config.scanFarmMinIOSecure))
      verifyHostName: $(ConvertTo-Json ($config.scanFarmMinIOVerifyHostname))
    storageProvider: minio
  storage-service:
    storageType: minio
    minio:
      bucket: $($config.scanFarmStorageBucketName)
      region: us-east-1
      secret:
        name: $credentialSecretName
"@ | Out-File (Get-ScanFarmMinIOValuesPath $config)

	if ($config.scanFarmStorageIsProxied) {
		New-ScanFarmExternalProxiedStorageConfig $config
	} else {
		New-ScanFarmExternalStorageConfig $config
	}
	if ($config.scanFarmMinIOSecure) {
		New-ScanFarmMinIOTlsConfig $config
	}
}

function New-ScanFarmAwsS3KeyConfig($config) {

	$credentialSecretName = Get-ScanFarmAwsS3CredentialName $config
	New-ScanFarmAwsS3SecretName $config
	@"
scan-services:
  cache-service:
    aws:
      region: $($config.scanFarmS3Region)
      secret: $credentialSecretName
    bucketName: $($config.scanFarmCacheBucketName)
    storageProvider: aws
  storage-service:
    storageType: s3
    s3:
      bucket: $($config.scanFarmStorageBucketName)
      region: $($config.scanFarmS3Region)
      secret:
        name: $credentialSecretName
"@ | Out-File (Get-ScanFarmAwsS3ValuesPath $config)
}

function New-ScanFarmAwsS3IrsaConfig($config) {

	$serviceAccountName = $config.scanFarmS3ServiceAccountName
	@"
scan-services:
  cache-service:
    aws:
      region: $($config.scanFarmS3Region)
      serviceAccount: $serviceAccountName
    bucketName: $($config.scanFarmCacheBucketName)
    storageProvider: aws
  storage-service:
    storageType: s3
    s3:
      bucket: $($config.scanFarmStorageBucketName)
      region: $($config.scanFarmS3Region)
      serviceAccount: $serviceAccountName
"@ | Out-File (Get-ScanFarmAwsS3ValuesPath $config)
}

function New-ScanFarmGcsConfig($config) {

	$credentialSecretName = Get-ScanFarmGcsCredentialName $config
	New-ScanFarmGcsSecretName $config
	@"
scan-services:
  cache-service:
    gcp:
      project: $($config.scanFarmGcsProjectName)
      secret: $credentialSecretName
    bucketName: $($config.scanFarmCacheBucketName)
    storageProvider: gcp
  storage-service:
    storageType: gcs
    gcs:
      bucket: $($config.scanFarmStorageBucketName)
      secret:
        key: key.json
        name: $credentialSecretName
"@ | Out-File (Get-ScanFarmGcsValuesPath $config)
}

function New-ScanFarmAzureConfig($config) {

	$credentialSecretName = Get-ScanFarmAzureCredentialName $config
	New-ScanFarmAzureSecretName $config
	@"
scan-services:
  cache-service:
    azure:
      secret: $credentialSecretName
    bucketName: $($config.scanFarmCacheBucketName)
    storageProvider: azure
  storage-service:
    storageType: azure
    azure:
      container: $($config.scanFarmStorageBucketName)
      secret:
        name: $credentialSecretName
      storageAccountName: $($config.scanFarmAzureStorageAccount)
"@ | Out-File (Get-ScanFarmAzureValuesPath $config)
}

function New-ScanFarmStorageConfig($config) {

	switch ($config.scanFarmStorageType) {
		([ScanFarmStorageType]::MinIO) {
			New-ScanFarmMinIOConfig $config
		}
		([ScanFarmStorageType]::AwsS3) {
			if ($config.scanFarmS3UseServiceAccountName) {
				New-ScanFarmAwsS3IrsaConfig $config
			} else {
				New-ScanFarmAwsS3KeyConfig $config
			}
		}
		([ScanFarmStorageType]::Gcs) {
			New-ScanFarmGcsConfig $config
		}
		([ScanFarmStorageType]::Azure) {
			New-ScanFarmAzureConfig $config
		}
	}
}
