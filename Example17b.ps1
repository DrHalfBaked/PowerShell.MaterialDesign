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

$Window = New-Window -XamlFile "$PSScriptRoot\Example17b.xaml"

$Services_Datatable = [System.Data.DataTable]::New()
[void]$Services_Datatable.Columns.AddRange(@('CheckboxChecked','Name', 'Description', 'State', 'StartMode'))
$Services_DataGrid.ItemsSource = $Services_Datatable.DefaultView

$Services = Get-CimInstance -ClassName Win32_service | Select-Object name, description, state, startmode

foreach ($Service in $Services) {
    [void]$Services_Datatable.Rows.Add($true,$Service.Name, $Service.Description, $Service.State, $Service.StartMode)
}

$Services_HeaderChkBox.add_Checked({ Write-Host "kuku" })

<# 
$HiddenInsertButton.add_Click({
   
        Write-Host "Clicked row $($Services_DataGrid.SelectedItem.Row.Name)"
})
 #>
$Services_DataGrid.Add_GotMouseCapture({
    $DisplayIndex = $this.CurrentColumn.DisplayIndex
    $OriginalSourceName = $_.OriginalSource.Name
    switch (($_.OriginalSource).GetType().name) {
        "CheckBox" { 
                    if (!$OriginalSourceName) {   # Exclude header checkbox
                        write-host " Checkbox checked on column $DisplayIndex"
                        $this.CurrentItem | out-host }
                    }
        "Button"    {
                        write-host "button $OriginalSourceName checked"
                        $this.CurrentCell.item | out-host
                    }
    }
})

$Services_DataGrid.Add_PreviewKeyDown({
    $_.Handled = $true
})

$async = $Window.Dispatcher.InvokeAsync( {
    $Window.ShowDialog()
})

$async.Wait() | Out-Null  