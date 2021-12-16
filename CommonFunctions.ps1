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
#  Last file update:  Dec 16, 2021  21:13
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

function Set-OutlinedProperty {
    param (
        [System.Management.Automation.PSObject[]]$InputObject,
        $Padding,                 # "2"
        $FloatingOffset,       # "-15, 0"
        $FloatingScale,        # "1.2"
        $Opacity,                 # "0.75"
        $FontSize
    )
    try {
        foreach($UIObject in $InputObject) {
            if($Padding){
                $UIObject.padding = [System.Windows.Thickness]::new($Padding)
            }
            if($FloatingOffset){
                [MaterialDesignThemes.Wpf.HintAssist]::SetFloatingOffset( $UIObject, $FloatingOffset)
            }
            if($FloatingScale){
                [MaterialDesignThemes.Wpf.HintAssist]::SetFloatingScale( $UIObject, $FloatingScale)
            }
            if($FontSize){
                $UIObject.FontSize = $FontSize
            }
            if($Opacity){
                $UIObject.Opacity = $Opacity
            }
            $UIObject.VerticalContentAlignment = "Center"
            
        }
    }
    catch {
        Write-Error "Error in Set-OutlinedProperty common function`n$_"
    }
}


function Set-ValidationError {
    param (
        $ErrorText,
        [switch]$ClearInvalid
    )
    #https://coderedirect.com/questions/546371/setting-validation-error-template-from-code-in-wpf
    # !!! you must put  Text="{Binding txt}" in the textbox xaml code.
    
    $ClassProperty = 
        switch($this.GetType().name) {
            "TextBox" {[System.Windows.Controls.TextBox]::TextProperty}
            "TimePicker" {[MaterialDesignThemes.Wpf.TimePicker]::TextProperty}
    }
    [System.Windows.Data.BindingExpression]$bindingExpression =  [System.Windows.Data.BindingOperations]::GetBindingExpression( $this, $ClassProperty)
    [System.Windows.Data.BindingExpressionBase]$bindingExpressionBase = [System.Windows.Data.BindingOperations]::GetBindingExpressionBase($this, $ClassProperty);
    [System.Windows.Controls.ValidationError]$validationError = [System.Windows.Controls.ValidationError]::new([System.Windows.Controls.ExceptionValidationRule]::New(),$bindingExpression)
    <#
    #This option will put the error message on either Absolute,AbsolutPoint,Bottom,Center,Custom,Left,Right,Top,MousePoint,Mouse,Relative,RelativePoint. Default is bottom.
    [MaterialDesignThemes.Wpf.ValidationAssist]::SetUsePopup($TB,$true)
    [MaterialDesignThemes.Wpf.ValidationAssist]::SetPopupPlacement($TB,[System.Windows.Controls.Primitives.PlacementMode]::Left)
    #>
    if ($ClearInvalid){
        [System.Windows.Controls.Validation]::ClearInvalid($bindingExpressionBase)
    }
    else{
        $validationError.ErrorContent = $ErrorText
        [System.Windows.Controls.Validation]::MarkInvalid($bindingExpressionBase,$validationError)
    }
}

function Test-RequiredField {
    param (
        $ErrorText = "This field is mandatory"
    )
    if (!$this.Text) {
        Set-ValidationError -ErrorText $ErrorText
    }
    else {
        Set-ValidationError -ClearInvalid
    }
}