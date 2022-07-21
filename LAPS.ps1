param($ComputerName)

if($ComputerName -eq $null) {
	$ComputerName = Read-Host "Computer name"
}

$Password = ""
$ComputerName | Out-File -FilePath C:\temp\LAPS\in.laps

if (!(Test-Path "C:\temp\LAPS\out.laps")) {
    Set-Content -Path "C:\temp\LAPS\out.laps"
}

$Folder = "C:\temp\LAPS\"
$Filter = "out.laps"
$FileWatcher = New-Object System.IO.FileSystemWatcher $Folder, $Filter -Property @{
    EnableRaisingEvents = $true
}

$Action = {
    $Path = $Event.SourceEventArgs.FullPath
    $Password = Get-Content $Path
    Write-Host $Password
}  

$Changed = Register-ObjectEvent $FileWatcher "Changed" -Action $Action -SourceIdentifier LapsPS

for ($i = 0; $i -le 20; $i++) {
    if ($Password -ne "") {
        break
    }
    Start-Sleep -Milliseconds 300
}
Unregister-Event -SourceIdentifier LapsPS