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

Get-Variable -Include "Car_Reg_Form_Textbox_*" -ValueOnly |
    ForEach-Object { Set-OutlinedProperty -TextboxObject $_ -Padding "2" -SetFloatingOffset "5,-18" -SetFloatingScale "0.8" -FontSize 16 }
Get-Variable -Include "Car_Reg_Form_TextboxShort_*","Car_Reg_Form_Combobox_*","Car_Reg_Form_TimePicker_*","Car_Reg_Form_DatePicker_*"  -ValueOnly |
    ForEach-Object { Set-OutlinedProperty -TextboxObject $_ -Padding "8" -SetFloatingOffset "1,-18" -SetFloatingScale "0.8" -FontSize 16 }

$CarList = Import-Csv -Path "$PSScriptRoot\Cars.csv"
Add-ItemToUIControl -UIControl $Car_Reg_Form_Combobox_Make -ItemToAdd ($CarList.Make | Select-Object -Unique | Sort-Object )
Add-ItemToUIControl -UIControl $Car_Reg_Form_Combobox_Color -ItemToAdd ([System.Windows.Media.Colors].Getproperties() | Select-Object -ExpandProperty name | Sort-Object )
Add-ItemToUIControl -UIControl $Car_Reg_Form_Combobox_Year -ItemToAdd (1990..2021)

$Car_Reg_Form_Combobox_Make.add_SelectionChanged({
    Add-ItemToUIControl -UIControl $Car_Reg_Form_Combobox_Model -Clear
    Add-ItemToUIControl -UIControl $Car_Reg_Form_Combobox_Model -ItemToAdd ($CarList | Where-Object {$_.Make -eq $Car_Reg_Form_Combobox_Make.SelectedItem }  | Select-Object -ExpandProperty Model | Select-Object -Unique | Sort-Object )
})

$Cars_Datatable = [System.Data.DataTable]::New()
[void]$Cars_Datatable.Columns.AddRange(@('Plate', 'Make', 'Model', 'Year', 'Owner', 'Color', 'Note', 'Rating', 'DateReg', 'TimeReg'))
$Cars_Datatable.primarykey = $Cars_Datatable.columns['Plate']
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

$Cars_Popup_Add_Car.Add_Click({ Set-NavigationRailTab -NavigationRail $NavRail -TabName "CarRegistration" })

[scriptblock]$OnResetCarForm = {
    Get-Variable -Include "Car_Reg_Form_Combobox*" -ValueOnly | ForEach-Object {$_.SelectedItem = $null}
    Get-Variable -Include "Car_Reg_Form_Textbox*","Car_Reg_Form_DatePicker*","Car_Reg_Form_TimePicker*" -ValueOnly | ForEach-Object { $_.Text = $null }
    $Car_Reg_Form_RatingBar_Rate.Value = 1
}

$NavRail.add_SelectionChanged({
    if ($_.Source -like "System.Windows.Controls.TabControl*") {
        switch (Get-NavigationRailSelectedTabName -NavigationRail $NavRail) {

            "CarRegistration"   {   Invoke-Command -Command $OnResetCarForm
                                    #$Car_Reg_Form_Btn_Apply.IsEnabled = $false 
                                }
        }
    }
})

$Car_Reg_Form_Btn_Reset.add_Click($OnResetCarForm)
$Car_Reg_Form_Btn_Cancel.add_Click({ Set-NavigationRailTab -NavigationRail $NavRail -TabName "Cars" })
$Car_Reg_Form_Btn_Apply.add_Click({
    $RowContent = @(
        $Car_Reg_Form_TextboxShort_Plate.Text
        $Car_Reg_Form_Combobox_Make.SelectedItem
        $Car_Reg_Form_Combobox_Model.SelectedItem
        $Car_Reg_Form_Combobox_Year.SelectedItem
        $Car_Reg_Form_Textbox_Owner.Text
        $Car_Reg_Form_Combobox_Color.SelectedItem
        $Car_Reg_Form_TextboxShort_Note.Text
        $Car_Reg_Form_RatingBar_Rate.Value
        $Car_Reg_Form_DatePicker_Registered.Text
        $Car_Reg_Form_TimePicker_Registered.Text
    )
    [void]$Cars_Datatable.Rows.Add($RowContent)
    Set-NavigationRailTab -NavigationRail $NavRail -TabName "Cars"
})





$Window.ShowDialog() | out-null