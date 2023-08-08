class ScanFarmRedisHost : Step {

	static [string] hidden $description = @'
The SRM Scan Feature depends on an external Redis instance that you
must provide.

You can install Redis in your cluster or you can use an external
Redis provider such as AWS ElastiCache, Azure Cache for Redis, or
GCP Memorystore.

You *must* ensure that the Redis eviction policy is set to
noeviction (maxmemory-policy=noeviction). Your Redis instance must
permit network traffic from the cache service.
'@
	
	ScanFarmRedisHost([Config] $config) : base(
		[ScanFarmRedisHost].Name, 
		$config,
		'Scan Farm Redis Host',
		[ScanFarmRedisHost]::description,
		'Enter the name of your external Redis host') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmRedisHost = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmRedisHost = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmRedisPort : Step {

	static [string] hidden $description = @'
Specify the port that your external Redis host is listening to for
incoming connections.

Note: The default port for Redis is 6379.
'@

	ScanFarmRedisPort([Config] $config) : base(
		[ScanFarmRedisPort].Name, 
		$config,
		'Scan Farm Redis Port',
		[ScanFarmRedisPort]::description,
		'Enter your Redis port number or press Enter to accept the default (6379)') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object IntegerQuestion($prompt, 0, 65535, $false)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$q = [IntegerQuestion]$question
		$this.config.scanFarmRedisPort = $q.isResponseEmpty ? 6379 : $q.intResponse
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmRedisPort = [Config]::externalDatabasePortDefault
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmRedisDatabase : Step {

	static [string] hidden $description = @'
Specify the logical Redis database name (e.g. "1") for the Scan Farm to use.
'@
	
	ScanFarmRedisDatabase([Config] $config) : base(
		[ScanFarmRedisDatabase].Name, 
		$config,
		'Scan Farm Redis Database',
		[ScanFarmRedisDatabase]::description,
		'Enter the name of your Redis database') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmRedisDatabase = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmRedisDatabase = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmRedisAuth : Step {

	static [string] hidden $description = @'
Specify whether you want to enable authentication (requiring a password)
for your Redis server.
'@

	ScanFarmRedisAuth([Config] $config) : base(
		[ScanFarmRedisAuth].Name, 
		$config,
		'Scan Farm Redis Auth',
		[ScanFarmRedisAuth]::description,
		'Do you want to enable authentication?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, I want to enable authentication and will specify a Redis password', 
			'No, I do not want to enable authentication', -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmRedisUseAuth = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmRedisUseAuth = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmRedisPassword : Step {

	static [string] hidden $description = @'
Specify the password for your Redis instance.
'@

	ScanFarmRedisPassword([Config] $config) : base(
		[ScanFarmRedisPassword].Name, 
		$config,
		'Scan Farm Redis Password',
		[ScanFarmRedisPassword]::description,
		'Enter the Redis password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmRedisPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmRedisPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and $this.config.scanFarmRedisUseAuth
	}
}
class ScanFarmRedisTls : Step {

	static [string] hidden $description = @'
Specify whether you want to enable TLS to protect the communicaitons 
between the Scan Farm and your external Redis server.

Note: To enable TLS, you must have access to the certificate associated
with your Redis CA.
'@

	ScanFarmRedisTls([Config] $config) : base(
		[ScanFarmRedisTls].Name, 
		$config,
		'Scan Farm Redis TLS',
		[ScanFarmRedisTls]::description,
		'Specify the SSL/TLS mode for your Redis connection') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Disable', 'Do not use TLS'),
			[tuple]::create('&Secure', 'Use TLS w/o hostname verification'),
			[tuple]::create('Secure + &Hostname Verification', 'Use TLS w/ hostname verification')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$choice = ([MultipleChoiceQuestion]$question).choice
		$this.config.scanFarmRedisSecure = $choice -eq 1 -or $choice -eq 2
		$this.config.scanFarmRedisVerifyHostname = $choice -eq 2
		return $true
	}	

	[void]Reset(){
		$this.config.scanFarmRedisSecure = $false
		$this.config.scanFarmRedisVerifyHostname = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class ScanFarmRedisCert : Step {

	static [string] hidden $description = @'
Specify a file path to the CA file for your Redis host.
'@

	ScanFarmRedisCert([Config] $config) : base(
		[ScanFarmRedisCert].Name, 
		$config,
		'Scan Farm Redis Cert',
		[ScanFarmRedisCert]::description,
		'Enter the path to the certificate of your Redis CA') {}
	
	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmRedisServerCert = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmRedisServerCert = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and $this.config.scanFarmRedisSecure
	}
}
