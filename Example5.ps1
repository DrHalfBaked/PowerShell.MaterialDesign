###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example4: DataTables
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

try {
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example5.xaml")
    $Reader = New-Object System.Xml.XmlNodeReader $Xaml
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} 
catch {
    Write-Error "Error building Xaml data.`n$_"
    exit
}

$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }


$Services_Datatable = [System.Data.DataTable]::New()
[void]$Services_Datatable.Columns.AddRange(@('Name', 'Description', 'State', 'StartMode'))

Function FilterServices {
    $FilterString = [System.Text.StringBuilder]::New()
    if ( $Services_TxtBox_FilterByName.Text) { 
        $FilterString.Append(" Name LIKE '%$($Services_TxtBox_FilterByName.Text)%' AND ") 
    }
    if ($Services_ChkBox_FilterRunning.IsChecked) { 
        $FilterString.Append("State LIKE 'Running'") 
    }
    else {
        $FilterString.Append("State LIKE '%%'")
    }
    $Services_Datatable.DefaultView.RowFilter = $FilterString
    $Services_DataGrid.ItemsSource = $Services_Datatable.DefaultView
}

$Services = Get-CimInstance -ClassName Win32_service | Select-Object name, description, state, startmode

foreach ($Service in $Services) {
    [void]$Services_Datatable.Rows.Add($Service.Name, $Service.Description, $Service.State, $Service.StartMode)
}


[System.Windows.RoutedEventHandler]$Services_Row_ChkBox_CheckEvent = {
    param ($sender,$e)
    Write-Host "Checked row $($Services_DataGrid.SelectedItem)"
}
    
[System.Windows.RoutedEventHandler]$Services_Row_ChkBox_UnCheckEvent = {
    param ($sender,$e)
    Write-Host "UnChecked row $($Services_DataGrid.SelectedItem.Row.Name)"
}

[System.Windows.RoutedEventHandler]$Services_Header_ChkBox_CheckEvent = {
    param ($sender,$e)
    #$ChkBoxItem.SetValue([System.Windows.Controls.CheckBox]::IsCheckedProperty, $true)
    #$Services_DataGrid.Columns[0].SetValue([System.Windows.Controls.CheckBox]::IsCheckedProperty, $true)
    $Setter_ChkBox = [System.Windows.Setter]::new([System.Windows.Controls.CheckBox]::IsCheckedProperty, $true)
    $Services_DataGrid.Columns[0].CellStyle.Setters.Add($Setter_ChkBox)
    Write-Host "Checked header $($Services_DataGrid.SelectedItem)"
}
    
[System.Windows.RoutedEventHandler]$Services_Header_ChkBox_UnCheckEvent = {
    param ($sender,$e)
    Write-Host "UnChecked header "
}
    
$ChkBoxColumn = [System.Windows.Controls.DataGridTemplateColumn]::New()
$ChkBoxItem =[System.Windows.FrameworkElementFactory]::New([System.Windows.Controls.CheckBox])
$ChkBoxItem.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent,$Services_Row_ChkBox_CheckEvent)
$ChkBoxItem.AddHandler([System.Windows.Controls.CheckBox]::UnCheckedEvent,$Services_Row_ChkBox_UnCheckEvent)
$DataTemplate = [System.Windows.DataTemplate]::New()
$DataTemplate.VisualTree = $ChkBoxItem
$ChkBoxColumn.CellTemplate = $DataTemplate
$ChkBoxColumn.CanUserResize = $false
$CellStyle = [System.Windows.Style]::new()
$CellStyle.TargetType = [System.Windows.controls.DataGridCell]
$CellTrigger = [System.Windows.Trigger]::new()
$CellTrigger.Property = [System.Windows.Controls.DataGridCell]::IsSelectedProperty
$CellTrigger.Value = $true
$Setter_CellBorderThickness = [System.Windows.Setter]::new([System.Windows.Controls.DataGridCell]::BorderThicknessProperty ,[System.Windows.Thickness]::new(0))

$CellTrigger.Setters.Add($Setter_CellBorderThickness)
$Color = [System.Windows.Media.SolidColorBrush]::new()
$Color.Opacity = 0
$Setter_CellBackGround = [System.Windows.Setter]::new([System.Windows.Controls.DataGridCell]::BackgroundProperty ,$Color)
$CellTrigger.Setters.Add($Setter_CellBackGround)
$CellStyle.Triggers.Add($CellTrigger)
$ChkBoxColumn.CellStyle = $CellStyle
$HeaderChkBox =[System.Windows.FrameworkElementFactory]::New([System.Windows.Controls.CheckBox])
$HeaderChkBox.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent,$Services_Header_ChkBox_CheckEvent)
$HeaderChkBox.AddHandler([System.Windows.Controls.CheckBox]::UnCheckedEvent,$Services_Header_ChkBox_UnCheckEvent)
$ChkBoxItem.SetValue([System.Windows.Controls.CheckBox]::MarginProperty,[System.Windows.Thickness]::new(9,0,20,0))   # code-behind column will not apply materialDesign:DataGridAssist.ColumnHeaderPadding/CellPadding
$HeaderDataTemplate = [System.Windows.DataTemplate]::New()
$HeaderDataTemplate.VisualTree = $HeaderChkBox
$ChkBoxColumn.Header = "Chk"
$ChkBoxColumn.HeaderTemplate = $HeaderDataTemplate
$Services_DataGrid.Columns.Insert(0, $ChkBoxColumn)
$Services_DataGrid.ItemsSource = $Services_Datatable.DefaultView

$Services_TxtBox_FilterByName.Add_TextChanged({ FilterServices })
$Services_ChkBox_FilterRunning.Add_Checked({ FilterServices })
$Services_ChkBox_FilterRunning.Add_Unchecked({ FilterServices })
$Test.Add_Checked({ FilterServices })

$Window.ShowDialog() | out-null
