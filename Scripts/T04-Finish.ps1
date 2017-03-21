
Write-Host "Cleaning up junk"

Remove-item c:\vmtools.ps1
Remove-Item "c:\rollup.msu" -ErrorAction SilentlyContinue
Remove-Item "c:\wufix.msu" -ErrorAction SilentlyContinue
Remove-Item "c:\sp.exe" -ErrorAction SilentlyContinue

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
        try {
              #&Takeown /d Y /R /f $_
              #&Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
              Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue| Out-Null
        }catch {
            $global:error.RemoveAt(0)
        }
    }
}

Defrag.exe c: /H

cmd.exe /c powershell.exe -executionpolicy bypass -noprofile -noninteractive -file c:\zero.ps1 | out-null

Write-Host "Blocking WinRM via Firewall."
&netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block | out-null
&netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=block | out-null

Write-Host "Syspreping system"
&"C:\windows\system32\sysprep\sysprep.exe" /generalize /oobe /unattend:c:/postunattend.xml /quiet /quit | out-null

Write-Host "All finished...Image ready for shutdown and capture"
