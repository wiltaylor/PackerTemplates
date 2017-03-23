$config = [io.file]::ReadAllText("c:\config.psd1") | Invoke-Expression

if($config.ServicePackURL -ne $null -and $env:patchvm -eq "true") 
{
    Write-Host "Package found! Downloading..."
    (New-Object System.Net.WebClient).DownloadFile($config.ServicePackURL, "c:\sp.exe")

    Write-Host "Extracting Package"
    &c:\sp.exe /x:c:\servicepack | Out-Null

    Write-Host "Installing Package..."
    &c:\servicepack\SPInstall.exe /nodialog /norestart /quiet | Out-Null
    Write-Host "Package installation completed...restarting..."
}