Push-Location $PSScriptRoot

helm repo index . --url https://codedx.github.io/srm-k8s

$index = Get-Content index.yaml
$index | ForEach-Object {
    $_ -replace 'https://github.com/synopsys-sig/srm-k8s','https://github.com/codedx/srm-k8s'
} | ForEach-Object {
    $_ -replace 'https://synopsys-sig.github.io/srm-k8s','https://codedx.github.io/srm-k8s'
} | ForEach-Object {
    $_ -replace 'https://sig-repo.synopsys.com/artifactory/sig-cloudnative','https://repo.blackduck.com/artifactory/sig-cloudnative'
} | Out-File index.yaml
