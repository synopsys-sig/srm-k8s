
function New-DockerImagePullSecretConfig($config) {

    $registrySecretName = $config.dockerImagePullSecretName
    New-ImagePullSecret $config.namespace $registrySecretName `
        $config.dockerRegistry `
        $config.dockerRegistryUser `
        $config.dockerRegistryPwd `
        -dryRun | Out-File (Get-RegistryK8sPath $config)
    
    @"
imagePullSecrets:
  - name: $registrySecretName
  
argo-workflows:
  images:
    pullSecrets:
    - name: $registrySecretName

mariadb:
  image:
    pullSecrets:
    - $registrySecretName

minio:
  image:
    pullSecrets:
    - $registrySecretName

scan-services:
  imagePullSecret: $registrySecretName
"@ | Out-File (Get-RegistryValuesPath $config)
}