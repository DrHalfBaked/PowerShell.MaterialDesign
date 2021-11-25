###########
#  Learn how to build Material Design based PowerShell apps
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
[System.Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[System.Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[System.Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

try {
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example3.xaml")
} catch {
    Write-Error "Error importing Xaml file.`n$_"
    exit
}

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)
$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }


$MessageQueue =   [MaterialDesignThemes.Wpf.SnackbarMessageQueue]::new()
$MessageQueue.DiscardDuplicates = $true

Function New-Snackbar {
    param (
        $Snackbar,
        $Text,
        $ButtonCaption
    )
    if ($ButtonCaption) {       
        $MessageQueue.Enqueue($Text, $ButtonCaption, {$null}, $null, $false, $false, [TimeSpan]::FromHours( 9999 ))
        # 7 Arguments of Enqueue: content, actionContent, actionHandler, actionArgument, promote, neverConsiderToBeDuplicate, durationOverride
    }
    else {
        $MessageQueue.Enqueue($Text, $null, $null, $null, $false, $false, $null)
    }
    $Snackbar.MessageQueue = $MessageQueue
}

$Btn_ShowSnkBarNoHide.Add_Click({New-Snackbar -Snackbar $Snackbar1 -Text $TxtBox_SnkBarContent.Text -ButtonCaption "OK"})
$Btn_ShowSnkBarAutoHide.Add_Click({New-Snackbar -Snackbar $Snackbar1 -Text $TxtBox_SnkBarContent.Text})

$Window.ShowDialog() | out-null