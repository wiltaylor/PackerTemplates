$url = $null
Write-Host "Looking for Windows Update Service Pack."
if($env:guestos -eq "Windows 7 x86") 
{
    $url = "http://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-X86.exe"
}

if($env:guestos -eq "Windows 7 x64")
{
    $url = "http://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-X64.exe"
}

if($env:guestos -eq "Windows 2008 R2 x64" -or $env:guestos -eq "Windows 2008 R2 Core x64") 
{
    $url = "http://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-X64.exe"
}

if($url -ne $null) 
{
    Write-Host "Package found! Downloading..."
    (New-Object System.Net.WebClient).DownloadFile($url, "c:\sp.exe")

    Write-Host "Extracting Package"
    &c:\sp.exe /x:c:\servicepack | Out-Null

    Write-Host "Installing Package..."
    &c:\servicepack\SPInstall.exe /nodialog /norestart /quiet | Out-Null
    Write-Host "Package installation completed...restarting..."
}