#Disable WinRM Firewall Port - Prevent system shutting down early.
&netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=block | out-null
&netsh advfirewall firewall add rule name="WinRM-HTTPS" dir=in localport=5986 protocol=TCP action=block | out-null

#Set powershell execution policy.
Set-ExecutionPolicy Unrestricted -Force

#Enable 32bit policy if on 64bit system
if(Test-Path "c:\Program Files (x86)" -ErrorAction SilentlyContinue)
{
    &C:\Windows\SysWOW64\cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force" | out-null
}

#Setting Network Interfaces to Home Profile
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
foreach($connection in $networkListManager.GetNetworkConnections())
{
    $connection.GetNetwork().SetCategory(1)
}

#Enable WinRM
&winrm quickconfig -q | out-null
&winrm set winrm/config/client/auth '@{Basic="true"}' | out-null
&winrm set winrm/config/service/auth '@{Basic="true"}' | out-null
&winrm set winrm/config/service '@{AllowUnencrypted="true"}' | out-null
&winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}' | out-null
Restart-Service -Name WinRM

#Copy Setup files off floppy
Copy-Item a:\vmtools.ps1 c:\vmtools.ps1
Copy-Item a:\setupcomplete.cmd c:\setupcomplete.cmd
Copy-Item a:\postunattend.xml c:\postunattend.xml
Copy-Item a:\config.psd c:\config.psd1
Copy-Item a:\shutdown.cmd c:\shutdown.cmd

#Getting SDelete - Need to get v1.61 as current version has a hanging glitch.
#(New-Object System.Net.WebClient).DownloadFile("https://web.archive.org/web/20141009082654/http://live.sysinternals.com/sdelete.exe", "c:\sdelete.exe")

#Disable Hybernate file
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name HibernateFileSizePercent -PropertyType DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name HibernateEnabled -PropertyType DWORD -Value 0 -Force

#Prevent vagrant account from expiring
&wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE | out-null

#Disabling auto update
if(-not(Test-Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update')) {
    New-Item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -Force | Out-Null
}
New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -Name AUOptions -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -Name AUState -Value 7 -PropertyType DWORD -Force | Out-Null

#Enable RDP
Write-LogMSG Info 'Enabling RDP'
if(-not(Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server')){
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Force | Out-Null
}
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0 -PropertyType DWORD -Force | Out-Null
&netsh advfirewall firewall set rule name="Remote Desktop (TCP-In)" new action=allow
&netsh advfirewall firewall set rule name="Remote Desktop (TCP-In)" new enable=yes
#Extra rules required for Windows 10.
&netsh advfirewall firewall set rule name="Remote Desktop - User Mode (TCP-In)" new action=allow 
&netsh advfirewall firewall set rule name="Remote Desktop - User Mode (TCP-In)" new enable=yes


Start-Sleep -Seconds 60

#Enable WinRM Firewall Port
&netsh advfirewall firewall set rule name="WinRM-HTTP" new action=allow
&netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=allow