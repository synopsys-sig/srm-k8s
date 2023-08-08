class Step : GuidedSetupStep {

	[Config] $config

	Step([string] $name, 
		[Config] $config,
		[string] $title,
		[string] $message,
		[string] $prompt) : base($name, $title, $message, $prompt) {

		$this.config = $config
	}
}