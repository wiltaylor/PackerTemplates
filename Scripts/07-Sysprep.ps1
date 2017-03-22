Write-Host "Blocking WinRM via Firewall."
&netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block | out-null    
&netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=block | out-null 

Write-Host "Syspreping system"
&"C:\windows\system32\sysprep\sysprep.exe" /generalize /oobe /unattend:c:\postunattend.xml /quiet /quit | out-null

Write-Host "All finished...Image ready for shutdown and capture"