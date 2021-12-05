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
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example4.xaml")
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

$Services_DataGrid.ItemsSource = $Services_Datatable.DefaultView

$Services_TxtBox_FilterByName.Add_TextChanged({ FilterServices })
$Services_ChkBox_FilterRunning.Add_Checked({ FilterServices })
$Services_ChkBox_FilterRunning.Add_Unchecked({ FilterServices })

$Window.ShowDialog() | out-null