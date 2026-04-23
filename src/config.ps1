# =====================================================================
# DCS Player Voice Muter - Config & Path Management
# =====================================================================

function Get-Config {
    param([string]$ScriptDir)
    $configFile = Join-Path $ScriptDir "muter_config.json"
    if ([System.IO.File]::Exists($configFile)) {
        try {
            $content = [System.IO.File]::ReadAllText($configFile) | ConvertFrom-Json
            if (-not [string]::IsNullOrWhiteSpace($content.DcsPath)) {
                return $content.DcsPath
            }
        }
        catch {}
    }
    return ""
}

function Save-Config {
    param([string]$ScriptDir, [string]$PathToSave)
    $configFile = Join-Path $ScriptDir "muter_config.json"
    $obj = @{ DcsPath = $PathToSave }
    $json = $obj | ConvertTo-Json
    [System.IO.File]::WriteAllText($configFile, $json)
}

function Update-DcsPaths {
    param([string]$DcsDir)
    
    $script:speechFile = ""
    $script:commonFile = ""

    if ([string]::IsNullOrWhiteSpace($DcsDir)) { return $false }
    if (-Not [System.IO.Directory]::Exists($DcsDir)) { return $false }

    $payloads = Get-PayloadDefinitions
    $allFound = $true

    foreach ($p in $payloads) {
        $targetPath = Join-Path $DcsDir $p.TargetRel
        if (-Not [System.IO.File]::Exists($targetPath)) {
            $allFound = $false
        }
        
        # Backward compatibility for old script logic that expects these variables
        if ($p.Name -eq "Speech") { $script:speechFile = $targetPath }
        if ($p.Name -eq "Common") { $script:commonFile = $targetPath }
    }

    return $allFound
}
