# Import
param (
    [switch]$Unregister
);
Import-Module AdmPwd.PS

# UI Change
$Title = "RDM LAPS Server"
$host.UI.RawUI.WindowTitle = $Title

$WindowSize = $Host.UI.RawUI.WindowSize
$WindowSize.Width  = [Math]::Min(50, $Host.UI.RawUI.BufferSize.Width)
$WindowSize.Height = 10

try{
  $Host.UI.RawUI.WindowSize = $WindowSize
}
catch [System.Management.Automation.SetValueInvocationException] {
  $Maxvalue = ($_.Exception.Message |Select-String "\d+").Matches[0].Value
  $WindowSize.Height = $Maxvalue
  $Host.UI.RawUI.WindowSize = $WindowSize
}


# File Watcher
$Folder = "L:\LAPS"
$LogPath = $Folder + "\laps.log"
$OutPath = $Folder + "\out.laps"
$Filter = "in.laps"
$FileWatcher = New-Object System.IO.FileSystemWatcher $Folder, $Filter -Property @{
  EnableRaisingEvents = $true
}

# File Watcher Event Handlers
$Action = {
  $FileWatcher.EnableRaisingEvents = $false
	$Path = $Event.SourceEventArgs.FullPath 
  Start-Sleep -Milliseconds 100
	$ComputerName = Get-Content $Path
  Add-Content -Path $LogPath -Value "$(Get-Date): Request for $ComputerName"
	$Password = Get-AdmPwdPassword -ComputerName $ComputerName | select -ExpandProperty Password
	Set-Content -Path $OutPath -Value $Password
  $FileWatcher.EnableRaisingEvents = $true
  }  



if ($Unregister) {
  try {
    Get-EventSubscriber -SourceIdentifier LapsPS | Unregister-Event
  } catch {
    Write-Host Event not registered.
  }
}
else { 
  $Changed = Register-ObjectEvent $FileWatcher "Changed" -Action $Action -SourceIdentifier LapsPS
}
  



