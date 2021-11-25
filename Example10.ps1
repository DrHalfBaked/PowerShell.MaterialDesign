###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example10: DataTables
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
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example10.xaml")
    $Reader = New-Object System.Xml.XmlNodeReader $Xaml
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} 
catch {
    Write-Error "Error building Xaml data.`n$_"
    exit
}

$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }


[xml]$DialogHostXaml = @"

<UserControl 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:md="http://materialdesigninxaml.net/winfx/xaml/themes" 
    Padding="15">
    <StackPanel>
        <TextBlock Name="gogo" />
        <TextBox Name="Username" />
        <TextBlock Text="Password" />
        <PasswordBox />

        <TextBlock Text="No account?" Margin="0,20,0,0"/>
        <Button Content="Click here to create a new account" Margin="0,0,0,20"/>

        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition />
                <ColumnDefinition />
            </Grid.ColumnDefinitions>
            <Button Content="Login" Command="{x:Static md:DialogHost.CloseDialogCommand}" CommandParameter="Login" Margin="0,0,20,0"/>
            <Button Content="Cancel" Command="{x:Static md:DialogHost.CloseDialogCommand}" CommandParameter="Cancel" Grid.Column="1" />
        </Grid>
    </StackPanel>
</UserControl>

"@

$DialogHostReader = New-Object System.Xml.XmlNodeReader $DialogHostXaml
$DialogHostWindow = [Windows.Markup.XamlReader]::Load($DialogHostReader)
$DialogHostXaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $DialogHostWindow.FindName($_.Name) -Scope Script }
#$DialogHostXaml.SelectNodes("//*[@Name]") | ForEach-Object { Remove-Variable -Name ($_.Name)}

$Username.Text = "gogogo"
$Btn1.Add_Click({[MaterialDesignThemes.Wpf.DialogHost]::Show($DialogHostWindow)})
$Btn2.Add_Click({[MaterialDesignThemes.Wpf.DialogHost]::Show($Notification)})
$Window.ShowDialog() | out-null