function New-DockerImageLocationConfig($config) {

	$repositoryPrefix = ''
	$registryAndRepositoryPrefix = $config.dockerRegistry

	if ($config.useDockerRepositoryPrefix) {

		$dockerRepositoryPrefixNoSlash = $config.dockerRepositoryPrefix.TrimEnd('/')
		$repositoryPrefix = "$dockerRepositoryPrefixNoSlash/"
		$registryAndRepositoryPrefix += "/$dockerRepositoryPrefixNoSlash"
	}

	if (-not $config.skipScanFarm) {
		@"
cnc:
  imageRegistry: '$registryAndRepositoryPrefix'
"@ | Out-File (Get-ScanFarmDockerImageLocationValuesPath $config)
	}

	@"
web:
  image:
    registry: '$($config.dockerRegistry)'
    repository: '$("$($repositoryPrefix)codedx/codedx-tomcat")'
"@ | Out-File (Get-WebDockerImageLocationValuesPath $config)

	if (-not $config.skipDatabase) {
		@"
mariadb:
  image:
    registry: '$($config.dockerRegistry)'
    repository: '$("$($repositoryPrefix)codedx/codedx-mariadb")'
"@ | Out-File (Get-DatabaseDockerImageLocationValuesPath $config)
	}

	if (-not $config.skipToolOrchestration) {
		@"
to:
  image:
    registry: '$($config.dockerRegistry)'
    repository:
      tools: '$("$($repositoryPrefix)codedx/codedx-tools")'
      toolsMono: '$("$($repositoryPrefix)codedx/codedx-toolsmono")'
      helmPreDelete: '$("$($repositoryPrefix)codedx/codedx-cleanup")'
      prepare: '$("$($repositoryPrefix)codedx/codedx-prepare")'
      newAnalysis: '$("$($repositoryPrefix)codedx/codedx-newanalysis")'
      sendResults: '$("$($repositoryPrefix)codedx/codedx-results")'
      toolService: '$("$($repositoryPrefix)codedx/codedx-tool-service")'
argo-workflows:
  controller:
    image:
      registry: '$($config.dockerRegistry)'
      repository: '$("$($repositoryPrefix)argoproj/workflow-controller")'
  executor:
    image:
      registry: '$($config.dockerRegistry)'
      repository: '$("$($repositoryPrefix)argoproj/argoexec")'
"@ | Out-File (Get-ToDockerImageLocationValuesPath $config)

		if (-not $config.skipMinIO) {
			@"
minio:
  image:
    registry: '$($config.dockerRegistry)'
    repository: '$("$($repositoryPrefix)bitnami/minio")'
"@ | Out-File (Get-StorageDockerImageLocationValuesPath $config)
		}
	}
}

function New-DockerImageVersionConfig($config) {

	if (-not ([string]::IsNullOrEmpty($config.imageVersionWeb))) {
		@"
web:
  image:
    tag: '$($config.imageVersionWeb)'
"@ | Out-File (Get-WebDockerImageVersionValuesPath $config)
	}

	if (-not $config.skipDatabase -and -not ([string]::IsNullOrEmpty($config.imageVersionMariaDB))) {
		@"
mariadb:
  image:
    tag: '$($config.imageVersionMariaDB)'
"@ | Out-File (Get-DatabaseDockerImageVersionValuesPath $config)
	}

	if (-not $config.skipToolOrchestration) {

		if (-not ([string]::IsNullOrEmpty($config.imageVersionTo))) {
			@"
to:
  image:
    tag: '$($config.imageVersionTo)'
"@ | Out-File (Get-ToDockerImageVersionValuesPath $config)
		}

		if (-not $config.skipMinIO -and -not ([string]::IsNullOrEmpty($config.imageVersionMinio))) {
			@"
minio:
  image:
    tag: '$($config.imageVersionMinio)'
"@ | Out-File (Get-StorageDockerImageVersionValuesPath $config)
		}

		if (-not ([string]::IsNullOrEmpty($config.imageVersionWorkflow))) {
			@"
argo-workflows:
  images:
    tag: '$($config.imageVersionWorkflow)'
"@ | Out-File (Get-WorkflowDockerImageVersionValuesPath $config)
		}
	}
}
