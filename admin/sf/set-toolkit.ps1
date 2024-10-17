<#PSScriptInfo
.VERSION 1.0.0
.GUID 7e4ef380-64d5-4ffe-81c6-29365c72b254
.AUTHOR Black Duck
#>

param (
	[string] $srmNamespace = 'srm',
	[string] $srmBaseUrl,
	[string] $srmPath = '/srm',
	[string] $srmApiKey = '',
	[string] $repoUsername,
	[string] $repoPwd,
	[string] $scanServiceName,
	[string] $tool = 'coverity',
	[string] $toolVersion = '2024.3.0',
	[int]    $maxUploadPartSize = 500*(1024*1024)
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

'../common/split-file.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-kubernetes GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

if ($tool -ne 'coverity') {
	throw "The coverity tool is the only one supported at this time."
}

# download kit using the repo credential
$downloadFile = "coverity-all-platforms-$toolVersion.tar.gz"
$downloadUri  = "https://sig-repo.synopsys.com/coverity-releases/$toolVersion/$downloadFile"

Write-Host "Downloading $downloadUri..."
Invoke-WebRequest `
 	-Authentication 'Basic' `
 	-Credential (New-Object PSCredential($repoUsername, ($repoPwd | ConvertTo-SecureString -AsPlainText))) `
 	-OutFile $downloadFile `
 	-Uri $downloadUri

Write-Host "Computing hash for $downloadFile..."
$md5Hash = (Get-FileHash $downloadFile -Algorithm MD5).Hash

function New-ServiceToken() {

	# use Administrator API Key to get access_token
	Write-Host 'Obtaining authorization token...'
	$accessTokenResponse = Invoke-RestMethod `
		-Method Post `
		-Uri "$srmBaseUrl$srmPath/oauth/token" `
		-Authentication 'Bearer' `
		-Token ($srmApiKey | ConvertTo-SecureString -AsPlainText) `
		-Body @{
			"authorization_details"='[{"type": "permission", "actions": ["site:admin", "service:internal-access"]}]'
			"grant_type"="client_credentials"
		}

	$accessTokenResponse.access_token | ConvertTo-SecureString -AsPlainText
}

$accessToken = New-ServiceToken

# use access_token as bearer token to start upload
Write-Host "Obtaining manual upload information for $TOOL ($toolVersion) with hash $md5Hash..."
$upload = Invoke-RestMethod `
	-Method Get `
	-Uri "$srmBaseUrl/api/v2/scans/tools/$TOOL/versions/$toolVersion/initiateupload?UploadType=manual&toolName=$TOOL&toolMd5=$md5Hash" `
	-Authentication 'Bearer' `
	-Token $accessToken

# use URL to PUT file that was downloaded (depends on MinIO ingress annotation nginx.ingress.kubernetes.io/proxy-body-size: 8g)
if ($maxUploadPartSize -eq 0) {

	Write-Host "Uploading $downloadFile to $($upload.url)..."
	Invoke-WebRequest `
		-Method Put `
		-Uri $upload.url `
		-InFile $downloadFile
} else {

	# split file
	Write-Host "Splitting file $downloadFile using max part size $maxUploadPartSize..."
	$fileParts = New-FileSplit $downloadFile $maxUploadPartSize

	# start upload
	Write-Host "Initiating multipart upload to $($upload.artifactId)..."
	$multipartUpload = Invoke-RestMethod `
		-Uri "$srmBaseUrl/api/v2/storage/{$($upload.artifactId)}/multipart/initiate" `
		-Authentication 'Bearer' `
		-Token $accessToken

	# get part URLs
	Write-Host "Obtaining multipart URLs for $($upload.artifactId) and $($fileParts.Length) part(s) for upload $($multipartUpload.uploadId)..."
	$multipartUploadUrls = Invoke-RestMethod `
		-Uri "$srmBaseUrl/api/v2/storage/{$($upload.artifactId)}/multipart/part?uploadId=$($multipartUpload.uploadId)&fromPart=1&numParts=$($fileParts.Length)" `
		-Authentication 'Bearer' `
		-Token $accessToken

	Write-Host "Showing part URLs ($($multipartUploadUrls.Length))..."
	$multipartUploadUrls | ForEach-Object {
		Write-Host "$($_.partNumber)) $($_.url) (expires on $($_.expiration))"
	}

	# upload parts
	$partDoc = @('<CompleteMultipartUpload>')
	0..$($fileParts.Length-1) | ForEach-Object {
		Write-Host "Uploading file $($fileParts[$_]) to $($($multipartUploadUrls[$_]).url) as part $_..."
		$partUploadResponse = Invoke-WebRequest `
			-Method PUT `
			-Uri $($multipartUploadUrls[$_]).url `
			-InFile $fileParts[$_]
		$partDoc += "<Part><PartNumber>$($_ + 1)</PartNumber><ETag>$($partUploadResponse.Headers['ETag'])</ETag></Part>"
	}
	$partDoc += @('</CompleteMultipartUpload>')

	# complete upload (upload duration likely means token is now expired)
	Write-Host "Completing multipart upload of $($upload.artifactId)..."
	$partCompleteResponse = Invoke-RestMethod `
		-Uri "$srmBaseUrl/api/v2/storage/{$($upload.artifactId)}/multipart/complete?uploadId=$($multipartUpload.uploadId)" `
		-Authentication 'Bearer' `
		-Token (New-ServiceToken)

	# combine parts (upload duration likely means token is now expired)
	Write-Host "Combining parts with POST to $partCompleteResponse.url..."
	[string]::join('',$partDoc) | Invoke-RestMethod `
		-ContentType 'application/xml' `
		-Method POST `
		-Uri $partCompleteResponse.url
}

# with upload complete, switch to PROGRESS so that the scan service can start work by moving 
# the related job through these stages: STARTED > PROGRESS > UPLOAD_INITIATED > COMPLETED/FAILED
Write-Host "Switching tool upload status to PROGRESS for $TOOL version $toolVersion..."
Invoke-RestMethod `
	-Method Put `
	-ContentType 'application/json' `
	-Uri "$srmBaseUrl/api/v2/scans/tools/$TOOL/versions/$toolVersion/status" `
	-Authentication 'Bearer' `
	-Token (New-ServiceToken) `
	-Body '{"status":"PROGRESS"}'

Write-Host 'The scan service will now work the related job to a COMPLETED (or FAILED) status'




