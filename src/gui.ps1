# =====================================================================
# DCS Player Voice Muter - Graphical User Interface
# =====================================================================

function Show-GUI {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Colors
    $colorBg = [System.Drawing.SystemColors]::Control
    $colorFg = [System.Drawing.SystemColors]::ControlText
    $colorInputBg = [System.Drawing.SystemColors]::Window

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "DCS Pilot Muter"
    $form.ClientSize = New-Object System.Drawing.Size(420, 200)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.BackColor = $colorBg
    $form.ForeColor = $colorFg
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

    # --- Saved Games Section ---
    $lblSG = New-Object System.Windows.Forms.Label
    $lblSG.Text = "Saved Games Folder:"
    $lblSG.Location = New-Object System.Drawing.Point(20, 15)
    $lblSG.AutoSize = $true
    $form.Controls.Add($lblSG)

    $txtSG = New-Object System.Windows.Forms.TextBox
    $txtSG.Text = $script:SAVED_GAMES_DIR
    $txtSG.Location = New-Object System.Drawing.Point(20, 37)
    $txtSG.Size = New-Object System.Drawing.Size(280, 23)
    $txtSG.ReadOnly = $true
    $txtSG.BackColor = $colorInputBg
    $txtSG.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $form.Controls.Add($txtSG)

    $btnBrowseSG = New-Object System.Windows.Forms.Button
    $btnBrowseSG.Text = "Browse..."
    $btnBrowseSG.Location = New-Object System.Drawing.Point(310, 36)
    $btnBrowseSG.Size = New-Object System.Drawing.Size(80, 25)
    $btnBrowseSG.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnBrowseSG.BackColor = $colorInputBg
    $form.Controls.Add($btnBrowseSG)


    # Status Label
    $lblMuterStatus = New-Object System.Windows.Forms.Label
    $lblMuterStatus.Text = "Muter: Checking..."
    $lblMuterStatus.Location = New-Object System.Drawing.Point(20, 80)
    $lblMuterStatus.Size = New-Object System.Drawing.Size(380, 20)
    $lblMuterStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblMuterStatus)

    # Toggle Buttons
    $btnToggleMuter = New-Object System.Windows.Forms.Button
    $btnToggleMuter.Text = "Install Muter"
    $btnToggleMuter.Location = New-Object System.Drawing.Point(20, 120)
    $btnToggleMuter.Size = New-Object System.Drawing.Size(180, 45)
    $btnToggleMuter.Enabled = $false
    $btnToggleMuter.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnToggleMuter.FlatAppearance.BorderSize = 0
    $form.Controls.Add($btnToggleMuter)

    $btnReinstall = New-Object System.Windows.Forms.Button
    $btnReinstall.Text = "Reinstall"
    $btnReinstall.Location = New-Object System.Drawing.Point(220, 120)
    $btnReinstall.Size = New-Object System.Drawing.Size(180, 45)
    $btnReinstall.Enabled = $false
    $btnReinstall.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnReinstall.FlatAppearance.BorderSize = 0
    $form.Controls.Add($btnReinstall)

    # Loading Element
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(30, 180)
    $progressBar.Size = New-Object System.Drawing.Size(360, 5)
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    $progressBar.Visible = $false
    $form.Controls.Add($progressBar)

    function Start-Loading {
        $btnToggleMuter.Enabled = $false
        $btnReinstall.Enabled = $false
        $btnBrowseSG.Enabled = $false
        $progressBar.Visible = $true
        [System.Windows.Forms.Application]::DoEvents()
    }

    function Stop-Loading {
        $btnBrowseSG.Enabled = $true
        $progressBar.Visible = $false
        [System.Windows.Forms.Application]::DoEvents()
    }

    function Update-UIStatus {
        $status = Test-HookStatus -SavedGamesDir $script:SAVED_GAMES_DIR
        
        if ($status -eq "NotConfigured") {
            $lblMuterStatus.Text = "Muter: Saved Games not found."
            $lblMuterStatus.ForeColor = [System.Drawing.Color]::DarkRed
            $btnToggleMuter.Enabled = $false
            $btnReinstall.Enabled = $false
            return
        }

        if ($status -eq "Installed") {
            $lblMuterStatus.Text = "Muter: Installed (Tech Mod)"
            $lblMuterStatus.ForeColor = [System.Drawing.Color]::DarkGreen
            $btnToggleMuter.Text = "Uninstall Muter"
            $btnToggleMuter.BackColor = [System.Drawing.Color]::IndianRed
            $btnToggleMuter.ForeColor = [System.Drawing.Color]::White
            $btnReinstall.Enabled = $true
            $btnReinstall.BackColor = [System.Drawing.Color]::CornflowerBlue
        }
        else {
            $lblMuterStatus.Text = "Muter: Not Installed"
            $lblMuterStatus.ForeColor = [System.Drawing.Color]::DarkRed
            $btnToggleMuter.Text = "Install Muter"
            $btnToggleMuter.BackColor = [System.Drawing.Color]::MediumSeaGreen
            $btnToggleMuter.ForeColor = [System.Drawing.Color]::White
            $btnReinstall.Enabled = $false
            $btnReinstall.BackColor = [System.Drawing.Color]::DarkGray
        }

        $btnToggleMuter.Enabled = $true
    }

    $btnBrowseSG.Add_Click({
            $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $dialog.Description = "Select your DCS Saved Games folder (e.g., %USERPROFILE%\Saved Games\DCS)"
            if ($dialog.ShowDialog() -eq "OK") {
                $script:SAVED_GAMES_DIR = $dialog.SelectedPath
                $txtSG.Text = $script:SAVED_GAMES_DIR
                Save-Config -ScriptDir $script:mainDir -DcsPath $script:DCS_DIR -SavedGamesPath $script:SAVED_GAMES_DIR
                Update-UIStatus
            }
        })

    $btnBrowseDCS.Add_Click({
            $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $dialog.Description = "Select your DCS Installation folder (Optional)"
            if ($dialog.ShowDialog() -eq "OK") {
                $script:DCS_DIR = $dialog.SelectedPath
                $txtDCS.Text = $script:DCS_DIR
                Save-Config -ScriptDir $script:mainDir -DcsPath $script:DCS_DIR -SavedGamesPath $script:SAVED_GAMES_DIR
                Update-UIStatus
            }
        })

    $btnToggleMuter.Add_Click({
            Start-Loading
            $status = Test-HookStatus -SavedGamesDir $script:SAVED_GAMES_DIR
            Start-Sleep -Milliseconds 300
            if ($status -eq "Installed") {
                Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null
            }
            else {
                Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null
            }
            Update-UIStatus
            Stop-Loading
        })

    $btnReinstall.Add_Click({
            Start-Loading
            Start-Sleep -Milliseconds 300
            Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null
            Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR -SavedGamesDir $script:SAVED_GAMES_DIR | Out-Null
            Update-UIStatus
            Stop-Loading
        })

    $form.Add_Load({ Update-UIStatus })
    $form.ShowDialog() | Out-Null
}
