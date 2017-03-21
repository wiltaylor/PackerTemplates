$config = [io.file]::ReadAllText("c:\config.psd1") | Invoke-Expression
Write-Host "Cleaning up junk"

Remove-item c:\vmtools.ps1
Remove-Item "c:\rollup.msu" -ErrorAction SilentlyContinue
Remove-Item "c:\wufix.msu" -ErrorAction SilentlyContinue
Remove-Item "c:\sp.exe" -ErrorAction SilentlyContinue
Remove-Item "c:\config.psd1" -ErrorAction SilentlyContinue

Write-Host "Cleaning SxS..."
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase | out-null

$cleanfolders = @(
    "$env:localappdata\Nuget",
    "$env:localappdata\temp\*",
    "$env:windir\logs",
    "$env:windir\panther",
    "$env:windir\temp\*",
    "$env:windir\winsxs\manifestcache",
    "c:\servicepack"
) 

foreach($folder in $cleanfolders)
{
    if(Test-Path $folder) 
    {
        Write-Host "Removing $folder"
        Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue| Out-Null
    }
}

Write-Host "Running Defrag"
Defrag.exe c: /H

Write-Host "Zeroing out drive"
cmd.exe /c powershell.exe -executionpolicy bypass -noprofile -noninteractive -file c:\zero.ps1 | out-null

Write-Host "Blocking WinRM via Firewall."
&netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block | out-null
&netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=block | out-null

Write-Host "Syspreping system"
&"C:\windows\system32\sysprep\sysprep.exe" /generalize /oobe /unattend:c:/postunattend.xml /quiet /quit | out-null

Write-Host "All finished...Image ready for shutdown and capture"
