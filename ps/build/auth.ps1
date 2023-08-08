function Get-SamlSecretName($config) {
	"$($config.releaseName)-web-saml-secret"
}

function Get-SamlIdpConfigMapName($config) {
	"$($config.releaseName)-web-saml-configmap"
}

function New-SamlConfig($config) {

	$samlPropsPath = Get-SamlPropsPath $config
	@"
auth.saml2.keystorePassword = """$($config.samlKeystorePwd)"""
auth.saml2.privateKeyPassword = """$($config.samlPrivateKeyPwd)"""
"@ | Out-File $samlPropsPath

	$samlSecretName = Get-SamlSecretName $config
	New-GenericSecret $config.namespace $samlSecretName -fileKeyValues @{
		"saml-keystore.props" = $samlPropsPath
	} -dryRun | Out-File (Get-SamlSecretK8sPath $config)

	$samlIdPConfigMapName = Get-SamlIdpConfigMapName $config
	New-ConfigMap $config.namespace $samlIdPConfigMapName -fileKeyValues @{
		"saml-idp.xml"=$config.samlIdentityProviderMetadataPath
	} -dryRun | Out-File (Get-SamlIdPK8sPath $config)

	@"
web:
  authentication:
    saml:
      enabled: true
      hostBasePath: $($config.samlHostBasePath)
      appName: $($config.samlAppName)
      samlIdpXmlFileConfigMap: $samlIdPConfigMapName
      samlSecret: $samlSecretName
"@ | Out-File (Get-SamlValuesPath $config)
}
