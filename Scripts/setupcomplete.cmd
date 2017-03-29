@echo off
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=allow
netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=allow
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUState /t REG_DWORD /d 7
del c:\postunattend.xml
del c:\shutdown.cmd

powershell -executionpolicy bypass -noninteractive -noprofile -file c:\windows\fixnetwork.ps1