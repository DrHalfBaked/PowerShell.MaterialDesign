###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example9: Forms and validations
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

try {
    [xml]$Xaml = (Get-content "$PSScriptRoot\DrawerClosingEvent2.xaml")
    $Reader = New-Object System.Xml.XmlNodeReader $Xaml
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} 
catch {
    Write-Error "Error building the Window.`n$_"
    exit
}

$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }


$DrawerHost.add_DrawerOpened({
    Write-Host "Drawer Opened"
    $DrawerHost.Height = $MainWindow.Height  # Make the Drawer size the same as the window, so the Modal can fully cover it.
    $DrawerHost.Width = $MainWindow.Width
})

[scriptblock]$OnClosingDrawer = {
    $DrawerHost.IsLeftDrawerOpen = $false
    $TglBtn_OpenLeftDrawer.IsChecked = $false
    $TglBtn_OpenLeftDrawer.Visibility="Visible"
}

$DrawerHost.add_DrawerClosing({
    Write-Host "Drawer Closing"
    Invoke-Command -Command $OnClosingDrawer
})

$TglBtn_OpenLeftDrawer.add_Click({ 
    $DrawerHost.IsLeftDrawerOpen = $true
    $TglBtn_CloseLeftDrawer.IsChecked = $true
    $TglBtn_OpenLeftDrawer.Visibility="Hidden"
})

$TglBtn_CloseLeftDrawer.add_Click($OnClosingDrawer)

$Window.ShowDialog() | out-null