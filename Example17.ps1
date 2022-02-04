###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example17: DataTable With Gmail-like controls
#  --------------------
#  Avi Coren (c)
#  Blog     - https://www.materialdesignps.com
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example17.xaml"

$Services_Datatable = [System.Data.DataTable]::New()
[void]$Services_Datatable.Columns.Add('CheckboxSelect',[bool])
[void]$Services_Datatable.Columns.AddRange(@('Name', 'Description', 'State', 'StartMode'))
$Services_Datatable.primarykey = $Services_Datatable.columns['Name']
$Services_DataGrid.ItemsSource = $Services_Datatable.DefaultView
[System.Collections.ArrayList]$Script:SelectedRows = @()

$Services = Get-CimInstance -ClassName Win32_service | Select-Object name, description, state, startmode

foreach ($Service in $Services) {
    [void]$Services_Datatable.Rows.Add($false,$Service.Name, $Service.Description, $Service.State, $Service.StartMode)
}

$Services_DataGrid.add_SelectionChanged({ #Because we use checkboxes for row selection we have to disable the row click selection
    $_.Handled = $true
})

$Services_HeaderChkBox.add_Indeterminate({
    if ($_.OriginalSource.IsMouseOver) {
        $Services_HeaderChkBox.IsChecked = $false  
    }
})

$Services_HeaderChkBox.add_Checked({
    if ($_.OriginalSource.IsMouseOver) {
        $Services_Datatable | ForEach-Object {$_.CheckboxSelect = $true}
        $Script:SelectedRows.Clear()
        $Script:SelectedRows += $Services_Datatable.Rows  # Equivalent of $Services_DataGrid.SelectAll()
        write-host -ForegroundColor "Green" "Select all was ticked. $($SelectedRows.Count) records are selected"
    }
})

$Services_HeaderChkBox.add_UnChecked({
    if ($_.OriginalSource.IsMouseOver) {
        $Services_Datatable | ForEach-Object {$_.CheckboxSelect = $false}
        $SelectedRows.Clear() # Equivalent of $Services_DataGrid.SelectedItems.Clear()
        write-host -ForegroundColor "Red" "Unselect all was ticked. $($SelectedRows.Count) records are selected"
    }
})


$Services_DataGrid.Add_GotMouseCapture({
    $OriginalSourceName = $_.OriginalSource.Name
    if ($OriginalSourceName -ne "Services_HeaderChkBox") {   # Ignore header checkbox click 
        $DisplayIndex = $this.CurrentColumn.DisplayIndex   # Returns the Column index (0 based) where the mouse was clicked on.
        $CurrentItemName = $this.CurrentItem.Name
        $OriginalSource = $_.OriginalSource
        switch (($_.OriginalSource).GetType().name) {
            "CheckBox" { 
                                $Row = $Services_Datatable.select("Name = '$($CurrentItemName)'")  #The search column(s) must be the primary key (return only one result)
                                $RowIndex = $Services_Datatable.Rows.IndexOf($Row[0])
                                $Services_Datatable.Rows[$RowIndex].CheckboxSelect = !($Services_Datatable.Rows[$RowIndex].CheckboxSelect)
                                $OriginalSource.IsChecked = !($OriginalSource.IsChecked) # It has to reflip to get to the right state.
                                if (!$OriginalSource.IsChecked) {
                                    $SelectedRows.Add($Services_Datatable.Rows[$RowIndex])
                                    write-host -ForegroundColor "Blue" "$CurrentItemName was selected. $($SelectedRows.Count) records are selected"
                                }
                                else {
                                    $SelectedRows.RemoveAt( $SelectedRows.IndexOf( ($SelectedRows | Where-Object {$_.name -eq $CurrentItemName})))
                                    write-host -ForegroundColor "Blue" "$CurrentItemName was unselected. $($SelectedRows.Count) records are selected"
                                }
                                if ($Script:SelectedRows.Count -eq ($Script:Services_Datatable.Rows).Count ) {
                                    $Services_HeaderChkBox.IsChecked = $true
                                }
                                elseif ($Script:SelectedRows.Count -eq 0) {
                                    $Services_HeaderChkBox.IsChecked = $false
                                }
                                else {
                                    $Services_HeaderChkBox.IsChecked = $null
                                }
                            break
                        }
            "Button"    {
                            switch ($OriginalSourceName) {
                                "Services_DeleteButton" {write-host -ForegroundColor "Cyan" "Delete action was clicked on Item $CurrentItemName"}
                                "Services_ViewButton" {write-host -ForegroundColor "DarkYellow" "View action was clicked on Item $CurrentItemName"}
                            }
                            break
                        }
        }
    }
})

$async = $Window.Dispatcher.InvokeAsync( {
    $Window.ShowDialog()
})

$async.Wait() | Out-Null  