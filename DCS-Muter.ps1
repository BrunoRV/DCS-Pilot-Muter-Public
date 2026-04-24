# =====================================================================
# DCS Player Voice Muter - Unified CLI
# License: MIT (Copyright (c) 2026 Bruno V)
# =====================================================================
param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Reinstall,
    [switch]$Status,
    [switch]$Menu,
    [string]$DcsPath

)

$scriptPath = $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($scriptPath)) {
    # Get the executable's path directly if the script path is unavailable.
    $scriptDir = [System.IO.Path]::GetDirectoryName([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
}
else {
    $scriptDir = Split-Path -Parent $scriptPath
}

$script:mainDir = $scriptDir
$srcDir = Join-Path $scriptDir "src"

if (-not [System.IO.Directory]::Exists($srcDir)) {
    Write-Host "`n[-] Critical Error: 'src' folder missing. Please ensure 'src' exists alongside the execution script.`n" -ForegroundColor Red
    exit
}

# Load components securely
. (Join-Path $srcDir "config.ps1")
. (Join-Path $srcDir "core.ps1")
. (Join-Path $srcDir "cli.ps1")
. (Join-Path $srcDir "gui.ps1")

$script:DCS_DIR = Get-Config -ScriptDir $script:mainDir

if (-not [string]::IsNullOrWhiteSpace($DcsPath)) {
    $script:DCS_DIR = $DcsPath
    if (Update-DcsPaths -DcsDir $script:DCS_DIR) {
        Save-Config -ScriptDir $script:mainDir -PathToSave $script:DCS_DIR
    }
}

# Initialize paths
Update-DcsPaths -DcsDir $script:DCS_DIR | Out-Null

# --- CLI Execution Logic ---

if ($Install -or $Uninstall -or $Reinstall -or $Status -or $Menu) {
    if ([string]::IsNullOrWhiteSpace($script:commonFile) -and [string]::IsNullOrWhiteSpace($script:speechFile)) {
        Write-Host "`n[-] Error: DCS installation not found or not configured." -ForegroundColor Red
        Write-Host "[*] Use -DcsPath to specify your DCS folder or run without arguments to use the GUI.`n" -ForegroundColor Yellow
        exit 1
    }
}

if ($Install) {
    Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR | Out-Null
}
elseif ($Uninstall) {
    Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR | Out-Null
}
elseif ($Reinstall) {
    Write-Host "[*] Reinstalling hooks..." -ForegroundColor Cyan
    Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR | Out-Null
    Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR | Out-Null
    Write-Host "[+] Reinstallation complete." -ForegroundColor Green
}
elseif ($Status) {
    Show-Status
}
elseif ($Menu) {
    Show-Menu
}
else {
    # If no parameters passed, run the GUI
    Show-GUI
}
