$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$installDir = Join-Path $HOME '.local\bin'
$chezmoiCommand = Get-Command chezmoi -ErrorAction SilentlyContinue

if ($chezmoiCommand) {
    $chezmoiPath = $chezmoiCommand.Source
} else {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    $installer = Invoke-RestMethod 'https://get.chezmoi.io/ps1'
    & ([scriptblock]::Create($installer)) -b $installDir
    $chezmoiPath = Join-Path $installDir 'chezmoi.exe'
    if (-not (Test-Path $chezmoiPath)) {
        throw "chezmoi installation did not create $chezmoiPath"
    }
}

$sourceArgs = @()
if (Test-Path (Join-Path $scriptDir '.chezmoiroot')) {
    $sourceArgs = @('--source', $scriptDir)
    $sourceDir = $scriptDir
} else {
    & $chezmoiPath init 'soparsio/dotfiles'
    if ($LASTEXITCODE -ne 0) { throw 'chezmoi init failed' }
    $sourceDir = (& $chezmoiPath source-path).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'chezmoi source-path failed' }
}

$dataBootstrap = Join-Path $sourceDir 'scripts/copy-example-data.ps1'
& $dataBootstrap -SourceDir $sourceDir

Write-Host 'Previewing dotfile changes:'
& $chezmoiPath @sourceArgs diff
if ($LASTEXITCODE -ne 0) { throw 'chezmoi diff failed' }

$answer = Read-Host 'Apply these changes to your home directory? [y/N]'
if ($answer -match '^(?i:y|yes)$') {
    & $chezmoiPath @sourceArgs apply
    if ($LASTEXITCODE -ne 0) { throw 'chezmoi apply failed' }
} else {
    Write-Host 'No changes applied.'
}
