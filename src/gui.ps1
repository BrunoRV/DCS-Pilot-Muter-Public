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
    $form.ClientSize = New-Object System.Drawing.Size(420, 260)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.BackColor = $colorBg
    $form.ForeColor = $colorFg
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

    # Path Label
    $lblPath = New-Object System.Windows.Forms.Label
    $lblPath.Text = "DCS Folder Path:"
    $lblPath.Location = New-Object System.Drawing.Point(20, 20)
    $lblPath.AutoSize = $true
    $form.Controls.Add($lblPath)

    # Path TextBox
    $txtPath = New-Object System.Windows.Forms.TextBox
    $txtPath.Text = $script:DCS_DIR
    $txtPath.Location = New-Object System.Drawing.Point(20, 45)
    $txtPath.Size = New-Object System.Drawing.Size(280, 23)
    $txtPath.ReadOnly = $true
    $txtPath.BackColor = $colorInputBg
    $txtPath.ForeColor = $colorFg
    $txtPath.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $form.Controls.Add($txtPath)

    # Browse Button
    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Text = "Browse..."
    $btnBrowse.Location = New-Object System.Drawing.Point(310, 44)
    $btnBrowse.Size = New-Object System.Drawing.Size(80, 25)
    $btnBrowse.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnBrowse.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
    $btnBrowse.BackColor = $colorInputBg
    $form.Controls.Add($btnBrowse)

    # Status Group
    $lblMuterStatus = New-Object System.Windows.Forms.Label
    $lblMuterStatus.Text = "Muter: Checking..."
    $lblMuterStatus.Location = New-Object System.Drawing.Point(20, 90)
    $lblMuterStatus.Size = New-Object System.Drawing.Size(380, 20)
    $lblMuterStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblMuterStatus)


    # Toggle Buttons
    $btnToggleMuter = New-Object System.Windows.Forms.Button
    $btnToggleMuter.Text = "Install Muter"
    $btnToggleMuter.Location = New-Object System.Drawing.Point(20, 160)
    $btnToggleMuter.Size = New-Object System.Drawing.Size(180, 45)
    $btnToggleMuter.Enabled = $false
    $btnToggleMuter.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnToggleMuter.FlatAppearance.BorderSize = 0
    $form.Controls.Add($btnToggleMuter)

    # Reinstall Button
    $btnReinstall = New-Object System.Windows.Forms.Button
    $btnReinstall.Text = "Reinstall"
    $btnReinstall.Location = New-Object System.Drawing.Point(220, 160)
    $btnReinstall.Size = New-Object System.Drawing.Size(180, 45)
    $btnReinstall.Enabled = $false
    $btnReinstall.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnReinstall.FlatAppearance.BorderSize = 0
    $form.Controls.Add($btnReinstall)


    # Loading Element
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(30, 230)
    $progressBar.Size = New-Object System.Drawing.Size(360, 5)
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    $progressBar.Visible = $false
    $form.Controls.Add($progressBar)

    function Start-Loading {
        $btnToggleMuter.Enabled = $false
        $btnReinstall.Enabled = $false
        $btnBrowse.Enabled = $false
        $progressBar.Visible = $true
        [System.Windows.Forms.Application]::DoEvents()
    }

    function Stop-Loading {
        $btnBrowse.Enabled = $true
        $progressBar.Visible = $false
        [System.Windows.Forms.Application]::DoEvents()
    }

    function Update-UIStatus {
        $isValidPath = Update-DcsPaths -DcsDir $script:DCS_DIR
        
        if (-not $isValidPath) {
            $errorMsg = if ([string]::IsNullOrWhiteSpace($script:DCS_DIR)) { "No directory selected." } else { "Invalid DCS Directory." }
            $lblMuterStatus.Text = "Muter: " + $errorMsg
            
            $lblMuterStatus.ForeColor = [System.Drawing.Color]::DarkRed
            
            $btnToggleMuter.Enabled = $false
            $btnReinstall.Enabled = $false
            return
        }

        $speechStatus = Test-HookStatus -FilePath $script:speechFile
        $commonStatus = Test-HookStatus -FilePath $script:commonFile
        
        # Update Muter Status
        if ($speechStatus -eq "Installed" -and $commonStatus -eq "Installed") {
            $lblMuterStatus.Text = "Muter: Installed"
            $lblMuterStatus.ForeColor = [System.Drawing.Color]::DarkGreen
            $btnToggleMuter.Text = "Uninstall Muter"
            $btnToggleMuter.BackColor = [System.Drawing.Color]::IndianRed
            $btnToggleMuter.ForeColor = [System.Drawing.Color]::White
        }
        elseif ($speechStatus -eq "NotInstalled" -and $commonStatus -eq "NotInstalled") {
            $lblMuterStatus.Text = "Muter: Not Installed"
            $lblMuterStatus.ForeColor = [System.Drawing.Color]::DarkRed
            $btnToggleMuter.Text = "Install Muter"
            $btnToggleMuter.BackColor = [System.Drawing.Color]::MediumSeaGreen
            $btnToggleMuter.ForeColor = [System.Drawing.Color]::White
        }
        else {
            $lblMuterStatus.Text = "Muter: Partially Installed (Fix Needed)"
            $lblMuterStatus.ForeColor = [System.Drawing.Color]::OrangeRed
            $btnToggleMuter.Text = "Fix Muter"
            $btnToggleMuter.BackColor = [System.Drawing.Color]::MediumSeaGreen
            $btnToggleMuter.ForeColor = [System.Drawing.Color]::White
        }

        # Update Reinstall Button
        if ($speechStatus -eq "Installed" -or $commonStatus -eq "Installed") {
            $btnReinstall.BackColor = [System.Drawing.Color]::CornflowerBlue
            $btnReinstall.ForeColor = [System.Drawing.Color]::White
            $btnReinstall.Enabled = $true
        }
        else {
            $btnReinstall.BackColor = [System.Drawing.Color]::DarkGray
            $btnReinstall.ForeColor = [System.Drawing.Color]::White
            $btnReinstall.Enabled = $false
        }

        $btnToggleMuter.Enabled = $true
    }

    $btnBrowse.Add_Click({
            $dialog = New-Object System.Windows.Forms.OpenFileDialog
            $dialog.ValidateNames = $false
            $dialog.CheckFileExists = $false
            $dialog.CheckPathExists = $true
            $dialog.Title = "Select DCS Installation Folder"
            $dialog.FileName = "Select Folder"

            if (-Not [string]::IsNullOrWhiteSpace($script:DCS_DIR) -and [System.IO.Directory]::Exists($script:DCS_DIR)) {
                $dialog.InitialDirectory = $script:DCS_DIR
            }

            if ($dialog.ShowDialog() -eq "OK") {
                Start-Loading
                $lblMuterStatus.Text = "Loading..."
                [System.Windows.Forms.Application]::DoEvents()
            
                # The OpenFileDialog returns the path including "Select Folder" dummy string
                $selectedPath = Split-Path $dialog.FileName -Parent
            
                $script:DCS_DIR = $selectedPath
                Save-Config -ScriptDir $script:mainDir -PathToSave $script:DCS_DIR
            
                $txtPath.Text = $script:DCS_DIR
            
                # Simulate a brief delay to ensure the user actually sees the feedback UI
                Start-Sleep -Milliseconds 250
            
                Update-UIStatus
                Stop-Loading
            }
        })

    $btnToggleMuter.Add_Click({
            $isValidPath = Update-DcsPaths -DcsDir $script:DCS_DIR
            if (-not $isValidPath) { return }

            Start-Loading
            [System.Windows.Forms.Application]::DoEvents()

            $speechStatus = Test-HookStatus -FilePath $script:speechFile
            $commonStatus = Test-HookStatus -FilePath $script:commonFile

            Start-Sleep -Milliseconds 300

            if ($speechStatus -eq "Installed" -and $commonStatus -eq "Installed") {
                Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR | Out-Null
            }
            else {
                Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR | Out-Null
            }
        
            Update-UIStatus
            Stop-Loading
        })

    $btnReinstall.Add_Click({
            $isValidPath = Update-DcsPaths -DcsDir $script:DCS_DIR
            if (-not $isValidPath) { return }

            Start-Loading
            [System.Windows.Forms.Application]::DoEvents()

            Start-Sleep -Milliseconds 300

            Invoke-MuterAction -Action "Uninstall" -DcsDir $script:DCS_DIR | Out-Null
            Invoke-MuterAction -Action "Install" -DcsDir $script:DCS_DIR | Out-Null
        
            Update-UIStatus
            Stop-Loading
        })

    $form.Add_Load({ Update-UIStatus })
    $form.ShowDialog() | Out-Null
}
