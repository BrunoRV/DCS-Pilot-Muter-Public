# =====================================================================
# DCS Player Voice Muter - Core Hook Logic
# =====================================================================


function Invoke-MuterAction {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Install", "Uninstall")]
        [string]$Action,
        
        [Parameter(Mandatory=$true)]
        [string]$SavedGamesDir
    )

    $srcModDir = Join-Path $script:mainDir "src\mod"
    
    if ($Action -eq "Install") {
        if (-not [System.IO.Directory]::Exists($SavedGamesDir)) {
            Write-Host "[-] Error: Saved Games directory not found: $SavedGamesDir" -ForegroundColor Red
            return $false
        }

        # 1. Create directory structure
        $targetModDir = Join-Path $SavedGamesDir "Mods\tech\DCS-Muter"
        $targetHooksDir = Join-Path $SavedGamesDir "Scripts\Hooks"
        
        New-Item -Path $targetModDir -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path $targetModDir "Scripts") -ItemType Directory -Force | Out-Null
        New-Item -Path $targetHooksDir -ItemType Directory -Force | Out-Null

        # 2. Copy Mod files
        Copy-Item -Path (Join-Path $srcModDir "entry.lua") -Destination $targetModDir -Force
        Copy-Item -Path (Join-Path $srcModDir "Scripts\MuterPayload.lua") -Destination (Join-Path $targetModDir "Scripts") -Force
        Copy-Item -Path (Join-Path $srcModDir "Hooks\MuterHook.lua") -Destination $targetHooksDir -Force -PassThru | Rename-Item -NewName "DCS-Muter-Hook.lua" -Force

        Write-Host "[+] Successfully installed Tech Mod to Saved Games." -ForegroundColor Cyan
        return $true
    }
    else {
        # Uninstall
        $targetModDir = Join-Path $SavedGamesDir "Mods\tech\DCS-Muter"
        $targetHookFile = Join-Path $SavedGamesDir "Scripts\Hooks\DCS-Muter-Hook.lua"

        if ([System.IO.Directory]::Exists($targetModDir)) {
            Remove-Item -Path $targetModDir -Recurse -Force
            Write-Host "[+] Removed Tech Mod from Saved Games." -ForegroundColor Cyan
        }
        if ([System.IO.File]::Exists($targetHookFile)) {
            Remove-Item -Path $targetHookFile -Force
            Write-Host "[+] Removed Hook from Saved Games." -ForegroundColor Cyan
        }

        return $true
    }
}


function Test-HookStatus {
    param([string]$SavedGamesDir)
    if ([string]::IsNullOrWhiteSpace($SavedGamesDir)) { return "NotConfigured" }
    
    $hookFile = Join-Path $SavedGamesDir "Scripts\Hooks\DCS-Muter-Hook.lua"
    if ([System.IO.File]::Exists($hookFile)) {
        return "Installed"
    }
    
    return "NotInstalled"
}
