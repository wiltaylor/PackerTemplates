$url = $null
Write-Host "Looking for Windows Update Fix Package."
if($env:guestos -eq "Windows 7 x86") 
{
    $url = "https://download.microsoft.com/download/C/0/8/C0823F43-BFE9-4147-9B0A-35769CBBE6B0/Windows6.1-KB3020369-x86.msu"
}

if($env:guestos -eq "Windows 7 x64")
{
    $url = "https://download.microsoft.com/download/5/D/0/5D0821EB-A92D-4CA2-9020-EC41D56B074F/Windows6.1-KB3020369-x64.msu"
}

if($env:guestos -eq "Windows 2008 R2 x64" -or $env:guestos -eq "Windows 2008 R2 Core x64") 
{
    $url = "https://download.microsoft.com/download/F/D/3/FD3728D5-0D2F-44A6-B7DA-1215CC0C9B75/Windows6.1-KB3020369-x64.msu"
}

if($url -ne $null) 
{
    Write-Host "Package found! Downloading..."
    (New-Object System.Net.WebClient).DownloadFile($url, "c:\wufix.msu")

    Write-Host "Package downloaded...Now installing..."
    &wusa.exe c:\wufix.msu /quiet /norestart /log:c:\wufix.log | out-null
    Write-Host "Package installation completed...restarting..."
}