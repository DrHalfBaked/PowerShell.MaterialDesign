###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example8: Navigation Rails - Tab awareness + introducing common files
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example8.xaml"

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

$LeftDrawerListBox1.add_SelectionChanged({
    
    switch ($LeftDrawerListBox1.SelectedItem.Content) {
        "Settings"  {
                        Set-NavigationRailTab -NavigationRail $NavRail -TabName "Settings"
                    }

        "Open File" {
                        $OpeneFilePath = Get-OpenFilePath -InitialDirectory $InitialDirectory  -Filter $FileFilter 
                        if ($OpeneFilePath) {
                            New-Snackbar -Snackbar $Snackbar1 -Text "You selected $OpeneFilePath"
                        }
                    }

        "Exit"      {
                        $Window.Close()
                    }
    }
    $DrawerHost.IsLeftDrawerOpen = $false
    $LeftDrawerListBox1.SelectedIndex = -1
})

$NavRail.add_SelectionChanged({ 
    New-Snackbar -Snackbar $Snackbar1 -Text "You selected the $(Get-NavigationRailSelectedTabName -NavigationRail $NavRail) page" 
})

$LeftDrawerListBox1.add_SelectionChanged({ 
     
})

$Window.ShowDialog() | out-null