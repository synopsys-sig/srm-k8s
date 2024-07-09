function Get-SemVerPattern() {
	# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
	'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?'
}

function Get-ReferenceCount([string] $file, [string] $unescapedPattern) {
	$pattern = [Regex]::Escape($unescapedPattern)
	Get-Content $file | Select-String -List -AllMatches -Pattern $pattern -CaseSensitive | ForEach-Object { $_.matches.length } | Measure-Object -Sum | Select-Object -ExpandProperty 'Sum'
}