###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example9: Forms and validations
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")
Get-ChildItem "$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll" | Select-Object -ExpandProperty versioninfo | Select-Object -ExpandProperty ProductVersion | out-host   #Material Design Version
Set-Culture -CultureInfo en-IL #(Get-WinSystemLocale | Select-Object -ExpandProperty Name)
try {
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example9.xaml")
    $Reader = New-Object System.Xml.XmlNodeReader $Xaml
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} 
catch {
    Write-Error "Error building Xaml data.`n$_"
    exit
}

$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }

$Drawer_User_Img.Source = "$PSScriptRoot\Resources\Images\mr_bean.jpg"

$DrawerHost.add_DrawerOpened({
    $DrawerHost.Height = $MainWindow.Height  # Make the Drawer size the same as the window, so the Modal can fully cover it.
    $DrawerHost.Width = $MainWindow.Width
})

[scriptblock]$OnClosingDrawer = {
    $DrawerHost.IsLeftDrawerOpen = $false
    $TglBtn_OpenLeftDrawer.IsChecked = $false
    $TglBtn_OpenLeftDrawer.Visibility="Visible"
}

$DrawerHost.add_DrawerClosing($OnClosingDrawer)
$TglBtn_CloseLeftDrawer.add_Click($OnClosingDrawer)

$TglBtn_OpenLeftDrawer.add_Click({ 
    $DrawerHost.IsLeftDrawerOpen = $true
    $TglBtn_CloseLeftDrawer.IsChecked = $true
    $TglBtn_OpenLeftDrawer.Visibility="Hidden"
})

$Cars_Popup_Add_Car.Add_Click( { $NavRail.SelectedIndex = [array]::IndexOf((($NavRail.Items | Select-Object -ExpandProperty name).toupper()),"CarRegistration".ToUpper()) })


$LeftDrawer_ListItem1.Add_Selected({
    $NavRail.SelectedIndex = [array]::IndexOf((($NavRail.Items | Select-Object -ExpandProperty name).toupper()),"MOVIES")  
})

$Window.ShowDialog() | out-null