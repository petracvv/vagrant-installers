# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

# Download signore release artifact and unzip in the current directory

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

$releases_uri = "https://api.github.com/repos/hashicorp/signore/releases/latest"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "token ${env:HASHIBOT_TOKEN}")

try {
    $response = Invoke-WebRequest -Uri $releases_uri -Headers $headers -UseBasicParsing
} catch  {
    Write-Error "Request for latest signore release failed: ${PSItem}"
    exit 1
}

$response_content = $response.Content | ConvertFrom-Json
$artifactUrl = $response_content.assets | where { $_.Name -like "*windows_x86_64.zip" } | Select -ExpandProperty url

if ($artifactUrl -eq "") {
    Write-Error "Failed to detect latest signore release for Windows (empty match)"
    exit 1
}

# Download signore release artifact
$signore_zip_file = "C:\Windows\Temp\signore.zip"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "token ${env:HASHIBOT_TOKEN}")
$headers.Add("Accept", "application/octet-stream")

try {
    $response = Invoke-WebRequest -Uri $artifactUrl -Headers $headers -OutFile $signore_zip_file
} catch {
    Write-Error "Request for latest signore release artifact failed: ${PSItem}"
}

New-Item -ItemType "directory" -Path "c:\hashicorp\tools"

try {
   & "C:\Program Files\7-Zip\7z.exe" x -y -o"c:\hashicorp\tools" C:\Windows\Temp\signore.zip
} catch {
    Write-Error "Expansion of signore release artifact failed: ${PSItem}"
    exit 1
}