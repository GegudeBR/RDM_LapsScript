param($ComputerName)

if($ComputerName -eq $null) {
	$ComputerName = Read-Host "Computer name"
}

$ComputerName | Out-File -FilePath C:\temp\LAPS\in.laps
$Password = ""

if (!(Test-Path "C:\temp\LAPS\out.laps"))
{
   Set-Content -Path "C:\temp\LAPS\out.laps"
}

$FileWatcher = New-Object System.IO.FileSystemWatcher
$FileWatcher.Path = "C:\temp\LAPS"
$FileWatcher.Filter = "out.laps"
$FileWatcher.EnableRaisingEvents = $true


$Action = {
	$Path = $Event.SourceEventArgs.FullPath
    $Password = Get-Content $Path
	Write-Host $Password
    }  

$Changed = Register-ObjectEvent $FileWatcher "Changed" -Action $Action

while(1) {
    if ($Password -ne "") {
        break
    }
}