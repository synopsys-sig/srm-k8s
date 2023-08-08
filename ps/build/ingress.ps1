function New-ServiceConfig($config) {

	@"
web:
  service:
    type: $($config.webServiceType)
    annotations: $(ConvertTo-YamlMap $config.GetWebServiceAnnotations())
    port: $($config.webServicePortNumber)
"@ | Out-File (Get-WebServiceValuesPath $config)
}

function New-IngressTlsConfig($config) {

	@"
ingress:
  tls:
    - secretName: $($config.ingressTlsSecretName)
      hosts:
        - $($config.ingressHostname)
"@ | Out-File (Get-IngressTlsValuesPath $config)
}

function New-IngressAnnotationsConfig($config) {

  @"
ingress:
  annotations:
    web: $(ConvertTo-YamlMap $config.GetIngressAnnotations())
"@ | Out-File (Get-IngressAnnotationsValuesPath $config)
}

function New-IngressConfig($config) {

	@"
ingress:
  enabled: true
  className: $($config.ingressClassName)
  hosts:
    - host: $($config.ingressHostname)
"@ | Out-File (Get-IngressValuesPath $config)

	if ($config.ingressTlsSecretName) {
		New-IngressTlsConfig $config
	}

  if ($config.ingressAnnotations.length -gt 0) {
    New-IngressAnnotationsConfig $config
  }
}