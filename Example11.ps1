###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example11: ListView with a GridView
#  --------------------
#  Avi Coren (c)
#  Blog     - https://www.materialdesignps.com
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example11.xaml"


[System.Collections.ArrayList]$items = @()
			
$obj = New-Object -TypeName PSObject -Property @{ 
    "Name"    = "John Doe"
    "Age"     = 42
    "Mail" = "john@doe-family.com" 
}

[void]$items.Add($obj)

$obj = New-Object -TypeName PSObject -Property @{ 
    "Name"    = "Jane Doe"
    "Age"     = 39
    "Mail" = "jane@doe-family.com" 
}

[void]$items.Add($obj)

$obj = New-Object -TypeName PSObject -Property @{ 
    "Name"    = "Sammy Doe"
    "Age"     = 7
    "Mail" = "sammy.doe@gmail.com" 
}

[void]$items.Add($obj)

$lvUsers.ItemsSource = $items

$async = $Window.Dispatcher.InvokeAsync( {
    $Window.ShowDialog()
})

$async.Wait() | Out-Null  