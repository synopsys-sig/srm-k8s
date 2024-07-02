function Get-PsScriptFileInfoVersion([string] $scriptPath) {

	$verMatch = Get-Content $scriptPath | select-string '^.VERSION\s+(?<version>.+)$'
	if ($null -eq $verMatch) {
		throw "Unable to find version in $scriptPath"
	}
	new-object Management.Automation.SemanticVersion($verMatch.matches.groups[1].value)
}

function Set-NextScriptMinorVersion([string] $scriptPath) {

	$currentVersion = Get-PsScriptFileInfoVersion $scriptPath
	$currentVersionPattern = $([Text.RegularExpressions.Regex]::Escape($currentVersion))
	$newVersion = "$($currentVersion.Major).$($currentVersion.Minor+1).$($currentVersion.Patch)"

	# Update version directly because the Update-PSScriptFileInfo will add script fields with blank entries
	(get-content $scriptPath) -replace "^\.VERSION $currentVersionPattern$",".VERSION $newVersion" | Set-Content $scriptPath
}