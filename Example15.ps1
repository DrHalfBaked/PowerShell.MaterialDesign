###########
#  Learn how to build Material Design based PowerShell apps
#  --------------------
#  Example15: Spinner and runspace
#  --------------------
#  Avi Coren (c)
#  Blog     - https://www.materialdesignps.com
#  Github   - https://github.com/DrHalfBaked/PowerShell.MaterialDesign
#  LinkedIn - https://www.linkedin.com/in/avi-coren-6647b2105/
#
Get-ChildItem -Path $PSScriptRoot -Filter Common*.PS1 | ForEach-Object {. ($_.FullName)}

$Window = New-Window -XamlFile "$PSScriptRoot\Example15.xaml"
$TextBox_Output.AppendText("Main Runspace ID: $(([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).id)`n")

$Btn_StartJob.Add_Click({ 

    $SpinnerOverlayLayer.Visibility = "Visible"

    $Global:SyncHash = [hashtable]::Synchronized(@{ 
        Window              = $window
        SpinnerOverlayLayer = $SpinnerOverlayLayer
        TextBox_Output      = $TextBox_Output
    })
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ThreadOptions = "ReuseThread"
    $Runspace.ApartmentState = "STA"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash", $SyncHash)
	$Worker = [PowerShell]::Create().AddScript({ 
        $RunspaceID = ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).id
        $SyncHash.Window.Dispatcher.Invoke([action]{$SyncHash.TextBox_Output.AppendText("New Runspace ID: $RunspaceID`n")}, "Normal")
        $Results = [System.Text.StringBuilder]::new()
        foreach ($number in [float]1..10000000) {
            if (($number % 2560583 ) -eq 0) {
                [void]$Results.AppendLine($number)
            }
        }
        if($Results){
            $SyncHash.Window.Dispatcher.Invoke([action]{$SyncHash.TextBox_Output.AppendText($Results.ToString())}, "Normal")
        }
        $SyncHash.Window.Dispatcher.Invoke([action]{ $SyncHash.SpinnerOverlayLayer.Visibility = "Collapsed" }, "Normal")
	})
	$Worker.Runspace = $Runspace

    Register-ObjectEvent -InputObject $Worker -EventName InvocationStateChanged -Action {
        param([System.Management.Automation.PowerShell] $ps)
        $state = $EventArgs.InvocationStateInfo.State
        if ($state -in 'Completed', 'Failed') {
            $ps.EndInvoke($Worker)
            $ps.Runspace.Dispose()
            $ps.Dispose()
            [GC]::Collect()
        }
    } | Out-Null
     
    Register-ObjectEvent -InputObject $Runspace -EventName AvailabilityChanged -Action {
        if ($($EventArgs.RunspaceAvailability) -eq 'Available'){
            $Runspace.Dispose()
            [GC]::Collect()
        }
    } | Out-Null

	$Worker.BeginInvoke()

})

$Window.ShowDialog() | out-null