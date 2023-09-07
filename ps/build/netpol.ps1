function New-NetworkPolicyConfig($config) {
	@"
networkPolicy:
  enabled: true
  k8sApiPort: $($config.kubeApiTargetPort)
"@ | Out-File (Get-NetworkPolicyValuesPath $config)

  if (-not $config.skipScanFarm) {
    @"
networkPolicy:
  web:
    egress:
      extraPorts:
        tcp: [22, 53, 80, 389, 443, 636, 7990, 7999, 8443, 9000, 9998]
"@ | Out-File (Get-NetworkPolicyEgressValuesPath $config)
  }
}