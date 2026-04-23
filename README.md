# DCS Player Muter

A simple PowerShell script to silence the player character's voice in DCS World while maintaining multiplayer Integrity Check passes.

## Usage

Run the script without parameters to natively launch the interactive Graphical User Interface (GUI):
```powershell
.\DCS-Muter.ps1 -DcsPath "C:\Path\To\DCS"
```

### CLI Parameters

You can also use command-line parameters for quick execution or console fallback:
- `-Menu`: Opens the traditional interactive console menu interface without the GUI.
- `-Install`: Injects the muter hooks.
- `-Uninstall`: Removes the hooks.
- `-Status`: Displays the current installation status.
- `-DcsPath "C:\Path\To\DCS"`: Specifies a custom DCS World path (overrides saved config). If not provided, it will try to find the path automatically or use the last saved path.

### Example
```powershell
.\DCS-Muter.ps1 -Install -DcsPath "C:\SteamLibrary\steamapps\common\DCSWorld"
```

## Manual Installation

If you prefer to install the hooks manually, append the contents of the payload files (located in the `src/payloads/` directory) to the end of the corresponding files in your DCS World installation.

### 1. Speech Core Hooks
- **DCS File:** `[DCS Path]\Scripts\Speech\common.lua`
- **Payload Source:** `src/payloads/common.lua`

### 2. Radio Event Hooks
- **DCS File:** `[DCS Path]\Scripts\Speech\speech.lua`
- **Payload Source:** `src/payloads/speech.lua`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
