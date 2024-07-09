function Get-WebPropsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-props.values.yaml'
}

function New-WebPropsConfig($config) {
	@"
web:
  props:
    auth:
      cookie:
        secure: $($config.authCookieSecure.ToString().ToLower())
"@ | Out-File (Get-WebPropsValuesPath $config)
}