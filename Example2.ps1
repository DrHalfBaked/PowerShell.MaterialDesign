###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example2: Open and Save Dialog boxes
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
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example2.xaml")
    $Reader = New-Object System.Xml.XmlNodeReader $Xaml
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} 
catch {
    Write-Error "Error building Xaml data.`n$_"
    exit
}

$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }

$InitialDirectory   = "$([Environment]::GetFolderPath("MyDocuments"))"
$FileFilter         = "Text files|*.txt|All Files|*.*"

function Save-File {
    Param (
        [string] $InitialDirectory,
        [string] $Filter
    )
    try {
        $SaveFileDialog = New-Object Microsoft.Win32.SaveFileDialog
        $SaveFileDialog.initialDirectory = $initialDirectory
        $SaveFileDialog.filter = $Filter
        $SaveFileDialog.CreatePrompt = $False;
        $SaveFileDialog.OverwritePrompt = $True;
        $SaveFileDialog.ShowDialog() | Out-Null
        return $SaveFileDialog.filename
    } 
    catch {
        Throw "Save-File Error $_"
    }
} 

function Open-File {
    Param (
        [string] $InitialDirectory,
        [string] $Filter
    )
    try{
        $OpenFileDialog = New-Object Microsoft.Win32.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = $Filter
        # Examples of other common filters: "Word Documents|*.doc|Excel Worksheets|*.xls|PowerPoint Presentations|*.ppt |Office Files|*.doc;*.xls;*.ppt |All Files|*.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        return $OpenFileDialog.filename
    }
    catch {
        Throw "Open-File Error $_"
    }
} 

$Btn_OpenFile.Add_Click({ On_OpenFile })
$Btn_SaveFile.Add_Click({ On_SaveFile })

Function On_OpenFile {
    $OpenedFile = Open-File -InitialDirectory $InitialDirectory  -Filter $FileFilter 
    if ($OpenedFile) {
        $TextBox_Editor.Text = Get-content $OpenedFile -Raw
    }
}

Function On_SaveFile {
    $SavePath = Save-File -InitialDirectory $InitialDirectory -Filter $FileFilter 
    if ($SavePath) {
        $TextBox_Editor.Text | Out-File -FilePath $SavePath -Encoding UTF8
    }
}


$Window.ShowDialog() | out-null