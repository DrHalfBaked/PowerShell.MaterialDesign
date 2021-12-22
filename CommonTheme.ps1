###########
#  Learn how to build Material Design based PowerShell apps
# 
#  Common Functions and Assemblies related to Themes
#
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
#  Last file update:  Dec 22, 2021  20:58
#

[System.Collections.ArrayList]$ThemePrimaryColors = [System.Enum]::GetNames([MaterialDesignColors.PrimaryColor])
$ThemePrimaryColors.Sort()
[System.Collections.ArrayList]$ThemeSecondaryColors = [System.Enum]::GetNames([MaterialDesignColors.SecondaryColor])
$ThemeSecondaryColors.Sort()



# Set-Theme                         - Sets the window theme colors and mode
# Get-ThemeMode                     - Returns the given app window theme mode ("Dark" or "Light")
# Get-SystemTheme                   - Will return "Dark" or "Light" based on the current apps theme mode set in windows OS

function  Set-Theme {
    param(
        $Window,
        $PrimaryColor,
        $SecondaryColor,
        [Parameter()]
        [ValidateSet('Dark', 'Light')]
        $ThemeMode
    )
    $Theme = [MaterialDesignThemes.Wpf.ResourceDictionaryExtensions]::GetTheme($Window.Resources)
    if($PrimaryColor) {
        $PrimaryColorObj = [MaterialDesignColors.SwatchHelper]::Lookup[$PrimaryColor]
        [void][MaterialDesignThemes.Wpf.ThemeExtensions]::SetPrimaryColor($Theme, $PrimaryColorObj)
    }
    if($SecondaryColor) {
        $SecondaryColorObj = [MaterialDesignColors.SwatchHelper]::Lookup[$SecondaryColor]
        [void][MaterialDesignThemes.Wpf.ThemeExtensions]::SetSecondaryColor($Theme, $SecondaryColorObj)
    }
    if($ThemeMode) {
        [void][MaterialDesignThemes.Wpf.ThemeExtensions]::SetBaseTheme($Theme, [MaterialDesignThemes.Wpf.Theme]::$ThemeMode)
    }
    [void][MaterialDesignThemes.Wpf.ResourceDictionaryExtensions]::SetTheme($Window.Resources, $Theme)
}

function  Get-ThemeMode {
    param(
        $Window
    )
    $Theme = [MaterialDesignThemes.Wpf.ResourceDictionaryExtensions]::GetTheme($Window.Resources)
    return [MaterialDesignThemes.Wpf.ThemeExtensions]::GetBaseTheme($Theme)
}

function Get-SystemTheme {
    return [MaterialDesignThemes.Wpf.Theme]::GetSystemTheme()
}