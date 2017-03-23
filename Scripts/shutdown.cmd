netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=block
"C:\windows\system32\sysprep\sysprep.exe" /generalize /oobe /unattend:c:\postunattend.xml /quiet /shutdown

mkdir C:\Windows\Setup\Scripts
move c:\SetupComplete.cmd "C:\Windows\Setup\Scripts\SetupComplete.cmd"