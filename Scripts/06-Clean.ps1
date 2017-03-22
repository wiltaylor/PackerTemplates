if($env:cleanvm -eq "true") {
    Write-Host "Cleaning up junk"

    Remove-item c:\vmtools.ps1
    Remove-Item "c:\rollup.msu" -ErrorAction SilentlyContinue
    Remove-Item "c:\wufix.msu" -ErrorAction SilentlyContinue
    Remove-Item "c:\sp.exe" -ErrorAction SilentlyContinue
    Remove-Item "c:\config.psd1" -ErrorAction SilentlyContinue

    Write-Host "Cleaning SxS..."
    if($env:nodismclean -eq "false") {
        &Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase | out-null
    }

    $cleanfolders = @(
        "$env:localappdata\Nuget"
        "$env:localappdata\temp\*"
        "$env:windir\logs"
        "$env:windir\panther"
        "$env:windir\temp\*"
        "$env:windir\winsxs\manifestcache"
        "c:\servicepack"
    ) 

    Write-Host "Cleaning folders..."
    if($env:nofolderclean -eq "false") {
        try{
            foreach($folder in $cleanfolders)
            {
                if(Test-Path $folder) 
                {
                    Write-Host "Removing $folder"

                        Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue| Out-Null

                }
            }
        } catch {
            #do nothing. This is to stop exceptions from failing process.
        }
    }
    Write-Host "Degraging disk"
    &Defrag.exe c: /H

    Write-Host "Zeroing out free space..."
    &c:\\sdelete.exe -accepteula -z c:
    Remove-Item "c:\sdelete" -ErrorAction SilentlyContinue | Out-Null
}