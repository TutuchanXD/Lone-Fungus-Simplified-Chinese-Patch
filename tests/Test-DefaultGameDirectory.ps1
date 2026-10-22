[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$windowsPowerShell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('lf-directory-test-' + [Guid]::NewGuid().ToString('N'))
$scriptDirectory = Join-Path $testRoot 'patch with spaces'
$explicitDirectory = Join-Path $testRoot 'explicit game directory'
$unrelatedDirectory = Join-Path $testRoot 'different working directory'

try {
    foreach ($directory in @($scriptDirectory, $explicitDirectory, $unrelatedDirectory)) {
        [IO.Directory]::CreateDirectory($directory) | Out-Null
    }

    foreach ($name in @('install.ps1', 'uninstall.ps1')) {
        $scriptPath = Join-Path $scriptDirectory $name
        Copy-Item -LiteralPath (Join-Path $repositoryRoot $name) -Destination $scriptPath

        foreach ($explicit in @($false, $true)) {
            $expectedDirectory = $scriptDirectory
            $startInfo = New-Object System.Diagnostics.ProcessStartInfo
            $startInfo.FileName = $windowsPowerShell
            $startInfo.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $scriptPath + '"'
            if ($explicit) {
                $expectedDirectory = $explicitDirectory
                $startInfo.Arguments += ' -GameDirectory "' + $explicitDirectory + '"'
            }
            $startInfo.WorkingDirectory = $unrelatedDirectory
            $startInfo.UseShellExecute = $false
            $startInfo.CreateNoWindow = $true
            $startInfo.RedirectStandardOutput = $true
            # Do not pass PowerShell 7's module path into Windows PowerShell.
            $startInfo.EnvironmentVariables.Remove('PSModulePath')

            $process = [Diagnostics.Process]::Start($startInfo)
            try {
                $output = $process.StandardOutput.ReadToEnd()
                $process.WaitForExit()
                $expectedError = '[ERROR] Game DAT was not found: ' + (Join-Path $expectedDirectory 'Lone Fungus.dat')
                if ($process.ExitCode -ne 1 -or $output.Trim() -ne $expectedError) {
                    throw "$name (explicit=$explicit) did not resolve the expected directory. Exit code: $($process.ExitCode). Output: $output"
                }
                Write-Host "[PASS] $name (explicit=$explicit) resolves the correct directory."
            }
            finally {
                $process.Dispose()
            }
        }
    }
}
finally {
    # Only remove the uniquely created test directory, never a game directory.
    if (Test-Path -LiteralPath $testRoot) {
        $resolvedRoot = [IO.Path]::GetFullPath($testRoot)
        $resolvedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
        if ((Split-Path -Parent $resolvedRoot) -ne $resolvedTemp -or
            (Split-Path -Leaf $resolvedRoot) -notmatch '^lf-directory-test-[0-9a-f]{32}$') {
            throw "Refusing to remove an unexpected test directory: $resolvedRoot"
        }
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
