<#PSScriptInfo
.VERSION 1.0.0
.GUID cf28e4f3-a289-40eb-b86f-367e5e0f54ca
.AUTHOR Black Duck
#>

function New-FilePart([string] $inputFile, [int] $partIndex) {

	$filename = "$inputFile.$partIndex"
	$stream = [IO.File]::Open($filename, [IO.FileMode]::OpenOrCreate)
	$stream.SetLength(0)
	$filename,$stream
}

function New-FileSplit([string] $file, [int] $maxPartSizeBytes, [int] $readBufferSizeBytes=1024) {

	if ($readBufferSizeBytes -le 0) {
		throw "Read buffer size ($readBufferSizeBytes) must be > 0 (1024 recommended)."
	}
	if ($maxPartSizeBytes -lt $readBufferSizeBytes) {
		throw "Maximum part size ($maxPartSizeBytes) must be > $readBufferSizeBytes"
	}

	$inputFile = Resolve-Path $file | Select-Object -ExpandProperty Path

	$fileParts = @()
	$fileReader = new-object IO.BinaryReader(([IO.File]::Open($inputFile, [IO.FileMode]::Open)))
	$buffer = new-object byte[] $readBufferSizeBytes
	$bytesRead = $fileReader.Read($buffer, 0, $buffer.Length)

	if ($bytesRead -eq 0) {
		$fileReader.Close()
		throw "Unable to split empty file '$inputFile'"
	}

	$currentReadIndex = 0
	$currentSplitIndex = 0

	$part = New-FilePart $inputFile $currentSplitIndex; $fileParts += $part[0]
	$filePartWriter = new-object IO.BinaryWriter($part[1])

	while ($bytesRead -gt 0) {

		$thisSplitIndex = ([Math]::DivRem($currentReadIndex, $maxPartSizeBytes)).Item1

		if ($thisSplitIndex -ne $currentSplitIndex) {

			$filePartWriter.Close()

			$currentSplitIndex = $thisSplitIndex
			$part = New-FilePart $inputFile $currentSplitIndex; $fileParts += $part[0]
			$filePartWriter = new-object IO.BinaryWriter($part[1])
		}

		$bytesToCloseThisFileIndex = ($thisSplitIndex + 1) * $maxPartSizeBytes - $currentReadIndex

		if ($bytesRead -le $bytesToCloseThisFileIndex) {
			$filePartWriter.Write($buffer, 0, $bytesRead)
		} else {
			$filePartWriter.Write($buffer, 0, $bytesToCloseThisFileIndex)
			$filePartWriter.Close()

			$currentSplitIndex = $thisSplitIndex + 1
			$part = New-FilePart $inputFile $currentSplitIndex; $fileParts += $part[0]
			$filePartWriter = new-object IO.BinaryWriter($part[1])
			$filePartWriter.Write($buffer, $bytesToCloseThisFileIndex, $bytesRead - $bytesToCloseThisFileIndex)
		}

		$currentReadIndex += $bytesRead
		$bytesRead = $fileReader.Read($buffer, 0, $buffer.Length)
	}

	$filePartWriter.Close()
	$fileReader.Close()

	$fileParts
}