class ScanFarmStorage : Step {

	static [string] hidden $description = @'
Specify the type of external storage you plan to use with the Scan Farm.

You can use the following storage providers:

- Amazon S3 (https://aws.amazon.com/s3/)
- Azure Storage (https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)
- Google Cloud Storage (https://cloud.google.com/storage/docs/creating-buckets)
- S3-compatible storage (e.g., OpenShift)
- MinIO (https://min.io/)
'@

	ScanFarmStorage([Config] $config) : base(
		[ScanFarmStorage].Name, 
		$config,
		'Scan Farm Storage',
		[ScanFarmStorage]::description,
		'Specify the type of Scan Farm storage you plan to use') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&AWS S3', 'Use storage provided by AWS S3'),
			[tuple]::create('&S3', 'Use storage provided by an S3-compatible provider'),
			[tuple]::create('&MinIO', 'Use storage provided by MinIO'),
			[tuple]::create('&GCS', 'Use storage provided by GCP GCS'),
			[tuple]::create('A&zure', 'Use storage provided by Azure')), -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::AwsS3 }
			1 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::AwsS3 }
			2 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::MinIO }
			3 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::Gcs }
			4 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::Azure }
		}
		return $true
	}	

	[void]Reset(){
		$this.config.scanFarmStorageType = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmStorageBucketName : Step {

	static [string] hidden $description = @'
The Scan Farm includes a storage service that depends on an existing
bucket in your storage system.
'@

	static [string] hidden $azureDescription = @'
The Scan Farm includes a storage service that depends on an existing
blob container in your Azure storage account.
'@

	static [string] hidden $azurePrompt = 'Enter the name of your *existing* storage service blob container'
	
	ScanFarmStorageBucketName([Config] $config) : base(
		[ScanFarmStorageBucketName].Name, 
		$config,
		'Storage Service Bucket Name',
		[ScanFarmStorageBucketName]::description,
		'Enter the name of your *existing* storage service bucket') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$prompt = $this.prompt
		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			$prompt = [ScanFarmStorageBucketName]::azurePrompt
		}
		return new-object Question($prompt)
	}

	[string]GetMessage() {

		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			return [ScanFarmStorageBucketName]::azureDescription
		}
		return $this.message
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageBucketName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageBucketName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmCacheBucketName : Step {

	static [string] hidden $description = @'
The Scan Farm includes a cache service that depends on an existing
bucket in your storage system.

IMPORTANT NOTE: You *must* configure your cache service bucket with
an object expiration greater than (not equal to) 7 days.
'@

	static [string] hidden $azureDescription = @'
The Scan Farm includes a cache service that depends on an existing
blob container in your Azure storage account.

IMPORTANT NOTE: You *must* configure your cache service blob container
with an object expiration greater than (not equal to) 7 days. You should
define the policy using the last modified date (not the creation date).
'@

	static [string] hidden $azurePrompt = 'Enter the name of your *existing* cache service blob container'

	ScanFarmCacheBucketName([Config] $config) : base(
		[ScanFarmCacheBucketName].Name, 
		$config,
		'Cache Service Bucket Name',
		[ScanFarmCacheBucketName]::description,
		'Enter the name of your *existing* cache service bucket') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$prompt = $this.prompt
		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			$prompt = [ScanFarmCacheBucketName]::azurePrompt
		}
		return new-object Question($prompt)
	}

	[string]GetMessage() {

		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			return [ScanFarmCacheBucketName]::azureDescription
		}
		return $this.message
	}

	[bool]HandleResponse([IQuestion] $question) {
		$bucketName = ([Question]$question).response
		if ($bucketName -eq $this.config.scanFarmStorageBucketName) {
			Write-Host 'You cannot use the same bucket/container for both the cache and storage services'
			return $false
		}
		$this.config.scanFarmCacheBucketName = $bucketName
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmCacheBucketName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmS3AccessMethod : Step {

	static [string] hidden $description = @'
You can access your S3 buckets using either an access and secret key
or an AWS IAM Role for Service Account (IRSA).
'@

	ScanFarmS3AccessMethod([Config] $config) : base(
		[ScanFarmS3AccessMethod].Name, 
		$config,
		'AWS S3 Access Method',
		[ScanFarmS3AccessMethod]::description,
		'Do you want to use an access and secret key?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to use an access and secret key',
			'No, I want to use IRSA', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3UseServiceAccountName = ([YesNoQuestion]$question).choice -eq 1
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3UseServiceAccountName = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3
	}
}

class ScanFarmS3IamRoleServiceAccount : Step {

	static [string] hidden $description = @'
Using an AWS IAM Role for Service Account (IRSA) is an alternative to
using an access and secret key.
'@

	ScanFarmS3IamRoleServiceAccount([Config] $config) : base(
		[ScanFarmS3IamRoleServiceAccount].Name, 
		$config,
		'AWS IRSA Role',
		[ScanFarmS3IamRoleServiceAccount]::description,
		'Enter your service account name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3ServiceAccountName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3ServiceAccountName = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3 -and
			$this.config.scanFarmS3UseServiceAccountName
	}
}

class ScanFarmS3AccessKey : Step {

static [string] hidden $description = @'
Specify the access key required to access your S3-compliant storage
system.
'@

	ScanFarmS3AccessKey([Config] $config) : base(
		[ScanFarmS3AccessKey].Name, 
		$config,
		'S3 Access Key',
		[ScanFarmS3AccessKey]::description,
		'Enter your S3 access-key') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3AccessKey = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3AccessKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3 -and
			-not $this.config.scanFarmS3UseServiceAccountName
	}
}

