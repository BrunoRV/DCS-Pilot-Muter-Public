# =====================================================================
# DCS Player Voice Muter - CLI Interface
# =====================================================================

function Show-Status {
    Write-Host "`n=== DCS Pilot Muter Status ===" -ForegroundColor White
    
    $speechStatus = Test-HookStatus -FilePath $script:speechFile
    $commonStatus = Test-HookStatus -FilePath $script:commonFile
    
    $muterStatus = ""
    $colMuter = "White"

    if ($speechStatus -eq "FileNotFound" -or $commonStatus -eq "FileNotFound") {
        $muterStatus = "DCS Path Not Configured"
        $colMuter = "Red"
    }
    elseif ($speechStatus -eq "Installed" -and $commonStatus -eq "Installed") {
        $muterStatus = "Installed"
        $colMuter = "Green"
    }
    elseif ($speechStatus -eq "NotInstalled" -and $commonStatus -eq "NotInstalled") {
        $muterStatus = "Not Installed"
        $colMuter = "DarkGray"
    }
    else {
        $muterStatus = "Partially Installed"
        $colMuter = "Yellow"
    }
    
    Write-Host "Muter:          " -NoNewline; Write-Host $muterStatus -ForegroundColor $colMuter
    Write-Host "===============================`n" -ForegroundColor White
}

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "=======================================" -ForegroundColor Cyan
        Write-Host "   DCS Pilot Muter - Console Menu" -ForegroundColor Cyan
        Write-Host "=======================================" -ForegroundColor Cyan
        Show-Status
        
        Write-Host "1. Install Muter Hooks"
        Write-Host "2. Uninstall Muter Hooks"
        Write-Host "3. Reinstall Muter Hooks"
        Write-Host "4. Exit"
        Write-Host ""
        
        $choice = Read-Host "Select an option [1-4]"
        
        switch ($choice) {
            "1" { Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR | Out-Null }
            "2" { Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR | Out-Null }
            "3" { 
                Write-Host "[*] Reinstalling hooks..." -ForegroundColor Cyan
                Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR | Out-Null
                Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR | Out-Null
            }
            "4" { exit }
            default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

