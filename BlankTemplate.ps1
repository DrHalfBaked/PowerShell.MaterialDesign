###########
#  Learn how to build Material Design based PowerShell apps
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
[System.Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[System.Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MahApps.Metro.dll")
[System.Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\System.Windows.Interactivity.dll")
[System.Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[System.Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

try {
    [xml]$Xaml = (Get-content "$PSScriptRoot\BlankTemplate.xaml")   # <-- Change the name of the xaml file to your project file
} catch {
    Write-Error "Error importing Xaml file.`n$_"
    exit
}

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)
$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }



$Window.ShowDialog() | out-null