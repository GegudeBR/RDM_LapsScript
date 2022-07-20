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

$Changed = Register-ObjectEvent $FileWatcher "Changed" -Action $Action

try {
  while(1){
  }
} finally {
  Unregister-Event $Changed
}


