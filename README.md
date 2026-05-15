# DCS Pilot Muter

A simple PowerShell script to silence the player character's voice in DCS World using a non-invasive Tech Mod approach.

## Why this method?
Previously, this script injected code directly into core DCS files. The new version uses a **DCS Tech Mod** and **Hook** system which:
- **Never modifies original DCS files**: No more backups or file corruption.
- **Survives Updates**: Won't be deleted when DCS updates or runs a repair.
- **Passes Integrity Checks**: Safe for use on servers that enforce strict file integrity.

## Usage

Run the script without parameters to launch the GUI:
```powershell
.\DCS-Muter.ps1
```

### CLI Parameters
- `-Install`: Installs the Tech Mod and Hook to your Saved Games folder.
- `-Uninstall`: Removes the mod and hook.
- `-Status`: Displays the current installation status.

## Manual Installation
1. Copy the contents of `src/mod` to `%USERPROFILE%\Saved Games\DCS\Mods\tech\DCS-Muter`.
2. Copy `src/mod/Hooks/MuterHook.lua` to `%USERPROFILE%\Saved Games\DCS\Scripts\Hooks\DCS-Muter-Hook.lua`.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
