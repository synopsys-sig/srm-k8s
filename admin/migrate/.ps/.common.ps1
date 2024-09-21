function Get-FilePath([string] $prompt) {
	$q = new-object PathQuestion($prompt, $false, $false)
	$q.Prompt()
	$q.Response
}

function Get-DirectoryPath([string] $prompt) {
	$q = new-object PathQuestion($prompt, $true, $false)
	$q.Prompt()
	$q.Response
}

function Get-QuestionResponse([string] $prompt, [string[]] $blockedList, [switch] $isSecure) {
	$q = new-object Question($prompt)
	$q.blacklist = $blockedList
	$q.isSecure = $isSecure
	$q.Prompt()
	$q.Response
}

function Get-MultipleChoiceQuestionResponse([string] $prompt, [tuple`2[string,string][]] $options, [int] $defaultOption) {

	$systemSizeQuestion = new-object MultipleChoiceQuestion(
		$prompt, $options, 
		$defaultOption
	)
	$systemSizeQuestion.Prompt()
	$systemSizeQuestion.choice
}

function Get-KeyValuesFromTable([hashtable] $table) {

	$table.Keys | ForEach-Object {
		$key = $_
		$val = $table[$key]
		[KeyValue]::New($key, $val)
	}
}

function New-KeyValueFromTuple([Tuple`2[string,string]] $tuple) {

	if ($null -eq $tuple) {
		return $null
	}
	[KeyValue]::New($tuple.Item1, $tuple.Item2)
}

function Get-HelmChartAppVersionString([string] $chartYamlPath) {
	$yaml = Get-Yaml $chartYamlPath
	$yaml.GetKeyValue('appVersion')
}

function Get-CodeDxHelmChartVersionString([string] $chartYamlPath) {
	# Code Dx version number format is "2024.9.0"
	(Get-HelmChartAppVersionString $chartYamlPath) -replace '"'
}

function Get-SrmHelmChartVersionString([string] $chartYamlPath) {
	# SRM version number format is "v2024.9.0"
	(Get-HelmChartAppVersionString $chartYamlPath) -replace '"v?'
}