class ScanFarmS3SecretKey : Step {

static [string] hidden $description = @'
Specify the secret key required to access your S3-compliant storage
system.
'@

	ScanFarmS3SecretKey([Config] $config) : base(
		[ScanFarmS3SecretKey].Name, 
		$config,
		'S3 Secret Key',
		[ScanFarmS3SecretKey]::description,
		'Enter your S3 secret-key') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3SecretKey = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3SecretKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3 -and
			-not $this.config.scanFarmS3UseServiceAccountName
	}
}

class ScanFarmS3Region : Step {

	static [string] hidden $description = @'
Specify the region where your S3-compliant storage bucket resides.
'@

	ScanFarmS3Region([Config] $config) : base(
		[ScanFarmS3Region].Name, 
		$config,
		'S3 Region',
		[ScanFarmS3Region]::description,
		'Enter your S3 region') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3Region = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3Region = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3
	}
}

class ScanFarmGcsProjectName : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a GCP project when using GCS storage.
'@
	
	ScanFarmGcsProjectName([Config] $config) : base(
		[ScanFarmGcsProjectName].Name, 
		$config,
		'Scan Farm GCP Project',
		[ScanFarmGcsProjectName]::description,
		'Enter your GCP project name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmGcsProjectName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmGcsProjectName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Gcs
	}
}

class ScanFarmGcsKey : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a GCP service account key when using GCS storage.

The service account must have read/write access to the scan farm storage 
and cache buckets.

Visit the following URL for information on obtaining your JSON service
account key: https://cloud.google.com/iam/docs/keys-create-delete
'@
	
	ScanFarmGcsKey([Config] $config) : base(
		[ScanFarmGcsKey].Name, 
		$config,
		'Scan Farm GCP Key',
		[ScanFarmGcsKey]::description,
		'Enter your GCP service account key JSON file path') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt, $false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmGcsSvcAccountKey = ([PathQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmGcsSvcAccountKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Gcs
	}
}

class ScanFarmAzureSubscription : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure subscription when using Azure storage.

You can find your Azure subscription ID with this command:
az account show
'@
	
	ScanFarmAzureSubscription([Config] $config) : base(
		[ScanFarmAzureSubscription].Name, 
		$config,
		'Scan Farm Azure Subscription',
		[ScanFarmAzureSubscription]::description,
		'Enter your Azure subscription ID') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureSubscriptionId = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureSubscriptionId = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmAzureTenantId : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure tenant when using Azure storage.

You can find your Azure tenant ID with this command:
az account show
'@
	
	ScanFarmAzureTenantId([Config] $config) : base(
		[ScanFarmAzureTenantId].Name, 
		$config,
		'Scan Farm Azure Tenant',
		[ScanFarmAzureTenantId]::description,
		'Enter your Azure tenant ID') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureTenantId = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureTenantId = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmAzureResourceGroup : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure Resource Group containing a storage
