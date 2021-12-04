###########
#  Learn how to build Material Design based PowerShell apps
# 
#  Common Functions and Assemblies
#
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
#  Last file update:  Dec 4, 2021  09:13
#
[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

function New-Window {
    param (
        [Parameter()]    
        $XamlFile,
        [Parameter()]
        [Switch]$NoSnackbar
    )
        
    try {
        [xml]$Xaml = (Get-content $XamlFile)
        $Reader = New-Object System.Xml.XmlNodeReader $Xaml
        $Window = [Windows.Markup.XamlReader]::Load($Reader)
    } 
    catch {
        Write-Error "Error building Xaml data.`n$_"
        exit
    }
    
    $Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }

    # Objects that have to be declared before the window launches (will run in the same dispatcher thread as the window)
    if (!$NoSnackbar){
        $Script:MessageQueue =   [MaterialDesignThemes.Wpf.SnackbarMessageQueue]::new()
        $Script:MessageQueue.DiscardDuplicates = $true
    }

    return $Window
}

function New-Snackbar {
    param (
        $Snackbar,
        $Text,
        $ButtonCaption
    )
    try{
        if ($ButtonCaption) {       
            $MessageQueue.Enqueue($Text, $ButtonCaption, {$null}, $null, $false, $false, [TimeSpan]::FromHours( 9999 ))
        }
        else {
            $MessageQueue.Enqueue($Text, $null, $null, $null, $false, $false, $null)
        }
        $Snackbar.MessageQueue = $MessageQueue
    }
    catch{
        Write-Error "No MessageQueue was declared in the window. Make sure -NoSnackbar switch wasn't used in New-Window`n$_"
    }
}

function Set-NavigationRailTab {
    param (
        $NavigationRail,
        $TabName
    )
    $NavigationRail.SelectedIndex = [array]::IndexOf((($NavigationRail.Items | Select-Object -ExpandProperty name).toupper()), $TabName.ToUpper())
}

function Get-NavigationRailSelectedTabName {
    param (
        $NavigationRail
    )
    return $NavigationRail.Items | Where-Object {$_.IsSelected -eq "True"} | Select-Object -ExpandProperty name
}

function Get-SaveFilePath {
    Param (
        [string] $InitialDirectory,
        [string] $Filter
    )
    try {
        $SaveFileDialog = [Microsoft.Win32.SaveFileDialog]::New()
        $SaveFileDialog.initialDirectory = $InitialDirectory
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
function Get-OpenFilePath {
    Param (
        [string] $InitialDirectory,
        [string] $Filter
    )
    try{
        $OpenFileDialog = [Microsoft.Win32.OpenFileDialog]::New()
        $OpenFileDialog.initialDirectory = $InitialDirectory
        $OpenFileDialog.filter = $Filter
        # Examples of other common filters: "Word Documents|*.doc|Excel Worksheets|*.xls|PowerPoint Presentations|*.ppt |Office Files|*.doc;*.xls;*.ppt |All Files|*.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        return $OpenFileDialog.filename
    }
    catch {
        Throw "Open-File Error $_"
    }
} 

function Open-ConfigurationFile {
    param(
        $Path
    )
    try {
        [xml]$ConfigXML = (Get-content $Path)
        return $ConfigXML
    } catch {
        Write-error "$Path file not found or not valid"
        return
    }
}

function Add-ItemToUIControl {
    param(
        $UIControl,
        $ItemToAdd
    )
    foreach ($Item in $ItemToAdd) {
        [void] $UIControl.Items.Add($Item)
    }
}