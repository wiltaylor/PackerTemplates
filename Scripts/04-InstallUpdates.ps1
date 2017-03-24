function Install-Updates {
    $config = [io.file]::ReadAllText("c:\config.psd1") | Invoke-Expression

    Write-Host "Searching for updates"
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    $UpdateServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
    $Query = "IsInstalled=0 and Type='Software' and IsHidden=0"
    $Patches = $Searcher.Search($Query).Updates
        
    if($patches -eq $null -or $patches.Count -eq 0 ) 
    { 
        write-host "No new updates exiting..."
        return $false 
    }
    
    Write-Host "Found $($Patches.Count) more patches!"
    $rollups = New-Object -ComObject Microsoft.Update.UpdateColl
    foreach($u in $Patches) 
    {
        if($u.Title.ToLower() -like "cumulative update") {
            $rollups.Add($u)
            Write-Host "Found Cumulative Update: $($u.Title)"
        }
    }

    if($rollups.Count -ne 0) {
        Write-Host "Only installing Cumulative Updates this run... Remaining patches will be installed on reboot."
        $Patches = $rollups
    }

    $UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
    $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
    $patchcount = $patches.Count
    $patchindex = 0
    Write-Host "Checking if updates are already downloaded..."
    foreach($u in $patches) {
        $patchindex++

        $skippatch = $false

        foreach($banned in $config.SkipUpdates){
            if($u.title.ToLower() -like $banned) {
                $skippatch = $true
            }
        }

        if(-not($skippatch)){
            if($u.IsDownloaded){
                Write-Host "Patch [$patchcount\$patchindex] $($u.Title) is already downloaded!"
                $AlreadyDownloaded.Add($u) | out-null
            }else{
                Write-Host "Patch [$patchcount\$patchindex] $($u.Title) needs to be downloaded!"
                $UpdateCollection.Add($u) | out-null
            }
        }
    }
    
    Write-Host "Begin Downloading...This could take awhile."
    $patchcount = $UpdateCollection.Count
    $patchindex = 0
    foreach($u in $UpdateCollection) 
    {
        $patchindex++
        $currentupdate = New-Object -ComObject Microsoft.Update.UpdateColl
        $currentupdate.Add($u) | Out-Null
        
        write-host "Downloading [$patchcount\$patchindex] $($u.Title)"

        try
        {
            $downloader = $Session.CreateUpdateDownloader() 
            $downloader.Updates = $currentupdate
            $downloader.Download() | Out-Null
            Write-Host "Downloaded Ok"
        }catch{
            Write-Host "Failed to download...will retry if stille applicable next reboot."
        }
    }

    foreach($i in $UpdateCollection) {
        if($i.IsDownloaded) {
            $updatesToInstall.Add($i) | Out-Null
        }    
    }
    Write-Host "Accepting EULAs"
    foreach($i in $updatesToInstall) {
        if(-not $i.EulaAccepted) {
            Write-Host "$($i.Title) - Accepted"
            $i.AcceptEula() | out-null
        }
    }

    $installer = $Session.CreateUpdateInstaller()

    Write-Host "Waiting for patch installer to be ready..."
    if($installer.IsBusy) {
        foreach($i in 1..20) { if($installer.IsBusy) { Start-Sleep -Seconds 5 } else { break }}

        if($installer.IsBusy) {
            Write-Host "Patch installer still not ready...rebooting..."
            return $true
        }
    }

    if($installer.RebootRequiredBeforeInstallation) 
    { 
        Write-Host "Pending reboot detected...rebooting..."
        return $true 
    }

    Write-Host "Installing updates...This will take awhile..."
    $patchcount = $updatesToInstall.Count
    $patchindex = 0
    foreach($u in $updatesToInstall)
    {
        $patchindex++
        $currentupdate = New-Object -ComObject Microsoft.Update.UpdateColl
        $currentupdate.Add($u) | Out-Null

        Write-Host "Installing [$patchcount\$patchindex] $($u.Title)"
        try 
        {                
            $installer.AllowSourcePrompts = $false
            $installer.IsForced = $true
            $installer.Updates = $currentupdate
            $installer.install() | Out-Null
            Write-Host "Installed Ok"
        }
        catch
        {
            Write-Host "Failed to install $($u.Title) - Will try again next reboot if still applicable."
        }
    }

    Write-Host "Updates installed...rebooting..."

    return $true

}

if($env:patchvm -eq "true"){
    Install-Updates 
}
