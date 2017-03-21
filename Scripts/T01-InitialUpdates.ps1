$url = $null
Write-Host "Looking for roll up package."
if($env:guestos -eq "Windows 7 x86") 
{
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/03/windows6.1-kb4012215-x86_e5918381cef63f171a74418f12143dabe5561a66.msu"
}

if($env:guestos -eq "Windows 7 x64")
{
    $url = "https://download.microsoft.com/download/5/6/0/560504D4-F91A-4DEB-867F-C713F7821374/Windows6.1-KB3172605-x64.msu"
}

if($url -ne $null) 
{
    Write-Host "Package found! Downloading..."
    (New-Object System.Net.WebClient).DownloadFile($url, "c:\rollup.msu")

    Write-Host "Package downloaded...Now installing..."
    &wusa.exe c:\rollup.msu /quiet /norestart /log:c:\rollup.log | out-null
    Write-Host "Package installation completed...restarting..."
}