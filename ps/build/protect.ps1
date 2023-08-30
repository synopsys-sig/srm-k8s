function New-ValueProtectionKeyAndSalt([string] $valuePwd) {

	$derivedBytes = New-Object Security.Cryptography.Rfc2898DeriveBytes($valuePwd, 128, 50, 'SHA512')
	try {
		$keyBytes =$derivedBytes.GetBytes(32)
		$salt = [Convert]::ToBase64String($derivedBytes.Salt)
		$keyBytes,$salt
	} finally {
		$derivedBytes.Dispose()
	}
}

function New-ValueProtectionKey([string] $valuePwd, [string] $salt) {

	$saltBytes = [Convert]::FromBase64String($salt)
	$derivedBytes = New-Object Security.Cryptography.Rfc2898DeriveBytes($valuePwd, $saltBytes, 50, 'SHA512')
	try {
		$derivedBytes.GetBytes(32)
	} finally {
		$derivedBytes.Dispose()
	}
}

function Protect-StringValue([string] $valuePwd, [string] $value) {

	$valueBytes = [Text.Encoding]::UTF8.GetBytes($value)

	$encryptKey = New-ValueProtectionKeyAndSalt $valuePwd
	$keyBytes = $encryptKey[0]
	$salt = $encryptKey[1]

	$encryptorAlg = [security.cryptography.aes]::create()
	try {
		$encryptorAlg.Key = $keyBytes
		$encryptor = $encryptorAlg.CreateEncryptor($encryptorAlg.Key, $encryptorAlg.IV)
		try {
			$encryptorStream = New-Object IO.MemoryStream
			try {
				$encryptorStream.Write($encryptorAlg.IV, 0, $encryptorAlg.IV.Length)
				$csEncrypt = New-Object Security.Cryptography.CryptoStream($encryptorStream, $encryptor, [Security.Cryptography.CryptoStreamMode]::Write)
				try {
					$csEncrypt.Write($valueBytes, 0, $valueBytes.Length)
					$csEncrypt.FlushFinalBlock()
					$encrypted = $encryptorStream.ToArray()
				} finally {
					$csEncrypt.Dispose()
				}
			}
			finally {
				$encryptorStream.Dispose()
			}
		} finally {
			$encryptor.Dispose()
		} 
	} finally {
		$encryptorAlg.Dispose()
	}
	$salt,[Convert]::ToBase64String($encrypted)
}

function Unprotect-StringValue([string] $valuePwd, [string] $salt, [string] $protectedValue) {

	$data = [Convert]::FromBase64String($protectedValue)
	$decryptorStream = New-Object IO.MemoryStream($data, 0, $data.Length)
	try {
		$decryptorAlg = [security.cryptography.aes]::create()
		try {
			$iv = New-Object byte[] $decryptorAlg.IV.Length
			$ivCount = $decryptorStream.Read($iv, 0, $iv.Length)
			if ($ivCount -ne $iv.Length) {
				throw "Unexpectedly read $($iv.Length) instead of $ivCount bytes"
			}
			$decryptorAlg.IV = $iv

			$decryptKey = New-ValueProtectionKey $valuePwd $salt
			$decryptorAlg.Key = $decryptKey
			
			$decryptor = $decryptorAlg.CreateDecryptor($decryptorAlg.Key, $decryptorAlg.IV)
			try {
				try {
					$csDecrypt = New-Object Security.Cryptography.CryptoStream($decryptorStream, $decryptor, [Security.Cryptography.CryptoStreamMode]::Read)
					$streamReader = New-Object IO.StreamReader($csDecrypt)
					try {
						$streamReader.ReadToEnd()
					} finally {
						$streamReader.Dispose()
					}
				} finally {
					$csDecrypt.Dispose()
				}
			} finally {
				$decryptor.Dispose()
			}
		} finally {
			$decryptorAlg.Dispose()
		}
	} finally {
		$decryptorStream.Dispose()
	}
}
