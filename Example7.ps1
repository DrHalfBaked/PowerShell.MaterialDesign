###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example7: Navigation Rails with a left drawer and a right popup box
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

try {
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example7.xaml")
    $Reader = New-Object System.Xml.XmlNodeReader $Xaml
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} 
catch {
    Write-Error "Error building Xaml data.`n$_"
    exit
}

$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }


$TglBtn_OpenLeftDrawer.Add_Click( { 
    if ($TglBtn_OpenLeftDrawer.IsChecked -eq $true) {
        $DrawerHost.IsLeftDrawerOpen = $true
        $TglBtn_CloseLeftDrawer.IsChecked = $true
        $TglBtn_OpenLeftDrawer.Visibility="Hidden"
    }
})
$TglBtn_CloseLeftDrawer.Add_Click( {
    if ($TglBtn_CloseLeftDrawer.IsChecked -eq $false) {
        $DrawerHost.IsLeftDrawerOpen = $false
        $TglBtn_OpenLeftDrawer.IsChecked = $false
        $TglBtn_OpenLeftDrawer.Visibility="Visible"
    }
})
# I had to skip the OpenMode="Modal" drawer because DrawerClosing event does not work so the hamburger toggle cannot be change while clicking away. so I'm using OpenMode="Standard"


$Window.ShowDialog() | out-null