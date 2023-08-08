class GeneratePwds : Step {

	static [string] hidden $description = @'
SRM can auto-generate the remaining passwords and keys, so you don't 
have to specify them individually. The notes provided at deployment 
time will include a command that you can use to fetch the auto-generated 
SRM admin password.
'@

	GeneratePwds([Config] $config) : base(
		[GeneratePwds].Name, 
		$config,
		'Auto-Generated Passwords',
		[GeneratePwds]::description,
		'Do you want to use auto-generated passwords and keys?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to use auto-generated passwords/keys',
			'No, I don''t want to use auto-generated passwords/keys', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useGeneratedPwds = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.useGeneratedPwds = $false
	}
}

class DatabaseRootPwd : Step {

	static [string] hidden $description = @'
Specify the password for the MariaDB root user.
'@

	DatabaseRootPwd([Config] $config) : base(
		[DatabaseRootPwd].Name, 
		$config,
		'Database Root Password',
		[DatabaseRootPwd]::description,
		'Enter a password for the MariaDB root user') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.blacklist = @("'")
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.mariadbRootPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.mariadbRootPwd = ''
	}

    [bool]CanRun(){
		return -not $this.config.skipDatabase -and -not $this.config.useGeneratedPwds
	}
}

class DatabaseReplicationPwd : Step {

	static [string] hidden $description = @'
Specify the password for the MariaDB replication user.
'@

	DatabaseReplicationPwd([Config] $config) : base(
		[DatabaseReplicationPwd].Name, 
		$config,
		'Database Replication Password',
		[DatabaseReplicationPwd]::description,
		'Enter a password for the MariaDB replicator user') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.blacklist = @("'")
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.mariadbReplicatorPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.mariadbReplicatorPwd = ''
	}

    [bool]CanRun(){
		return (-not $this.config.skipDatabase) -and ($this.config.dbSlaveReplicaCount -gt 0) -and -not $this.config.useGeneratedPwds
	}
}

class DatabaseUserPwd : Step {

	static [string] hidden $description = @'
Specify the password for the 'codedx' database user account to access the SRM 
database.
'@

	DatabaseUserPwd([Config] $config) : base(
		[DatabaseUserPwd].Name, 
		$config,
		'SRM Database User Password',
		[DatabaseUserPwd]::description,
		"Enter a password for the SRM database user account") {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.srmDatabaseUserPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.srmDatabaseUserPwd = ''
	}

    [bool]CanRun(){
		return -not $this.config.skipDatabase -and -not $this.config.useGeneratedPwds
	}
}

class AdminPassword : Step {

	static [string] hidden $description = @'
Specify the password you want to use for the SRM admin account. The 
password must be at least eight characters long.
'@
	
    AdminPassword([Config] $config) : base(
		[AdminPassword].Name, 
		$config,
		'SRM Password',
		[AdminPassword]::description,
		'Enter a password for the SRM admin account') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.adminPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.adminPwd = ''
	}

	[bool]CanRun(){
		return -not $this.config.useGeneratedPwds
	}
}

class ToolServiceKey : Step {

	static [string] hidden $description = @'
Specify the key you want to use for the SRM Tool Service. The key provides 
admin access to the tool orchestration system. The key must be at least eight 
characters long.
'@

	ToolServiceKey([Config] $config) : base(
		[ToolServiceKey].Name, 
		$config,
		'SRM Tool Service Password',
		[ToolServiceKey]::description,
		'Enter SRM Tool Service API key/password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.toolServiceApiKey = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.toolServiceApiKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration -and -not $this.config.useGeneratedPwds
	}
}

class MinioAdminPassword : Step {

	static [string] hidden $description = @'
Specify the password you want to use for the MinIO admin account. The 
password must be at least eight characters long.
'@

	MinioAdminPassword([Config] $config) : base(
		[MinioAdminPassword].Name, 
		$config,
		'MinIO Password',
		[MinioAdminPassword]::description,
		'Enter a password for the MinIO admin account') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.minioAdminPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.minioAdminPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration -and -not $this.config.skipMinIO -and -not $this.config.useGeneratedPwds
	}
}
