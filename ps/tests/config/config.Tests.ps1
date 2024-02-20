$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

BeforeAll {
	. (Join-Path $PSScriptRoot '../../keyvalue.ps1')
	. (Join-Path $PSScriptRoot '../../build/protect.ps1')
	. (Join-Path $PSScriptRoot '../../config.ps1')
}

Describe 'Lock config' -Tag 'config' {

	It 'should not require locking' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.ShouldLock() | Should -BeFalse
	}

	It 'should require locking' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'
		$config.ShouldLock() | Should -BeTrue
	}

	It 'should be locked' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'

		$config.Lock('password')
		$config.isLocked | Should -BeTrue
	}

	It 'should not support re-locking' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'

		$config.Lock('password')
		$config.isLocked | Should -BeTrue

		$err = ''
		try {
			$config.Lock('password')
		} catch {
			$err = $_
		}
		'Unable to lock config because it''s already locked' -eq $err | Should -BeTrue
	}

	It 'should encrypt admin password' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'

		'password' -eq $config.adminPwd | Should -BeTrue

		$config.Lock('password')

		'password' -eq $config.adminPwd | Should -BeFalse
		'password' -eq [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($config.adminPwd)) | Should -BeFalse

		$config.salts.Count -eq 1 | Should -BeTrue
		$config.salts[0].key -eq 'adminPwd' | Should -BeTrue
		$config.salts[0].value.Length -gt 0 | Should -BeTrue
		
		$config.isLocked | Should -BeTrue
	}
}

Describe 'Unlock config' -Tag 'config' {

	It 'should be unlocked' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'

		$config.Lock('password')
		$config.isLocked | Should -BeTrue

		$config.Unlock('password')
		$config.isLocked | Should -BeFalse
		'password' -eq $config.adminPwd | Should -BeTrue
	}

	It 'should not support re-unlocking' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'

		$config.Lock('password')
		$config.isLocked | Should -BeTrue

		$config.Unlock('password')
		$config.isLocked | Should -BeFalse

		$err = ''
		try {
			$config.Unlock('password')
		} catch {
			$err = $_
		}
		'Unable to unlock config because it''s already unlocked' -eq $err | Should -BeTrue
	}

	It 'should decrypt admin password' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'

		'password' -eq $config.adminPwd | Should -BeTrue

		$config.Lock('password')

		$config.isLocked | Should -BeTrue
		'password' -eq $config.adminPwd | Should -BeFalse
		'password' -eq [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($config.adminPwd)) | Should -BeFalse

		$config.salts.Count -eq 1 | Should -BeTrue
		$config.salts[0].key -eq 'adminPwd' | Should -BeTrue
		$config.salts[0].value.Length -gt 0 | Should -BeTrue

		$config.Unlock('password')

		$config.isLocked | Should -BeFalse
		'password' -eq $config.adminPwd | Should -BeTrue
		$config.salts.Count -eq 0 | Should -BeTrue
	}

	It 'should support partially protected config' {

		$config = new-object Config
		$config.workDir = '/dir'
		$config.adminPwd = 'password'

		'password' -eq $config.adminPwd | Should -BeTrue

		$config.Lock('password')

		$config.isLocked | Should -BeTrue
		'password' -eq $config.adminPwd | Should -BeFalse
		'password' -eq [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($config.adminPwd)) | Should -BeFalse

		$config.salts.Count -eq 1 | Should -BeTrue
		$config.salts[0].key -eq 'adminPwd' | Should -BeTrue
		$config.salts[0].value.Length -gt 0 | Should -BeTrue

		# add unprotected field to locked config
		$config.mariadbRootPwd = 'password'

		$config.Unlock('password')

		$config.isLocked | Should -BeFalse
		'password' -eq $config.adminPwd | Should -BeTrue
		'password' -eq $config.mariadbRootPwd | Should -BeTrue
		$config.salts.Count -eq 0 | Should -BeTrue
	}
}