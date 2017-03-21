if ($PSVersionTable.PSVersion.Major -le 4)
{
  Write-Host "Installing Newer Version of PowerShell"
  choco install powershell -y
}
else
{
  Write-Host "Not installing PowerShell as it is 5+"
}

if($env:debugbuild -eq "true") 
{
    Start-Process -FilePath "c:\windows\system32\notepad.exe" -Wait
}