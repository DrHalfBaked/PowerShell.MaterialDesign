###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example1: Hello World
#  --------------------
#  Avi Coren (c)
#  Blog     - https://avicoren.wixsite.com/powershell
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignThemes.Wpf.dll")
[Void][System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\Assembly\MaterialDesignColors.dll")

try {
    [xml]$Xaml = (Get-content "$PSScriptRoot\Example111.xaml")
    $Reader = New-Object System.Xml.XmlNodeReader $Xaml
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} 
catch {
    Write-Error "Error building Xaml data.`n$_"
    exit
}

$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script }

<# 
$DataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$Whatever = [int]0
$DataContext.Add($Whatever)
#$TB.DataContext = $DataContext

$Binding = New-Object System.Windows.Data.Binding
$Binding.Path = "[0]"
$Binding.Source = $DataContext
$Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
[void][System.Windows.Data.BindingOperations]::SetBinding($TB,[System.Windows.Controls.TextBox]::TextProperty, $Binding)
 #>


 $ct = [System.Windows.Controls.ControlTemplate]::new()
 $elemFactory = [System.Windows.FrameworkElementFactory]::new([System.Windows.Controls.DockPanel])
 $elemFactory.SetValue([System.Windows.Controls.DockPanel]::DockProperty,[System.Windows.Controls.Dock]::Top)
 $Tblock = [System.Windows.FrameworkElementFactory]::new([System.Windows.Controls.TextBlock])
 $Tblock.SetValue([System.Windows.Controls.TextBlock]::ForegroundProperty ,[System.Windows.Media.Brushes]::Red )
 $Tblock.SetValue([System.Windows.Controls.TextBlock]::TextProperty ,"*" )
 $Tblock.AppendChild($elemFactory)

 $ct.VisualTree = $Tblock

 #$elemFactory.SetValue([System.Windows.Controls.TextBlock]::ForegroundProperty, [System.Windows.Media.Brushes]::Red)

 #$elemFactory.SetValue([System.Windows.Controls.TextBlock]::TextProperty,"FFFF")


 

 #$TB.Template = $ct

 $TB.add_LostFocus({
    
        #https://coderedirect.com/questions/546371/setting-validation-error-template-from-code-in-wpf
        
        #BindingExpression bindingExpression = BindingOperations.GetBindingExpression(txtBox, TextBox.TextProperty);
        [System.Windows.Data.BindingExpression]$bindingExpression =  [System.Windows.Data.BindingOperations]::GetBindingExpression( $this,  [System.Windows.Controls.TextBox]::TextProperty)

        #BindingExpressionBase bindingExpressionBase = BindingOperations.GetBindingExpressionBase(txtBox, TextBox.TextProperty);
            [System.Windows.Data.BindingExpressionBase]$bindingExpressionBase = [System.Windows.Data.BindingOperations]::GetBindingExpressionBase($this,[System.Windows.Controls.TextBox]::TextProperty);
        #ValidationError validationError = new ValidationError(new ExceptionValidationRule(), bindingExpression);
        [System.Windows.Controls.ValidationError]$validationError = [System.Windows.Controls.ValidationError]::new([System.Windows.Controls.ExceptionValidationRule]::New(),$bindingExpression)
        #Validation.MarkInvalid(bindingExpressionBase, validationError);
        if (!$TB.Text)
    {
        [System.Windows.Controls.Validation]::MarkInvalid($bindingExpressionBase,$validationError)


        #To unset the value you use

        #[System.Windows.Controls.Validation]::ClearInvalid($bindingExpressionBase,$validationError)



    }
    else {
        [System.Windows.Controls.Validation]::ClearInvalid($bindingExpressionBase)
    }

})



$BTN.add_Loaded({

        $button = $this
        [string]$template =
            
            "<ControlTemplate  xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' TargetType=`"Button`">
            <Border BorderBrush=`"Orange`" BorderThickness=`"3`" CornerRadius=`"2`"
            >

            </Border>

            </ControlTemplate>"
        $button.Template = [Windows.Markup.XamlReader]::Parse($template)


})



$Window.ShowDialog() | out-null