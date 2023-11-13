class UseDefaultCACerts : Step {

	static [string] hidden $description = @'
Specify whether you want to use the default Java cacerts file. SRM uses a
Java cacerts file to trust secure connections made to third-party applications
such as JIRA, Git, and other tools.

Answer No if you plan to connect to external tools or use services (like LDAPS)
that use self-signed certificates or certificates not issued by a well-known
certificate authority.
'@

	UseDefaultCACerts([Config] $config) : base(
		[UseDefaultCACerts].Name,
		$config,
		'Default Java cacerts',
		[UseDefaultCACerts]::description,
		'Do you want to use the default cacerts file?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, use the default cacerts file.',
			'No, I will specify a path to the cacerts file I want to use.', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useDefaultCACerts = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.useDefaultCACerts = $false
	}

	[bool]CanRun(){
		return -not $this.config.externalDatabaseTrustCert
	}
}

class CACertsFile : Step {

	static [string] hidden $description = @'
Specify the path to your Java cacerts file. You can find the cacerts file
under your Java installation. Use of a cacerts file from a Java 11 JRE 
install is strongly recommended.

The cacerts file is not an individual certificate file. Visit the below URL
and search for "cacerts Certificates File" to learn more:
https://docs.oracle.com/en/java/javase/11/tools/keytool.html

Note: You can find a cacerts file in the lib/security directory under
your Java home directory.
'@

	CACertsFile([Config] $config) : base(
		[CACertsFile].Name,
		$config,
		'Java cacerts File Path',
		[CACertsFile]::description,
		'Enter the path to your cacerts file') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt,	$false, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.caCertsFilePath = ([PathQuestion]$question).response
		return $true
	}

	[bool]CanRun() {
		return -not $this.config.useDefaultCACerts
	}

	[void]Reset(){
		$this.config.caCertsFilePath = ''
	}
}

class CACertsFilePassword : Step {

	static [string] hidden $description = @'
Specify the password to your Java cacerts file. If you have not set a
password, use the default Java cacerts file password (changeit).
'@

	CACertsFilePassword([Config] $config) : base(
		[CACertsFilePassword].Name,
		$config,
		'Java cacerts File Password',
		[CACertsFilePassword]::description,
		'Enter the password for your cacerts file') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {

		$pwd = ([Question]$question).response

		if (-not (Test-KeystorePassword $this.config.caCertsFilePath $pwd)) {
			Write-Host "The password you entered is invalid for $($this.config.caCertsFilePath)."
			Write-Host "Enter a different password or go back and choose a different cacerts file."
			return $false
		}

		$this.config.caCertsFilePwd = $pwd
		return $true
	}

	[void]Reset(){
		$this.config.caCertsFilePwd = ''
	}
}

class AddExtraCertificates : Step {

	static [string] hidden $description = @'
SRM uses a Java cacerts file to trust secure connections made to
third-party applications.

If you want to plan to make connections to tools that use self-signed
certificates or certificates not issued by a well-known certificate authority,
you can add the certificates that SRM should trust.
'@

	AddExtraCertificates([Config] $config) : base(
		[AddExtraCertificates].Name,
		$config,
		'Add Extra Certificates',
		[AddExtraCertificates]::description,
		'Do you want to add extra certificates to trust?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to add extra certificates for SRM to trust.',
			'No, I do not want to add any extra certificates for SRM to trust.', -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.addExtraCertificates = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.addExtraCertificates = $false
	}
}

class ExtraCertificates : Step {

	static [string] hidden $description = @'
Specify each certificate file you want to add. Press Enter at the prompt when
you have finished adding certificates.
'@

	ExtraCertificates([Config] $config) : base(
		[ExtraCertificates].Name,
		$config,
		'Extra Certificate Files',
		[ExtraCertificates]::description,
		'Enter a certificate file') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]Run() {

		Write-HostSection $this.title ($this.GetMessage())

		$files = @()
		while ($true) {
			$question = $this.MakeQuestion($this.prompt)
			$question.allowEmptyResponse = $files.count -gt 0
			if ($question.allowEmptyResponse) {
				$question.emptyResponseLabel = 'Done'
				$question.emptyResponseHelp = 'I finished entering certificate files'
			}
			$question.Prompt()

			if (-not $question.hasResponse) {
				return $false
			}

			if ($question.isResponseEmpty) {
				break
			}
			$files += $question.response
		}

		$this.config.extraTrustedCaCertPaths = $files
		return $true
	}

	[bool]HandleResponse([IQuestion] $question) {
		return $true
	}

	[bool]CanRun() {
		return $this.config.addExtraCertificates
	}

	[void]Reset(){
		$this.config.extraTrustedCaCertPaths = @()
	}
}
