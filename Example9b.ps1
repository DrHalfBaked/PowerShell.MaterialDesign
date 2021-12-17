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
Set-CurrentCulture

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
    Get-Variable -Include "Car_Reg_Form_Textbox*","Car_Reg_Form_Combobox*","Car_Reg_Form_*Picker*" -ValueOnly | ForEach-Object {Set-ValidationError -UIObject $_ -ClearInvalid}
}

$Car_Reg_Form_Btn_Reset.add_Click($OnResetCarForm)
$Car_Reg_Form_Btn_Cancel.add_Click({ 
    Invoke-Command -Command $OnResetCarForm
    Set-NavigationRailTab -NavigationRail $NavRail -TabName "Cars"
})
$Car_Reg_Form_Btn_Apply.add_Click({
    $FormHasErrors = $false
    Get-Variable -Include "Car_Reg_Form_Combobox*","Car_Reg_Form_*Picker*","Car_Reg_Form_Textbox_Owner","Car_Reg_Form_Textbox_Plate" -ValueOnly | ForEach-Object { Confirm-RequiredField -UI_Object $_ }
    Confirm-TextPatternField -UI_Object $Car_Reg_Form_Textbox_Plate -Regex '^[0-9]{2}-[0-9]{3}-[0-9]{2}$','^[0-9]{3}-[0-9]{2}-[0-9]{3}$' -ErrorText "Invalid plate number"
    Get-Variable -Include "Car_Reg_Form_Combobox*","Car_Reg_Form_*Picker*","Car_Reg_Form_Textbox_Owner","Car_Reg_Form_Textbox_Plate" -ValueOnly | ForEach-Object { 
        if (Set-ValidationError -UIObject $_ -CheckHasError) {
            $FormHasErrors = $true
        }
    }  
    if ($FormHasErrors){
        return
    }
 
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

$Cars_Datatable = [System.Data.DataTable]::New()
[void]$Cars_Datatable.Columns.AddRange(@('Plate', 'Make', 'Model', 'Year', 'Owner', 'Color', 'Note', 'Rating', 'DateReg', 'TimeReg'))
$Cars_Datatable.primarykey = $Cars_Datatable.columns['Plate']
$Cars_DataGrid.ItemsSource = $Cars_Datatable.DefaultView

$Cars_Popup_Add_Car.Add_Click({ Set-NavigationRailTab -NavigationRail $NavRail -TabName "CarRegistration" })

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
            "CarRegistration"   { Invoke-Command -command $OnResetCarForm }
            "Photos"            {  }
            "Movies"            {  }
        }
    }
})

$Car_Reg_Form_TextBox_Plate.add_PreviewTextInput({ 
    $_.Handled = ($_.Text) -notmatch $RegEx_NumbersDash
})

$Car_Reg_Form_TextBox_Owner.add_PreviewTextInput({ 
    $_.Handled = ($_.Text) -notmatch $RegEx_AlphaNumericSpaceUnderscore
})

$Car_Reg_Form_Textbox_Note.add_PreviewTextInput({ 
    $_.Handled = ($_.Text) -notmatch $RegEx_NoteChars
})

$Car_Reg_Form_TextBox_Plate.add_LostFocus({ 
    Confirm-TextPatternField -Regex '^[0-9]{2}-[0-9]{3}-[0-9]{2}$','^[0-9]{3}-[0-9]{2}-[0-9]{3}$' -ErrorText "Invalid plate number"
})

$Car_Reg_Form_TimePicker_Registered.add_SelectedTimeChanged({ Confirm-RequiredField })
$Car_Reg_Form_DatePicker_Registered.add_SelectedDateChanged({ Confirm-RequiredField })
Get-Variable -Include "Car_Reg_Form_Combobox*","Car_Reg_Form_TextBox_Owner","Car_Reg_Form_TimePicker_Registered","Car_Reg_Form_DatePicker_Registered" -ValueOnly |
    ForEach-Object {$_.add_LostFocus({ Confirm-RequiredField })}
Get-Variable -Include "Car_Reg_Form_TextBox_Plate","Car_Reg_Form_TextBox_Owner" -ValueOnly |
    ForEach-Object {$_.add_TextChanged({ Confirm-RequiredField })}

$Window.ShowDialog() | out-null