account when using Azure storage.

You must provide the Azure Resource Group name that contains your
Azure storage account.
'@
	
	ScanFarmAzureResourceGroup([Config] $config) : base(
		[ScanFarmAzureResourceGroup].Name, 
		$config,
		'Scan Farm Azure Resource Group',
		[ScanFarmAzureResourceGroup]::description,
		'Enter the name of your Azure resource group') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureResourceGroup = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureResourceGroup = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmAzureStorageAccountName : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure storage account when using Azure storage.
'@
	
	ScanFarmAzureStorageAccountName([Config] $config) : base(
		[ScanFarmAzureStorageAccountName].Name, 
		$config,
		'Scan Farm Azure Storage Account',
		[ScanFarmAzureStorageAccountName]::description,
		'Enter the name of your Azure storage account') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureStorageAccount = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureStorageAccount = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmAzureStorageAccountKey : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure storage account key when using Azure storage.

You can find your access key on the Azure Portal "Access keys" tab for your 
storage account.
'@
	
	ScanFarmAzureStorageAccountKey([Config] $config) : base(
		[ScanFarmAzureStorageAccountKey].Name, 
		$config,
		'Scan Farm Azure Storage Account Key',
		[ScanFarmAzureStorageAccountKey]::description,
		'Enter the name of your Azure storage account key') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureStorageAccountKey = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureStorageAccountKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmAzureEndpoint : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure endpoint when using Azure storage.

You can find your blob service Azure endpoint on the Azure Portal 
"Endpoints" tab for your storage account.

It will typically look like this:
https://<storage-account-name>.blob.core.windows.net
'@
	
	ScanFarmAzureEndpoint([Config] $config) : base(
		[ScanFarmAzureEndpoint].Name, 
		$config,
		'Scan Farm Azure Endpoint',
		[ScanFarmAzureEndpoint]::description,
		'Enter your Azure endpoint URL') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureEndpoint = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureEndpoint = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmAzureClientId : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure service account with access to your
Azure storage container.

You must provide the client identifier for your application registered 
in Azure AD with access to your storage account. A client ID typically
looks like this: 9b1f8b8d-db8f-4683-8023-2dd7962b1e96
'@
	
	ScanFarmAzureClientId([Config] $config) : base(
		[ScanFarmAzureClientId].Name, 
		$config,
		'Scan Farm Azure Client ID',
		[ScanFarmAzureClientId]::description,
		'Enter your Azure account client ID') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureClientId = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureClientId = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmAzureClientSecret : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure service account with access to your
Azure storage container.

You must provide the client secret for your application registered 
in Azure AD with access to your storage account.
'@
	
	ScanFarmAzureClientSecret([Config] $config) : base(
		[ScanFarmAzureClientSecret].Name, 
		$config,
		'Scan Farm Azure Client Secret',
		[ScanFarmAzureClientSecret]::description,
		'Enter your Azure account client secret') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureClientSecret = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureClientSecret = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

class ScanFarmMinIOHostname : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an external MinIO instance when using MinIO storage.
'@

	ScanFarmMinIOHostname([Config] $config) : base(
		[ScanFarmMinIOHostname].Name, 
		$config,
		'Scan Farm MinIO Hostname',
		[ScanFarmMinIOHostname]::description,
		'Enter your MinIO hostname') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIOHostname = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIOHostname = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

class ScanFarmMinIOPort : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an external MinIO instance when using MinIO storage.

