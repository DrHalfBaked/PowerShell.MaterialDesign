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

$ConfigXML = Open-ConfigurationFile -Path "$PSScriptRoot\Example.config"

Set-Theme -Window $Window -PrimaryColor $ConfigXML.Parameters.Settings.Appearance.PrimaryColor -SecondaryColor $ConfigXML.Parameters.Settings.Appearance.SecondaryColor -ThemeMode $ConfigXML.Parameters.Settings.Appearance.Mode

Add-ItemToUIControl -UIControl $LeftDrawer_PrimaryColor_LstBox   -ItemToAdd $Script:ThemePrimaryColors
Add-ItemToUIControl -UIControl $LeftDrawer_SecondaryColor_LstBox -ItemToAdd $Script:ThemeSecondaryColors


[scriptblock]$SyncDrawerSizeWithWindow = {
    $DrawerHost.Height = $MainWindow.Height  
    $DrawerHost.Width = $MainWindow.Width
}

[scriptblock]$OnClosingLeftDrawer = {
    $DrawerHost.IsLeftDrawerOpen = $false
    $TglBtn_OpenLeftDrawer.IsChecked = $false
    $TglBtn_OpenLeftDrawer.Visibility="Visible"
}

[scriptblock]$OnLeftDrawerOpen = {
    $SyncDrawerSizeWithWindow
}

$MainWindow.add_SizeChanged($SyncDrawerSizeWithWindow)

$DrawerHost.add_DrawerOpened($OnLeftDrawerOpen)

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
    Set-Theme -Window $Window -PrimaryColor $ConfigXML.Parameters.Settings.Appearance.PrimaryColor -SecondaryColor $ConfigXML.Parameters.Settings.Appearance.SecondaryColor -ThemeMode $ConfigXML.Parameters.Settings.Appearance.Mode
    $LeftDrawer_ThemeMode_TglBtn.IsChecked = if((Get-ThemeMode -Window $Window) -eq "Dark") {$true} else {$false}
    $LeftDrawer_PrimaryColor_LstBox.SelectedIndex = $ThemePrimaryColors.indexof($ConfigXML.Parameters.Settings.Appearance.PrimaryColor)
    $LeftDrawer_SecondaryColor_LstBox.SelectedIndex = $ThemeSecondaryColors.indexof($ConfigXML.Parameters.Settings.Appearance.SecondaryColor)
})

$LeftDrawer_Theme_Apply_Btn.Add_Click( {

    $IsChanged = $false

    if (($Settings_PrimaryColor_CmbBox.SelectedValue) -and $ConfigXML.Parameters.Settings.Appearance.PrimaryColor -ne $Settings_PrimaryColor_CmbBox.SelectedValue) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Appearance.PrimaryColor  =  $Settings_PrimaryColor_CmbBox.SelectedValue
    }

    if (($Settings_SecondaryColor_CmbBox.SelectedValue) -and $ConfigXML.Parameters.Settings.Appearance.SecondaryColor -ne $Settings_SecondaryColor_CmbBox.SelectedValue) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Appearance.SecondaryColor  =  $Settings_SecondaryColor_CmbBox.SelectedValue
    }

    if (($ConfigXML.Parameters.Settings.Appearance.Mode -eq "Light") -and ($Settings_ThemeMode_TglBtn.IsChecked)) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Appearance.Mode  =  "Dark"
    }

    if (($ConfigXML.Parameters.Settings.Appearance.Mode -eq "Dark") -and (!$Settings_ThemeMode_TglBtn.IsChecked)) {
        $IsChanged = $true
        $ConfigXML.Parameters.Settings.Appearance.Mode  =  "Light"
    }

    if ($IsChanged) {
        try {
            $ConfigXML.Save("$PSScriptRoot\YAIFS.config")
            Open-MessageBox -Type Information -Text "Settings were successfully saved"
        }
        catch {
            Open-MessageBox -Type Error -Text $_[0]
            return
        }
    }
    
})





$Window.ShowDialog() | out-null