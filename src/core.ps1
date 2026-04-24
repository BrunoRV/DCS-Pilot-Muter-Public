# =====================================================================
# DCS Player Voice Muter - Core Hook Logic
# =====================================================================

function Get-PayloadDefinitions {
    # Define all payloads here for easy extensibility
    return @(
        @{
            Name        = "Common"
            TargetRel   = "Scripts\Speech\common.lua"
            PayloadFile = "common.lua"
        },
        @{
            Name        = "Speech"
            TargetRel   = "Scripts\Speech\speech.lua"
            PayloadFile = "speech.lua"
        }
    )
}

function Invoke-MuterAction {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Install", "Uninstall")]
        [string]$Action,
        
        [Parameter(Mandatory=$true)]
        [string]$DcsDir
    )

    $payloads = Get-PayloadDefinitions
    $srcPayloadDir = Join-Path $script:mainDir "src\payloads"
    
    $successCount = 0
    $totalCount = $payloads.Count

    foreach ($p in $payloads) {
        $targetPath = Join-Path $DcsDir $p.TargetRel
        $payloadSource = Join-Path $srcPayloadDir $p.PayloadFile

        if ($Action -eq "Install") {
            if (-Not [System.IO.File]::Exists($payloadSource)) {
                Write-Host "[-] Error: Payload source file missing: $($p.PayloadFile)" -ForegroundColor Red
                continue
            }
            $rawContent = [System.IO.File]::ReadAllText($payloadSource)
            # Extract only the block between markers to avoid injecting file metadata/comments
            if ($rawContent -match "(?s)(-- \[DCS MUTER INJECT START\].*?-- \[DCS MUTER INJECT END\])") {
                $payloadContent = $Matches[1]
            } else {
                $payloadContent = $rawContent
            }
            
            if (Install-Hook -FilePath $targetPath -Payload $payloadContent) {
                $successCount++
            }
        }
        else {
            if (Uninstall-Hook -FilePath $targetPath) {
                $successCount++
            }
        }
    }

    return ($successCount -eq $totalCount)
}

function Test-HookStatus {
    param([string]$FilePath)
    if ([string]::IsNullOrWhiteSpace($FilePath) -or -Not [System.IO.File]::Exists($FilePath)) { return "FileNotFound" }
    
    # Fast Native .NET I/O to avoid GUI sluggishness
    $content = [System.IO.File]::ReadAllText($FilePath)
    if ($content.Contains("[DCS MUTER INJECT START]")) { return "Installed" }
    
    return "NotInstalled"
}

function Install-Hook {
    param([string]$FilePath, [string]$Payload)
    
    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        Write-Host "[-] Error: No target file specified for installation." -ForegroundColor Red
        return $false
    }

    $status = Test-HookStatus -FilePath $FilePath
    if ($status -eq "FileNotFound") {
        Write-Host "[-] Error: $(Split-Path $FilePath -Leaf) missing!" -ForegroundColor Red
        return $false
    }
    if ($status -eq "Installed") {
        Write-Host "[~] Payload already present in $(Split-Path $FilePath -Leaf). Skipping." -ForegroundColor DarkGray
        return $true
    }
    
    $backupPath = "$FilePath.muter_bak"
    if (-Not [System.IO.File]::Exists($backupPath)) {
        Copy-Item -Path $FilePath -Destination $backupPath
        Write-Host "[+] Created backup: $(Split-Path $backupPath -Leaf)" -ForegroundColor Green
    }
    
    # Ensure the block is separated by newlines
    $payloadWithPadding = "`r`n`r`n$Payload`r`n"
    [System.IO.File]::AppendAllText($FilePath, $payloadWithPadding)
    Write-Host "[+] Successfully injected into $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
    return $true
}

function Uninstall-Hook {
    param([string]$FilePath)
    
    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        Write-Host "[-] Error: No target file specified for uninstallation." -ForegroundColor Red
        return $false
    }

    $status = Test-HookStatus -FilePath $FilePath
    if ($status -eq "FileNotFound") {
        Write-Host "[-] Error: $(Split-Path $FilePath -Leaf) missing!" -ForegroundColor Red
        return $false
    }
    if ($status -eq "NotInstalled") {
        Write-Host "[~] No payload found in $(Split-Path $FilePath -Leaf). Skipping." -ForegroundColor DarkGray
        return $true
    }
    
    $content = [System.IO.File]::ReadAllText($FilePath)
    # Regex to cleanly match our previously injected block, including the added newlines
    $pattern = "(?s)(\r?\n){0,2}-- \[DCS MUTER INJECT START\].*?-- \[DCS MUTER INJECT END\](\r?\n)?"
    $newContent = $content -replace $pattern, ""
    
    [System.IO.File]::WriteAllText($FilePath, $newContent)
    Write-Host "[+] Successfully removed payload from $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
    return $true
}
