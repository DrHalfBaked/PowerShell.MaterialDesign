###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example9b: Forms with validations
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example9b.xaml"

# Car form setup
Get-Variable -Include "Car_Reg_Form_Textbox*","Car_Reg_Form_Combobox*","Car_Reg_Form_*Picker*" -ValueOnly |
    ForEach-Object { Set-OutlinedProperty -InputObject $_ -Padding "8" -FloatingOffset "1,-18" -FloatingScale "0.8" -Opacity "0.75" -FontSize 16 }
$CarList = Import-Csv -Path "$PSScriptRoot\Cars.csv"
$Car_Reg_Form_Combobox_Make.ItemsSource = ($CarList.Make | Select-Object -Unique | Sort-Object )
$Car_Reg_Form_Combobox_Color.ItemsSource = ([System.Windows.Media.Colors].Getproperties() | Select-Object -ExpandProperty name | Sort-Object )
$Car_Reg_Form_Combobox_Year.ItemsSource = (1990..2021)
$Car_Reg_Form_Textbox_Note.SpellCheck.IsEnabled = $true
$Car_Reg_Form_Textbox_Owner.SpellCheck.IsEnabled = $true

$Car_Reg_Form_Combobox_Make.add_SelectionChanged({
    $Car_Reg_Form_Combobox_Model.ItemsSource = $null
    $Car_Reg_Form_Combobox_Model.ItemsSource = ($CarList | Where-Object {$_.Make -eq $Car_Reg_Form_Combobox_Make.SelectedItem }  | Select-Object -ExpandProperty Model | Select-Object -Unique | Sort-Object )
})

[scriptblock]$OnResetCarForm = {
    Get-Variable -Include "Car_Reg_Form_Combobox*" -ValueOnly | ForEach-Object {$_.SelectedItem = $null}
    Get-Variable -Include "Car_Reg_Form_Textbox*","Car_Reg_Form_*Picker*" -ValueOnly | ForEach-Object { $_.Text = $null }
    $Car_Reg_Form_RatingBar_Rate.Value = 0
}

$Car_Reg_Form_Btn_Reset.add_Click($OnResetCarForm)
$Car_Reg_Form_Btn_Cancel.add_Click({ 
    Invoke-Command -Command $OnResetCarForm
    Set-NavigationRailTab -NavigationRail $NavRail -TabName "Cars"
})
$Car_Reg_Form_Btn_Apply.add_Click({
    $RowContent = @(
        $Car_Reg_Form_Textbox_Plate.Text
        $Car_Reg_Form_Combobox_Make.SelectedItem
        $Car_Reg_Form_Combobox_Model.SelectedItem
        $Car_Reg_Form_Combobox_Year.SelectedItem
        $Car_Reg_Form_Textbox_Owner.Text
        $Car_Reg_Form_Combobox_Color.SelectedItem
        $Car_Reg_Form_Textbox_Note.Text
        $Car_Reg_Form_RatingBar_Rate.Value
        $Car_Reg_Form_DatePicker_Registered.Text
        $Car_Reg_Form_TimePicker_Registered.Text
    )
    [void]$Cars_Datatable.Rows.Add($RowContent)
    Invoke-Command -Command $OnResetCarForm
    Set-NavigationRailTab -NavigationRail $NavRail -TabName "Cars"
})

# Car table setup
$Cars_Datatable = [System.Data.DataTable]::New()
[void]$Cars_Datatable.Columns.AddRange(@('Plate', 'Make', 'Model', 'Year', 'Owner', 'Color', 'Note', 'Rating', 'DateReg', 'TimeReg'))
$Cars_Datatable.primarykey = $Cars_Datatable.columns['Plate']
$Cars_DataGrid.ItemsSource = $Cars_Datatable.DefaultView

$Cars_Popup_Add_Car.Add_Click({ Set-NavigationRailTab -NavigationRail $NavRail -TabName "CarRegistration" })

# Left drawer setup
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

$NavRail.add_SelectionChanged({
    if ($_.Source -like "System.Windows.Controls.TabControl*") {
        switch (Get-NavigationRailSelectedTabName -NavigationRail $NavRail) {
            "Users"             {  }
            "Cars"              {  }
            "CarRegistration"   {  }
            "Photos"            {  }
            "Movies"            {  }
        }
    }
})


$Car_Reg_Form_TextBox_Plate.add_PreviewTextInput({
    #$_.Handled = ($_.Text) -notmatch '^[0-9]*$'  # Forces inputing only digits
    #$_.Handled = ($_.Text) -notmatch '^[a-zA-Z0-9]*$'  # Forces inputing only letters and digits
    #$_.Handled = ($_.Text) -notmatch '^[a-zA-Z]*$' # Forces inputing only letters
    #$_.Handled = ($_.Text) -notmatch '^[\s_a-zA-Z0-9]*$' #Forces inputing only letters, digits, white spaces, underscores
    $_.Handled = ($_.Text) -notmatch '^[\@\.\-a-zA-Z0-9]*$' # Forces inputing only letters, digits, dots, @, dash (for email address)
    # regex for email address:    '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'
})


$Car_Reg_Form_TextBox_Plate,$Car_Reg_Form_TextBox_Owner | 
    Foreach-Object {    $_.add_LostFocus({ Test-RequiredField })
                        $_.add_TextChanged({ Test-RequiredField })}


$Car_Reg_Form_TimePicker_Registered.add_LostFocus({ Test-RequiredField })

$Window.ShowDialog() | out-null