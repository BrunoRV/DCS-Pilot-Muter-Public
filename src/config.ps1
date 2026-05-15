# =====================================================================
# DCS Player Voice Muter - Config & Path Management
# =====================================================================

function Get-Config {
    param([string]$ScriptDir)
    $configFile = Join-Path $ScriptDir "muter_config.json"
    $config = @{ SavedGamesPath = "" }
    if ([System.IO.File]::Exists($configFile)) {
        try {
            $content = [System.IO.File]::ReadAllText($configFile) | ConvertFrom-Json
            if (-not [string]::IsNullOrWhiteSpace($content.SavedGamesPath)) { $config.SavedGamesPath = $content.SavedGamesPath }
        }
        catch {}
    }
    return $config
}

function Save-Config {
    param([string]$ScriptDir, [string]$SavedGamesPath)
    $configFile = Join-Path $ScriptDir "muter_config.json"
    $obj = @{ 
        SavedGamesPath = $SavedGamesPath 
    }
    $json = $obj | ConvertTo-Json
    [System.IO.File]::WriteAllText($configFile, $json)
}

function Get-DefaultSavedGamesPath {
    # Try standard Windows location
    $userProfile = [Environment]::GetFolderPath("UserProfile")
    $paths = @(
        (Join-Path $userProfile "Saved Games\DCS"),
        (Join-Path $userProfile "Saved Games\DCS.openbeta")
    )
    
    foreach ($p in $paths) {
        if ([System.IO.Directory]::Exists($p)) { return $p }
    }
    return ""
}

function Update-DcsPaths {
    param([string]$SavedGamesDir)
    
    # Check for Saved Games folders
    $script:hooksDir = ""
    $script:modDir = ""
    if (-not [string]::IsNullOrWhiteSpace($SavedGamesDir) -and [System.IO.Directory]::Exists($SavedGamesDir)) {
        $script:hooksDir = Join-Path $SavedGamesDir "Scripts\Hooks"
        $script:modDir = Join-Path $SavedGamesDir "Mods\tech\DCS-Muter"
        return $true
    }

    return $false
}
