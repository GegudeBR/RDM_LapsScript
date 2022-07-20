param (
    [switch]$Unregister
);
Import-Module AdmPwd.PS

$FileWatcher = New-Object System.IO.FileSystemWatcher
$FileWatcher.Path = "L:\LAPS"
$FileWatcher.Filter = "in.laps"
$FileWatcher.EnableRaisingEvents = $true

$Fetching = $false

$Action = {
    if($Fetching) {
        Return
    }
    $Fetching = $true
	$Path = $Event.SourceEventArgs.FullPath 
    Start-Sleep 0.3
	$ComputerName = Get-Content $Path
    Write-Host "$(Get-Date): Request for $ComputerName"
	$Password = Get-AdmPwdPassword -ComputerName $ComputerName | select -ExpandProperty Password
	Set-Content -Path L:\LAPS\out.laps -Value $Password
    $Fetching = $false
    }  

if($Unregister) {
  try {
    Get-EventSubscriber -SourceIdentifier LapsPS | Unregister-Event
  } catch {
    Write-Host Event not registered.
  }
} else { 
  $Changed = Register-ObjectEvent $FileWatcher "Changed" -Action $Action -SourceIdentifier LapsPS
}

