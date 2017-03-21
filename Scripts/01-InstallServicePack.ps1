$config = [io.file]::ReadAllText("c:\config.psd1") | Invoke-Expression

if($config.ServicePackURL -ne $null -and $env:patchvm -eq "true") 
{
    Write-Host "Package found! Downloading..."
    (New-Object System.Net.WebClient).DownloadFile($config.ServicePackURL, "c:\sp.exe")

    Write-Host "Extracting Package"
    &$config.ServicePackExtractCommand | Out-Null

    Write-Host "Installing Package..."
    &$config.ServicePackInstallCommand | Out-Null
    Write-Host "Package installation completed...restarting..."
}