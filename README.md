# keep-sys-awake

A Windows system tray app, written as a PowerShell script, that keeps the PC awake while you're away. Every 59 seconds it sends a Shift+F15 keypress. F15 does nothing on a normal keyboard, but it counts as user activity, so the screen doesn't lock and the PC doesn't sleep.

## Usage

1. Download `keepSysAwake.ps1`.
2. Right-click it and choose **Run with PowerShell**.

The script restarts itself in a hidden PowerShell window and adds an icon to the system tray. Right-click the icon for these options:

| Menu item | What it does |
|-----------|--------------|
| **Start** | Starts sending keypresses (it starts automatically when launched). |
| **Stop**  | Pauses keypresses. |
| **Exit**  | Removes the tray icon and quits. |

> On first run, the script sets the PowerShell execution policy to `Unrestricted` for the current user.

## History

This project started as a gist, [keepSysAwake](https://gist.github.com/selvalogesh/37b99e43b932d42b5a9901a33284b4fa), and this repo carries over its full revision history. Revision 4 rewrote the script as a single self-launching `keepSysAwake.cmd`. It didn't work properly, so it was reverted to revision 3 (commit `5b0ccc7`). Development continues in this repo.

## Credits

- [damienvanrobaeys/Build-PS1-Systray-Tool](https://github.com/damienvanrobaeys/Build-PS1-Systray-Tool)
- [Create your own PowerShell systray tool](https://www.systanddeploy.com/2018/12/create-your-own-powershell.html)
- [PowerShell NotifyIcon context menu (Stack Overflow)](https://stackoverflow.com/questions/54649456/powershell-notifyicon-context-menu)
- [PowerShell async](https://adamtheautomator.com/powershell-async/)
