###########
#  Learn how to build Material Design based PowerShell apps
# 
#  Common Functions and Assemblies
#
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
#  Last file update:  Dec 11, 2021  13:55
#
[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

function New-Window {
    param (
        $XamlFile,
        [Switch]$NoSnackbar
    )
        
    try {
        [xml]$Xaml = (Get-content $XamlFile)
        $Reader = New-Object System.Xml.XmlNodeReader $Xaml
        $Window = [Windows.Markup.XamlReader]::Load($Reader)
        
        $Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }
        # Objects that have to be declared before the window launches (will run in the same dispatcher thread as the window)
        if (!$NoSnackbar){
            $Script:MessageQueue =   [MaterialDesignThemes.Wpf.SnackbarMessageQueue]::new()
            $Script:MessageQueue.DiscardDuplicates = $true
        }
        
        return $Window
    } 
    catch {
        Write-Error "Error building Xaml data or loading window data.`n$_"
        exit
    }
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
        Write-Error "Error in Get-SaveFilePath common function`n$_"
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
        Write-Error "Error in Get-OpenFilePath common function`n$_"
    }
} 

function Open-File {
    param(
        $Path,
        $FileType
    )
    try {
        if (!(Test-Path $Path)) {
            Write-error "File $Path not found"
            return
        }
        switch ($FileType) {
            "xml"   {
                        [xml]$OutputFile = (Get-content $Path)
                    }
            "csv"   {
                $OutputFile = (Import-Csv -Path $Path -Encoding UTF8)
                    }
            default {
                        $OutputFile = (Get-content $Path)
                    }
        }
        return $OutputFile
    } catch {
        Write-error "Error in Open-File common function`n$_"
    }
}

function Add-ItemToUIControl {
    param(
        [System.Management.Automation.PSObject[]]$UIControl,
        [System.Management.Automation.PSObject[]]$ItemToAdd,
        [Switch]$Clear
    )
    try{
        if ($Clear){
            foreach($Control in $UIControl) {
                $Control.Items.Clear()
            }
        }
        else {
            foreach($Control in $UIControl) {
                foreach ($Item in $ItemToAdd) {
                    [void] $Control.Items.Add($Item)
                }
            }
        }
    }
    catch{
        Write-Error "Error in Add-ItemToUIControl common function`n$_"
    }
}

function Set-OutlinedProperty {
    param (
        [System.Management.Automation.PSObject[]]$InputObject,
        $Padding,                 # "2"
        $SetFloatingOffset,       # "-15, 0"
        $SetFloatingScale,        # "1.2"
        $FontSize
    )
    try {
        foreach($UIObject in $InputObject) {
            if($Padding){
                $UIObject.padding = [System.Windows.Thickness]::new($Padding)
            }
            if($SetFloatingOffset){
                [MaterialDesignThemes.Wpf.HintAssist]::SetFloatingOffset( $UIObject, $SetFloatingOffset)
            }
            if($SetFloatingScale){
                [MaterialDesignThemes.Wpf.HintAssist]::SetFloatingScale( $UIObject, $SetFloatingScale)
            }
            if($FontSize){
                $UIObject.FontSize = $FontSize
            }
            $UIObject.VerticalContentAlignment = "Center"
            $UIObject.Opacity = "0.75"
        }
    }
    catch {
        Write-Error "Error in Set-OutlinedProperty common function`n$_"
    }
}
