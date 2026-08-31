[CmdletBinding()]
param(
    [string]$GameDirectory = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

$SourceHash = '3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB'
$TargetHash = '7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA'

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

try {
    $GameDirectory = [IO.Path]::GetFullPath($GameDirectory)
    $datPath = Join-Path $GameDirectory 'Lone Fungus.dat'
    $backupPath = Join-Path $GameDirectory 'Lone Fungus.dat.lf-zh-cn.original.bak'

    if (-not (Test-Path -LiteralPath $datPath -PathType Leaf)) {
        throw "Game DAT was not found: $datPath"
    }
    if (Get-Process -Name 'Lone Fungus' -ErrorAction SilentlyContinue) {
        throw 'Lone Fungus is running. Close the game before uninstalling.'
    }

    $currentHash = Get-Sha256 -Path $datPath
    if ($currentHash -eq $SourceHash) {
        Write-Host '[OK] The verified English original is already installed.' -ForegroundColor Green
        exit 0
    }
    if ($currentHash -ne $TargetHash) {
        throw "Current DAT is not this patch version: $currentHash. Use Steam Verify integrity of game files instead."
    }
    if (-not (Test-Path -LiteralPath $backupPath -PathType Leaf)) {
        throw 'The verified English backup is missing. Use Steam Verify integrity of game files.'
    }

    $backupHash = Get-Sha256 -Path $backupPath
    if ($backupHash -ne $SourceHash) {
        throw "Backup failed SHA-256 verification: $backupHash"
    }

    [IO.File]::Copy($backupPath, $datPath, $true)
    $restoredHash = Get-Sha256 -Path $datPath
    if ($restoredHash -ne $SourceHash) {
        throw "Restored DAT failed SHA-256 verification: $restoredHash"
    }

    Write-Host '[OK] The verified English original was restored.' -ForegroundColor Green
    Write-Host "Restored SHA-256: $restoredHash"
}
catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