Note: The default port for MinIO is 9000, so enter that value if you haven't 
changed MinIO's configuration.
'@

	ScanFarmMinIOPort([Config] $config) : base(
		[ScanFarmMinIOPort].Name, 
		$config,
		'Scan Farm MinIO Port',
		[ScanFarmMinIOPort]::description,
		'Enter your MinIO port') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object IntegerQuestion($prompt, 0, 65535, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIOPort = ([IntegerQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIOPort = ''
	}
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

class ScanFarmMinIORootUsername : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a root username for your external MinIO instance
when using MinIO storage.
'@

	ScanFarmMinIORootUsername([Config] $config) : base(
		[ScanFarmMinIORootUsername].Name, 
		$config,
		'Scan Farm MinIO Root Username',
		[ScanFarmMinIORootUsername]::description,
		'Enter your MinIO root username') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIORootUsername = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIORootUsername = ''
	}
	
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

class ScanFarmMinIORootPwd : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a root password for your external MinIO instance
when using MinIO storage.
'@

	ScanFarmMinIORootPwd([Config] $config) : base(
		[ScanFarmMinIORootPwd].Name, 
		$config,
		'Scan Farm MinIO Root Password',
		[ScanFarmMinIORootPwd]::description,
		'Enter your MinIO root password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIORootPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIORootPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

class ScanFarmInClusterStorage : Step {

	static [string] hidden $description = @'
If your Scan Farm storage runs on the same cluster where you plan to
install SRM, the SRM web component can access your storage using the
in-cluster storage URL. This is an optional optimization that works
only when SRM and your storage service runs on the same cluster.
'@

	ScanFarmInClusterStorage([Config] $config) : base(
		[ScanFarmInClusterStorage].Name, 
		$config,
		'Scan Farm In-Cluster Storage',
		[ScanFarmInClusterStorage]::description,
		'Do you want to specify an in-cluster storage URL?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'For internal operations, SRM Web should use an in-cluster URL',
			'No, SRM Web should use an in-cluster URL', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$choice = ([YesNoQuestion]$question).choice
		$this.config.scanFarmStorageHasInClusterUrl = $choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageHasInClusterUrl = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

class ScanFarmInClusterStorageUrl : Step {

	static [string] hidden $description = @'
The SRM web component will use the URL you specify here to access your
storage service.

If your storage service is deployed to the same namespace as SRM, you
can specify a non-fully qualified URL like this: http://minio:9000

If your storage service is deployed to another namespace, you should
specify a fully qualified URL that will resolve from SRM's namespace.
'@
	
	ScanFarmInClusterStorageUrl([Config] $config) : base(
		[ScanFarmInClusterStorageUrl].Name, 
		$config,
		'Scan Farm In-Cluster Storage Url',
		[ScanFarmInClusterStorageUrl]::description,
		'Enter the in-cluster URL for your storage service') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageInClusterUrl = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageInClusterUrl = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO -and
			$this.config.scanFarmStorageHasInClusterUrl
	}
}


class ScanFarmMinIOTLS : Step {

	static [string] hidden $description = @'
Specify whether you want to enable TLS to protect the communicaitons 
between the Scan Farm and your external MinIO server.

Note: To enable TLS, you must have access to the certificate associated
with your MinIO CA.
'@

	ScanFarmMinIOTLS([Config] $config) : base(
		[ScanFarmMinIOTLS].Name, 
		$config,
		'Scan Farm MinIO TLS',
		[ScanFarmMinIOTLS]::description,
		'Specify the SSL/TLS mode for your MinIO connection') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Disable', 'Do not use TLS'),
			[tuple]::create('&Secure', 'Use TLS w/o hostname verification'),
			[tuple]::create('Secure + &Hostname Verification', 'Use TLS w/ hostname verification')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$choice = ([MultipleChoiceQuestion]$question).choice
		$this.config.scanFarmMinIOSecure = $choice -eq 1 -or $choice -eq 2
		$this.config.scanFarmMinIOVerifyHostname = $choice -eq 2
		return $true
	}	

	[void]Reset(){
		$this.config.scanFarmMinIOSecure = $false
		$this.config.scanFarmMinIOVerifyHostname = $false
	}
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

class ScanFarmMinIOCert : Step {

	static [string] hidden $description = @'
Specify a file path to the CA file for your MinIO host.
'@

	ScanFarmMinIOCert([Config] $config) : base(
		[ScanFarmMinIOCert].Name, 
		$config,
		'Scan Farm MinIO Cert',
		[ScanFarmMinIOCert]::description,
		'Enter the path to the certificate of your MinIO CA') {}
	
	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIOServerCert = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIOServerCert = ''
	}
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO -and
			$this.config.scanFarmMinIOSecure
	}
}

