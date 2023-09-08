class UseScanFarm : Step {

	static [string] hidden $description = @'
SRM includes a scan farm feature, a separately licensed component 
capable of running SAST and SCA scans.

The scan farm depends on the following external systems that you
must separately provision/configure:

1) PostgreSQL
2) Redis
3) Object Storage (e.g., AWS, GCS, Azure, MinIO)
'@

	static [string] hidden $notes = @'
- Your deployment includes the scan farm feature. Remember to complete the following tasks:
  * Configure external dependencies (PostgreSQL, Redis, Object Storage)
  * Define your "small" scan job node pool:
  *   Assign a pool-type label (pool-type=small) to analysis node(s).
  *   Assign a scanner node taint (NodeType=ScannerNode:NoSchedule) to analysis node(s).
  *   NOTE: A "small" pool-type requires one or more nodes with 6.5 vCPUs and 26 GB of memory
'@

UseScanFarm([Config] $config) : base(
		[UseScanFarm].Name, 
		$config,
		'Scan Farm',
		[UseScanFarm]::description,
		'Install Scan Farm Components?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, I have an SRM license that includes SAST/SCA scanning', 
			'No, I don''t want to use the Scan Farm at this time', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$this.config.skipScanFarm = ([YesNoQuestion]$question).choice -eq 1

		if (-not $this.config.skipScanFarm) {
			$this.config.SetNote($this.GetType().Name, [UseScanFarm]::notes)
		}
		return $true
	}

	[void]Reset(){
		$this.config.skipScanFarm = $false
		$this.config.RemoveNote($this.GetType().Name)
	}
}

class SigRepoUsername : Step {

	static [string] hidden $description = @'
To use the Scan Farm feature, you must provide a username and password
for the Synopsys SIG Docker Registry. You can obtain your credential by
clicking the 'View/Request Docker Registry Credential' button in the
Synopsys Community portal.

If you are new to Synopsys SIG, request access to Synopsys SIG Community
at https://community.synopsys.com/s/SelfRegistrationForm. Complete and
submit the registration form, and you should receive access instantaneously.

Your credential is the same one you will use to copy Docker images from
the Synopsys Docker registry to your private Docker registry.
'@

	SigRepoUsername([Config] $config) : base(
		[SigRepoUsername].Name, 
		$config,
		'Synopsys SIG Docker Repo Username',
		[SigRepoUsername]::description,
		'Enter your SIG Docker Repo username') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.sigRepoUsername = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.sigRepoUsername = ''
	}
	
	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class SigRepoPassword : Step {

	static [string] hidden $description = @'
To use the Scan Farm feature, you must provide a username and password
for the Synopsys SIG Docker Registry. You can obtain your credential by
clicking the 'View/Request Docker Registry Credential' button in the
Synopsys Community portal.

If you are new to Synopsys SIG, request access to Synopsys SIG Community
at https://community.synopsys.com/s/SelfRegistrationForm. Complete and
submit the registration form, and you should receive access instantaneously.

Your credential is the same one you will use to copy Docker images from
the Synopsys Docker registry to your private Docker registry.
'@

	SigRepoPassword([Config] $config) : base(
		[SigRepoPassword].Name, 
		$config,
		'Synopsys SIG Docker Repo Password',
		[SigRepoPassword]::description,
		'Enter your SIG Docker Repo password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.sigRepoPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.sigRepoPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}
