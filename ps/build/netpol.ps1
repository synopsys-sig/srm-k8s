function New-NetworkPolicyConfig($config) {
	@"
networkPolicy:
  enabled: true
  k8sApiPort: $($config.kubeApiTargetPort)
"@ | Out-File (Get-NetworkPolicyValuesPath $config)
}