class AuthenticationType : Step {

	static [string] hidden $description = @'
By default, SRM users log on using a local account by specifying a 
username and password. SRM can also be configured to authenticate users 
against a SAML 2.0 Identity Provider (IdP) or an LDAP directory.
'@

	AuthenticationType([Config] $config) : base(
		[AuthenticationType].Name, 
		$config,
		'Authentication Type',
		[AuthenticationType]::description,
		'How will users authenticate to SRM?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Local Accounts', 'Use local SRM accounts only'),
			[tuple]::create('&SAML', 'Use local SRM accounts and a SAML IdP'),
			[tuple]::create('L&DAP', 'Use local SRM accounts and an LDAP directory')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$multipleChoiceQuestion = ([MultipleChoiceQuestion]$question)
		$this.config.useSaml = $multipleChoiceQuestion.choice -eq 1
		$this.config.useLdap = $multipleChoiceQuestion.choice -eq 2
		return $true
	}

	[void]Reset(){
		$this.config.useSaml = $false
		$this.config.useLdap = $false
	}
}

class LdapInstructions : Step {
	static [string] hidden $description = @'
SRM supports authentication against an LDAP directory, but you must 
manually configure LDAP.

Refer to the following URL for LDAP configuration instructions. Read the 
instructions at this time and remember to add any necessary certificates 
if you plan to use LDAPS:

https://github.com/synopsys-sig/srm-k8s/blob/feature/srm/docs/auth/use-ldap.md
'@

	LdapInstructions([Config] $config) : base(
		[LdapInstructions].Name, 
		$config,
		'LDAP Authentication',
		[LdapInstructions]::description,
		'Do you want to continue?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, 
			[tuple]::create('&Yes', 'Yes, I will manually configure LDAP later on'),
			-1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return $true
	}

	[bool]CanRun() {
		return $this.config.useLdap
	}
}

class SamlAuthenticationHostBasePath : Step {
	
	static [string] hidden $description = @'
Specify the SAML hostBasePath name to associate with the SRM web application. The SAML 
IdP will connect to your SRM instance using the SRM Assertion Consumer Service (ACS) 
endpoint, which will be a URL that is based on your SRM DNS name.

If your DNS name will be my-srm.synopsys.com accessed via HTTPS, enter this hostBasePath:

https://my-srm.synopsys.com/srm
'@

	SamlAuthenticationHostBasePath([Config] $config) : base(
		[SamlAuthenticationHostBasePath].Name, 
		$config,
		'SRM SAML hostBasePath',
		[SamlAuthenticationHostBasePath]::description,
		'Enter SAML hostBasePath') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlHostBasePath = ([Question]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlHostBasePath = ''
	}
}

class SamlIdpMetadata : Step {

	static [string] hidden $description = @'
Specify the IdP metadata you downloaded from your SAML identity provider.
'@

	SamlIdpMetadata([Config] $config) : base(
		[SamlIdpMetadata].Name, 
		$config,
		'SAML Identity Provider Metadata',
		[SamlIdpMetadata]::description,
		'Enter IdP metadata path') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt,	$false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlIdentityProviderMetadataPath = ([PathQuestion]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlIdentityProviderMetadataPath = ''
	}
}

class SamlAppName : Step {

	static [string] hidden $description = @'
Specify the application name or ID that was previously registered with your 
SAML identity provider and is associated with your SRM application.
'@

	SamlAppName([Config] $config) : base(
		[SamlAppName].Name, 
		$config,
		'SAML Application Name',
		[SamlAppName]::description,
		'Enter SAML client ID/name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlAppName = ([Question]$question).response
		return $true
	}

	[string]GetMessage() {
		return $this.message + "`n`nYour SRM ACS endpoint will be $($this.config.samlHostBasePath)/login/callback/saml."
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlAppName = ''
	}
}

class SamlKeystorePwd : Step {

	static [string] hidden $description = @'
Specify the password to protect the keystore that SRM will create to store 
the key pair that SRM will use to connect to your SAML identify provider.
'@

	SamlKeystorePwd([Config] $config) : base(
		[SamlKeystorePwd].Name, 
		$config,
		'SAML Keystore Password',
		[SamlKeystorePwd]::description,
		'Enter SAML keystore password') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlKeystorePwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlKeystorePwd = ''
	}
}

class SamlPrivateKeyPwd : Step {

	static [string] hidden $description = @'
Specify the password to protect the private key of the key pair that SRM 
will use to connect to your SAML identify provider.
'@

	SamlPrivateKeyPwd([Config] $config) : base(
		[SamlPrivateKeyPwd].Name, 
		$config,
		'SAML Private Key Password',
		[SamlPrivateKeyPwd]::description,
		'Enter SAML private key password') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlPrivateKeyPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlPrivateKeyPwd = ''
	}
}

class SamlExtraConfig : Step {
	static [string] hidden $description = @'
The setup script will configure the following SRM SAML properties based on 
the information you have provided thus far:

- auth.saml2.identityProviderMetadataPath
- auth.saml2.entityId
- auth.saml2.keystorePassword
- auth.saml2.privateKeyPassword
- auth.hostBasePath

You can find the entire list of SRM SAML properties at 
https://community.synopsys.com/s/document-item?bundleId=codedx&topicId=install_guide%2FCodeDxConfiguration%2Fsaml-props.html&_LANG=enus

To configure additional SAML properties, follow these instructions:
https://github.com/synopsys-sig/srm-k8s/blob/feature/srm/docs/auth/use-saml.md
'@

	SamlExtraConfig([Config] $config) : base(
		[SamlExtraConfig].Name, 
		$config,
		'SAML Extra Config',
		[SamlExtraConfig]::description,
		'Do you want to continue?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, 
			[tuple]::create('&Yes', 'Yes, continue to the next step'),
			-1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}
}
