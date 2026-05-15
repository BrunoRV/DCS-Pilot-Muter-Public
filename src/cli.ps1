# =====================================================================
# DCS Player Voice Muter - CLI Interface
# =====================================================================

function Show-Status {
    param([string]$SavedGamesDir)
    Write-Host "`n=== DCS Pilot Muter Status ===" -ForegroundColor White
    
    $status = Test-HookStatus -SavedGamesDir $SavedGamesDir
    
    $muterStatus = ""
    $colMuter = "White"

    if ($status -eq "NotConfigured") {
        $muterStatus = "Saved Games Not Configured"
        $colMuter = "Red"
    }
    elseif ($status -eq "Installed") {
        $muterStatus = "Installed (Tech Mod)"
        $colMuter = "Green"
    }
    else {
        $muterStatus = "Not Installed"
        $colMuter = "DarkGray"
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
        Show-Status -SavedGamesDir $script:SAVED_GAMES_DIR
        
        Write-Host "1. Install Tech Mod"
        Write-Host "2. Uninstall Tech Mod"
        Write-Host "3. Reinstall Tech Mod"
        Write-Host "4. Exit"
        Write-Host ""
        
        $choice = Read-Host "Select an option [1-4]"
        
        switch ($choice) {
            "1" { Invoke-MuterAction -Action "Install" -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null }
            "2" { Invoke-MuterAction -Action "Uninstall" -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null }
            "3" { 
                Write-Host "[*] Reinstalling..." -ForegroundColor Cyan
                Invoke-MuterAction -Action "Uninstall" -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null
                Invoke-MuterAction -Action "Install" -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null
            }
            "4" { exit }
            default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

