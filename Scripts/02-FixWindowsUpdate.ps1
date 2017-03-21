$config = [io.file]::ReadAllText("c:\config.psd1") | Invoke-Expression

if($config.WindowsUpdateFix -ne $null -and $env:patchvm -eq "true") 
{
    Write-Host "Package found! Downloading..."
    (New-Object System.Net.WebClient).DownloadFile($config.WindowsUpdateFix, "c:\wufix.msu")

    Write-Host "Package downloaded...Now installing..."
    &wusa.exe c:\wufix.msu /quiet /norestart /log:c:\wufix.log | out-null
    Write-Host "Package installation completed...restarting..."
}