function Get-HelmChartVersionString([string] $chartYamlPath) {
	(Get-YamlField $chartYamlPath '.version')[2]
}

function Set-HelmChartVersion([string] $chartYamlPath, [string] $version, [string] $appVersion) {

	if ($appVersion -notmatch 'v\d+\.\d+\.\d+') {
		throw "Expected to find an appVersion number matching format v1.2.3 (not $appVersion)"
	}

	Set-YamlContentLine $chartYamlPath '.version' $version
	Set-YamlContentLine $chartYamlPath '.appVersion' $appVersion
}