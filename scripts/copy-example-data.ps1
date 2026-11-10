param(
    [Parameter(Mandatory = $true)]
    [string] $SourceDir
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$exampleDir = Join-Path $SourceDir 'examples/.chezmoidata'
$dataDir = Join-Path $SourceDir 'home/.chezmoidata'

if (-not (Test-Path -LiteralPath $exampleDir -PathType Container)) {
    throw "Example data directory not found: $exampleDir"
}

New-Item -ItemType Directory -Path $dataDir -Force | Out-Null

Get-ChildItem -LiteralPath $exampleDir -Filter '*.example' -File | ForEach-Object {
    $dataFileName = $_.Name.Substring(0, $_.Name.Length - '.example'.Length)
    $dataFile = Join-Path $dataDir $dataFileName

    $existingDataFile = Get-Item -LiteralPath $dataFile -Force -ErrorAction SilentlyContinue
    if ($null -eq $existingDataFile) {
        Copy-Item -LiteralPath $_.FullName -Destination $dataFile
        Write-Host "Created machine-local data file: home/.chezmoidata/$dataFileName"
    }
}
