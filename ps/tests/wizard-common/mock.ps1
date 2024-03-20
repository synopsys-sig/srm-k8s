function Get-QueuedInput {

	$val = $global:inputs.dequeue()
	if ($null -ne $val) {
		$val
		Write-Host "'$val' dequeued"
	} else {
		Write-Host 'null dequeued'
	}
	# Start-Sleep -Seconds 2
}

function New-Mocks() {

	Mock -ModuleName Guided-Setup Read-HostChoice {
		Write-Host $args
		Get-QueuedInput
	}

	Mock -ModuleName Guided-Setup Read-Host {
		Write-Host $args
		Get-QueuedInput
	}

	Mock -ModuleName Guided-Setup Clear-HostStep {
	}

	Mock Write-StepGraph {
	}
}

function New-Password([string] $pwdValue) {
	(new-object net.NetworkCredential("",$pwdValue)).securepassword
}
