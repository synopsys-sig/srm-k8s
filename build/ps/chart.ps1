function Get-HelmChartVersionString([string] $chartYamlPath) {

	$versionPattern = '(?m)^version:\s(?<version>.+)$'

	$versionMatch = Get-Content $chartYamlPath | select-string -pattern $versionPattern
	if ($null -eq $versionMatch) {
		throw "Expected to find a version match in path $chartYamlPath with $versionPattern"
	}

	(new-object Management.Automation.SemanticVersion($versionMatch.Matches.Groups[1].Value)).toString()
}

function Set-NextHelmChartMinorVersion([string] $chartYamlPath, [string] $appVersion) {

	$chartLines = Get-Content $chartYamlPath

	$versionPattern = '(?m)^version:\s(?<version>.+)$'

	$versionMatch = $chartLines | select-string -pattern $versionPattern
	if ($null -eq $versionMatch) {
		throw "Expected to find a version match in path $chartYamlPath with $versionPattern"
	}

	$currentVersion = new-object Management.Automation.SemanticVersion($versionMatch.Matches.Groups[1].Value)
	$newVersion = "$($currentVersion.Major).$($currentVersion.Minor+1).$($currentVersion.Patch)"

	$chartLines = $chartLines -replace $versionPattern,"version: $newVersion"

	if ($appVersion -notmatch 'v\d+\.\d+\.\d+') {
		throw "Expected to find an appVersion number matching format v1.2.3 (not $appVersion)"
	}

	$appVersionPattern = '(?m)^appVersion:\s.+$'
	$chartLines = $chartLines -replace $appVersionPattern,"appVersion: ""$($appVersion.substring(1))"""

	Set-Content $chartYamlPath $chartLines
}