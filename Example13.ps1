###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example8: Navigation Rails - Tab awareness + introducing common files
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example13.xaml"
$ConfigFilePath = "$PSScriptRoot\Example.config"
$ConfigXML = Open-ConfigurationFile -Path $ConfigFilePath

Set-Theme -Window $Window -PrimaryColor $ConfigXML.Parameters.Settings.Theme.PrimaryColor -SecondaryColor $ConfigXML.Parameters.Settings.Theme.SecondaryColor -ThemeMode $ConfigXML.Parameters.Settings.Theme.Mode
Add-ItemToUIControl -UIControl $LeftDrawer_PrimaryColor_LstBox   -ItemToAdd $ThemePrimaryColors
Add-ItemToUIControl -UIControl $LeftDrawer_SecondaryColor_LstBox -ItemToAdd $ThemeSecondaryColors
$LeftDrawer_Chip_Img.Source = "$PSScriptRoot\Resources\Images\mr_bean_tiny.jpg"
$LeftDrawer_ThemeMode_TglBtn.IsChecked = if((Get-ThemeMode -Window $Window) -eq "Dark") {$true} else {$false}

[scriptblock]$SyncDrawerSizeWithWindow = {
    $DrawerHost.Height = $MainWindow.Height  
    $DrawerHost.Width = $MainWindow.Width
}

 [scriptblock]$OnWindowStateChanged = {
    if ($MainWindow.WindowState -eq "Maximized"){
        $MainWindow.Height = [System.Windows.SystemParameters]::VirtualScreenHeight 
        $MainWindow.Width =  [System.Windows.SystemParameters]::VirtualScreenWidth
        # The virtual screen is the bounding rectangle of all display monitors
        # It will make sure the window size is big enough to cover all monitors sizes
    }
    elseif ($MainWindow.WindowState -eq "Normal") {
        $MainWindow.Height = $RestoreWindowHeight
        $MainWindow.Width = $RestoreWindowWidth
    } 
} 

[scriptblock]$OnClosingLeftDrawer = {
    $DrawerHost.IsLeftDrawerOpen = $false
    $TglBtn_OpenLeftDrawer.IsChecked = $false
    $TglBtn_OpenLeftDrawer.Visibility="Visible"
}


$MainWindow.Add_Loaded({
    $Script:RestoreWindowWidth  = $MainWindow.Width
    $Script:RestoreWindowHeight = $MainWindow.Height
})
$MainWindow.add_SizeChanged($SyncDrawerSizeWithWindow)
$MainWindow.add_StateChanged($OnWindowStateChanged)

$DrawerHost.add_DrawerOpened($SyncDrawerSizeWithWindow)
$DrawerHost.add_DrawerClosing($OnClosingLeftDrawer)

$TglBtn_CloseLeftDrawer.add_Click($OnClosingLeftDrawer)

$TglBtn_OpenLeftDrawer.add_Click({ 
    $DrawerHost.IsLeftDrawerOpen = $true
    $TglBtn_CloseLeftDrawer.IsChecked = $true
    $TglBtn_OpenLeftDrawer.Visibility="Hidden"
})

$LeftDrawerListBox1.add_SelectionChanged({ 
    $LeftDrawerListBox1.SelectedIndex = -1 
})

$LeftDrawer_ListItem1.add_Selected({
    Set-NavigationRailTab -NavigationRail $NavRail -TabName "Settings"
})

$LeftDrawer_ListItem2.add_Selected({
    $OpeneFilePath = Get-OpenFilePath -InitialDirectory $InitialDirectory  -Filter $FileFilter 
    if ($OpeneFilePath) {
        New-Snackbar -Snackbar $Snackbar1 -Text "You selected $OpeneFilePath"
    }
})

$LeftDrawer_ListItem3.add_Selected({
    $Window.Close()
})

$NavRail.add_SelectionChanged({ 
    New-Snackbar -Snackbar $Snackbar1 -Text "You selected the $(Get-NavigationRailSelectedTabName -NavigationRail $NavRail) page" 
})

