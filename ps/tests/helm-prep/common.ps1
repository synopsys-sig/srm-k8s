function New-Mocks() {

	Mock Get-AppCommandPath {
		$true
	}

	Mock New-GenericSecret {
		''
	}
}

function Get-TestDriveDirectoryInfo() {

	$TestDrive -is [IO.DirectoryInfo] ? $TestDrive : (New-Object IO.DirectoryInfo($TestDrive))
}