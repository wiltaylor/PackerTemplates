$config = [io.file]::ReadAllText("c:\config.psd1") | Invoke-Expression

if($config.RollUp -ne $null -and $env:patchvm -eq "true") 
{
    Write-Host "Package found! Downloading..."
    (New-Object System.Net.WebClient).DownloadFile($config.RollUp, "c:\rollup.msu")

    Write-Host "Package downloaded...Now installing..."
    &wusa.exe c:\rollup.msu /quiet /norestart /log:c:\rollup.log | out-null
    Write-Host "Package installation completed...restarting..."
}