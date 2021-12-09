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

Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example9.xaml"

#####Set-Culture -CultureInfo en-IL #(Get-WinSystemLocale | Select-Object -ExpandProperty Name)

Get-Variable -Include "Form_Textbox_*" -ValueOnly | ForEach-Object { Set-OutlinedProperty -TextboxObject $_ -Padding "2" -SetFloatingOffset "5,-18" -SetFloatingScale "0.8" -FontSize 16 }
Get-Variable -Include "Form_Picker_*"  -ValueOnly | ForEach-Object { Set-OutlinedProperty -TextboxObject $_ -Padding "8" -SetFloatingOffset "1,-18" -SetFloatingScale "0.8" -FontSize 16 }

$CarList = Import-Csv -Path "$PSScriptRoot\Cars.csv"
Add-ItemToUIControl -UIControl $Form_Picker_Car_Make -ItemToAdd ($CarList.Make | Select-Object -Unique | Sort-Object )
Add-ItemToUIControl -UIControl $Form_Picker_Car_Color -ItemToAdd ([System.Windows.Media.Colors].Getproperties() | Select-Object -ExpandProperty name | Sort-Object )
Add-ItemToUIControl -UIControl $Form_Picker_Car_Year -ItemToAdd (1990..2021)
$Form_Picker_Car_Make.add_SelectionChanged({
    Add-ItemToUIControl -UIControl $Form_Picker_Car_Model -Clear
    Add-ItemToUIControl -UIControl $Form_Picker_Car_Model -ItemToAdd ($CarList | Where-Object {$_.Make -eq $Form_Picker_Car_Make.SelectedItem }  | Select-Object -ExpandProperty Model | Select-Object -Unique | Sort-Object )
})


$Cars_Datatable = [System.Data.DataTable]::New()
[void]$Cars_Datatable.Columns.AddRange(@('Make', 'Model', 'Owner', 'Color'))
$Cars_Datatable.primarykey = $Cars_Datatable.columns['Make', 'Model', 'Owner', 'Color']
[void]$Cars_Datatable.Rows.Add('Toyota', 'Corolla', 'John Smith', 'Blue')
[void]$Cars_Datatable.Rows.Add('Tesla', 'Model 3', 'Will Bond', 'White')

$Cars_DataGrid.ItemsSource = $Cars_Datatable.DefaultView

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


$NavRail.add_SelectionChanged({
    if ($_.Source -like "System.Windows.Controls.TabControl*") {
        # Write a switch that will run a relevant block for each page
    }
})


$Window.ShowDialog() | out-null