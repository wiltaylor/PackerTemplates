@netsh advfirewall firewall set rule name="WinRM-HTTP" new action=allow
@netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=allow
@del c:\postunattend.xml
@del c:\shutdown.cmd