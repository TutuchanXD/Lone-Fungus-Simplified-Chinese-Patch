[CmdletBinding()]
param(
    [string]$GameDirectory
)

$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1 initializes $PSScriptRoot after -File parameter binding.
if ([string]::IsNullOrWhiteSpace($GameDirectory)) {
    $GameDirectory = $PSScriptRoot
}

$SourceHash = '3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB'
$TargetHash = '7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA'
$PatchHash = 'FE7E5EAAFE02A64B7F3148CB0C83ECD4462C59CB3503769CDB09E9342761CAFF'
$ZstdHash = '8076AAE03FEAC7C66B319579E82172EED168DEED2A3F25E5E2D3C60F55E84111'
$SourceSize = 613928694L
$TargetSize = 618844371L
$PatchName = 'LoneFungus.zh-CN.v0.1.0-preview.1.zstpatch'

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Assert-FileExists {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label was not found: $Path"
    }
}

$tempPath = $null

try {
    $GameDirectory = [IO.Path]::GetFullPath($GameDirectory)
    $datPath = Join-Path $GameDirectory 'Lone Fungus.dat'
    $backupPath = Join-Path $GameDirectory 'Lone Fungus.dat.lf-zh-cn.original.bak'
    $patchPath = Join-Path $PSScriptRoot $PatchName
    $zstdPath = Join-Path $PSScriptRoot 'zstd.exe'
    $tempPath = Join-Path $GameDirectory 'Lone Fungus.dat.zh-cn.tmp'

    Assert-FileExists -Path $datPath -Label 'Game DAT'
    Assert-FileExists -Path $patchPath -Label 'Patch file'
    Assert-FileExists -Path $zstdPath -Label 'Zstandard executable'

    Write-Host '[1/6] Checking release files...'
    $actualPatchHash = Get-Sha256 -Path $patchPath
    if ($actualPatchHash -ne $PatchHash) {
        throw "Patch file failed SHA-256 verification: $actualPatchHash"
    }
    $actualZstdHash = Get-Sha256 -Path $zstdPath
    if ($actualZstdHash -ne $ZstdHash) {
        throw "Zstandard executable failed SHA-256 verification: $actualZstdHash"
    }

    if (Get-Process -Name 'Lone Fungus' -ErrorAction SilentlyContinue) {
        throw 'Lone Fungus is running. Close the game before installing.'
    }

    Write-Host '[2/6] Checking current game data...'
    $currentHash = Get-Sha256 -Path $datPath
    if ($currentHash -eq $TargetHash) {
        Write-Host '[OK] This patch is already installed.' -ForegroundColor Green
        exit 0
    }

    $backupExists = Test-Path -LiteralPath $backupPath -PathType Leaf
    if ($backupExists) {
        $backupHash = Get-Sha256 -Path $backupPath
        if ($backupHash -ne $SourceHash) {
            throw "Existing backup has an unexpected SHA-256: $backupHash"
        }
    }

    if ($currentHash -ne $SourceHash -and -not $backupExists) {
        throw "Unsupported Lone Fungus.dat SHA-256: $currentHash. Restore the Steam original with Verify integrity of game files, then retry."
    }

    $driveName = ([IO.Path]::GetPathRoot($GameDirectory)).Substring(0, 1)
    $freeBytes = (Get-PSDrive -Name $driveName).Free
    $requiredBytes = $TargetSize + 134217728L
    if (-not $backupExists) {
        $requiredBytes += $SourceSize
    }
    if ($freeBytes -lt $requiredBytes) {
        $requiredGiB = [Math]::Ceiling(($requiredBytes / 1GB) * 10) / 10
        throw "Not enough free space. At least $requiredGiB GiB is required for a safe install."
    }

    Write-Host '[3/6] Preserving the verified English original...'
    if (-not $backupExists) {
        [IO.File]::Copy($datPath, $backupPath, $false)
        if ((Get-Sha256 -Path $backupPath) -ne $SourceHash) {
            throw 'The backup failed SHA-256 verification.'
        }
    }

    if (Test-Path -LiteralPath $tempPath) {
        [IO.File]::Delete($tempPath)
    }

    Write-Host '[4/6] Reconstructing the Chinese DAT...'
    $zstdArguments = @(
        '-d',
        '--long=30',
        "--patch-from=$backupPath",
        $patchPath,
        '-o',
        $tempPath
    )
    & $zstdPath @zstdArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Zstandard exited with code $LASTEXITCODE."
    }

    Write-Host '[5/6] Verifying the reconstructed DAT...'
    $tempInfo = Get-Item -LiteralPath $tempPath
    if ($tempInfo.Length -ne $TargetSize) {
        throw "Unexpected reconstructed size: $($tempInfo.Length) bytes."
    }
    $tempHash = Get-Sha256 -Path $tempPath
    if ($tempHash -ne $TargetHash) {
        throw "Reconstructed DAT failed SHA-256 verification: $tempHash"
    }

    Write-Host '[6/6] Installing the verified DAT...'
    [IO.File]::Copy($tempPath, $datPath, $true)
    $installedHash = Get-Sha256 -Path $datPath
    if ($installedHash -ne $TargetHash) {
        [IO.File]::Copy($backupPath, $datPath, $true)
        throw 'Installed DAT failed verification. The English backup was restored.'
    }

    Write-Host '[OK] Installation completed successfully.' -ForegroundColor Green
    Write-Host "Installed SHA-256: $installedHash"
    Write-Host "Original backup: $backupPath"
}
catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    if ($tempPath -and (Test-Path -LiteralPath $tempPath -PathType Leaf)) {
        [IO.File]::Delete($tempPath)
    }
}