$LeftDrawer_ThemeMode_TglBtn.Add_Click({ 
        $ThemeMode = if ($LeftDrawer_ThemeMode_TglBtn.IsChecked -eq $true) {"Dark"} else {"Light"}
        Set-Theme -Window $Window -ThemeMode $ThemeMode
}) 

$LeftDrawer_PrimaryColor_LstBox.Add_SelectionChanged( { 
    $sender = [System.Windows.Controls.ListBox]$args[0]
    $e = [System.Windows.Controls.SelectionChangedEventArgs]$args[1]
    if ($sender.IsMouseCaptured ) {   # this condition prvents the event to be triggered when listbox selection is changed programatically
        Set-Theme -Window $Window -PrimaryColor $LeftDrawer_PrimaryColor_LstBox.SelectedValue
    }
})
   
$LeftDrawer_SecondaryColor_LstBox.Add_SelectionChanged( {
    $sender = [System.Windows.Controls.ListBox]$args[0]
    $e = [System.Windows.Controls.SelectionChangedEventArgs]$args[1]
    if ($sender.IsMouseCaptured ) {   # this condition prvents the event to be triggered when listbox selection is changed programatically
        Set-Theme -Window $Window -SecondaryColor $LeftDrawer_SecondaryColor_LstBox.SelectedValue
    }
})   

$LeftDrawer_Theme_Undo_Btn.Add_Click( {
    Set-Theme -Window $Window -PrimaryColor $ConfigXML.Parameters.Settings.Theme.PrimaryColor -SecondaryColor $ConfigXML.Parameters.Settings.Theme.SecondaryColor -ThemeMode $ConfigXML.Parameters.Settings.Theme.Mode
    $LeftDrawer_ThemeMode_TglBtn.IsChecked = if((Get-ThemeMode -Window $Window) -eq "Dark") {$true} else {$false}
    $LeftDrawer_PrimaryColor_LstBox.SelectedIndex = $ThemePrimaryColors.indexof($ConfigXML.Parameters.Settings.Theme.PrimaryColor)
    $LeftDrawer_SecondaryColor_LstBox.SelectedIndex = $ThemeSecondaryColors.indexof($ConfigXML.Parameters.Settings.Theme.SecondaryColor)
})

$LeftDrawer_Theme_Apply_Btn.Add_Click( {

    $IsChanged = $false
    if (($LeftDrawer_PrimaryColor_LstBox.SelectedValue) -and $ConfigXML.Parameters.Settings.Theme.PrimaryColor -ne $LeftDrawer_PrimaryColor_LstBox.SelectedValue) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Theme.PrimaryColor = $LeftDrawer_PrimaryColor_LstBox.SelectedValue
    }
    if (($LeftDrawer_SecondaryColor_LstBox.SelectedValue) -and $ConfigXML.Parameters.Settings.Theme.SecondaryColor -ne $LeftDrawer_SecondaryColor_LstBox.SelectedValue) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Theme.SecondaryColor = $LeftDrawer_SecondaryColor_LstBox.SelectedValue
    }
    if (($ConfigXML.Parameters.Settings.Theme.Mode -eq "Light") -and ($LeftDrawer_ThemeMode_TglBtn.IsChecked)) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Theme.Mode = "Dark"
    }
    if (($ConfigXML.Parameters.Settings.Theme.Mode -eq "Dark") -and (!$LeftDrawer_ThemeMode_TglBtn.IsChecked)) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Theme.Mode = "Light"
    }
    if ($IsChanged) {
        try {
            $ConfigXML.Save($ConfigFilePath)
            New-Snackbar -Snackbar $Snackbar1 -Text "The theme was successfully saved"
        }
        catch {
            New-Snackbar -Snackbar $Snackbar1 -Text  $_[0] -ButtonCaption "OK"
            return
        }
    }  
})





$Window.ShowDialog() | out-null