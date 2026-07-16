
$Date = Get-Date -Format "yyyy-MM-dd-HH-mm"

$Backup = "$PSScriptRoot\backups\$Date"

New-Item -ItemType Directory -Path $Backup -Force | Out-Null

Copy-Item "$PSScriptRoot\*" $Backup -Recurse -Force

Write-Host "Backup created:"
Write-Host $Backup

