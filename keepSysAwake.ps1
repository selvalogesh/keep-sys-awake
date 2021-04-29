#Thanks to - https://github.com/damienvanrobaeys/Build-PS1-Systray-Tool
#          - https://www.systanddeploy.com/2018/12/create-your-own-powershell.html
#          - https://stackoverflow.com/questions/54649456/powershell-notifyicon-context-menu
#          - https://adamtheautomator.com/powershell-async/

 


[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')       | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')      | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')          | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null

 

$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\EaseOfAccessDialog.exe")    

 

################################################################################################################################"
# ACTIONS FROM THE SYSTRAY
################################################################################################################################"

 

# ----------------------------------------------------
# Part - Add the systray menu
# ----------------------------------------------------        

 

$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "WPF Systray tool"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true

 

$Menu_Start = New-Object System.Windows.Forms.MenuItem
$Menu_Start.Enabled = $false
$Menu_Start.Text = "Start"

 

$Menu_Stop = New-Object System.Windows.Forms.MenuItem
$Menu_Stop.Enabled = $true
$Menu_Stop.Text = "Stop"

 

$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "Exit"

 

$contextmenu = New-Object System.Windows.Forms.ContextMenu
$Main_Tool_Icon.ContextMenu = $contextmenu
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Start)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Stop)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)

 

# ---------------------------------------------------------------------
# Action to keep system awake
# ---------------------------------------------------------------------

 

$keepAwakeScript = {
    while (1) {
      $wsh = New-Object -ComObject WScript.Shell
      $wsh.SendKeys('+{F15}')
      Start-Sleep -seconds 59
    }
}

 

function Kill-Tree {
    Param([int]$ppid)
    Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $ppid } | ForEach-Object { Kill-Tree $_.ProcessId }
    Stop-Process -Id $ppid
}

 

Start-Job -ScriptBlock $keepAwakeScript -Name "keepAwake"

 

# ---------------------------------------------------------------------
# Action when after a click on the systray icon
# ---------------------------------------------------------------------
$Main_Tool_Icon.Add_Click({                    
    If ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
        $Main_Tool_Icon.GetType().GetMethod("ShowContextMenu",[System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).Invoke($Main_Tool_Icon,$null)
    }
})

 


 # When Start is clicked, start stayawake job and get its pid
$Menu_Start.add_Click({
    $Menu_Stop.Enabled = $true
    $Menu_Start.Enabled = $false
    Stop-Job -Name "keepAwake"
    Start-Job -ScriptBlock $keepAwakeScript -Name "keepAwake"
 })

 

 # When Stop is clicked, kill stay awake job
$Menu_Stop.add_Click({
    $Menu_Stop.Enabled = $false
    $Menu_Start.Enabled = $true
    Stop-Job -Name "keepAwake"
 })

 

# When Exit is clicked, close everything and kill the PowerShell process
$Menu_Exit.add_Click({
    $Main_Tool_Icon.Visible = $false
    $window.Close()
    Stop-Job -Name "keepAwake"
    Stop-Process $pid
 })
 

 

# Make PowerShell Disappear
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

 

# Force garbage collection just to start slightly lower RAM usage.
[System.GC]::Collect()

 

# Create an application context for it to all run within.
# This helps with responsiveness, especially when clicking Exit.
$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)