###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example11: Context menu in TextBox
#  --------------------
#  Avi Coren (c)
#  Blog     - https://www.materialdesignps.com
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example11.xaml"

$InitialDirectory   = "$([Environment]::GetFolderPath("MyDocuments"))"
$FileFilter         = "Text files|*.txt|All Files|*.*"

$Btn_OpenFile.add_Click({ On_OpenFile })
$Btn_SaveFile.add_Click({ On_SaveFile })
$TextBox_Editor_CopySelectedToClipboard_MenuItm.add_Click({ On_CopySelectedToClipboard })
$TextBox_Editor_CopyAllToClipboard_MenuItm.add_Click({      On_CopyAllToClipboard      })
$TextBox_Editor_PasteFromClipboard_MenuItm.add_Click({      On_PasteFromClipboard      })
$TextBox_Editor_CutToClipboard_MenuItm.add_Click({          On_CutToClipboard          })
Function On_OpenFile {
    $OpenedFile = Get-OpenFilePath -InitialDirectory $InitialDirectory  -Filter $FileFilter 
    if ($OpenedFile) {
        $TextBox_Editor.Text = Get-content $OpenedFile -Raw
    }
}

Function On_SaveFile {
    $SavePath = Get-SaveFilePath -InitialDirectory $InitialDirectory -Filter $FileFilter 
    if ($SavePath) {
        $TextBox_Editor.Text | Out-File -FilePath $SavePath -Encoding UTF8
    }
}

function On_CopySelectedToClipboard {
    $TextBox_Editor.Copy()
}

function On_CopyAllToClipboard {
    [System.Windows.Clipboard]::SetText($TextBox_Editor.Text)
}

function On_PasteFromClipboard {
    $TextBox_Editor.Paste()
}

function On_CutToClipboard {
    $TextBox_Editor.Cut()
}


$Window.ShowDialog() | out-null