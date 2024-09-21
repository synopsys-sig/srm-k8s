
function New-SystemSize($config) {

	@"
sizing:
  size: $($config.systemSize)
"@  | Out-File (Get-SizingValuesPath $config)
}