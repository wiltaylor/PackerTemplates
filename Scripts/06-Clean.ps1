if($env:cleanvm -eq "true") {
    Write-Host "Cleaning up junk"

    Remove-item "c:\vmtools.ps1" -ErrorAction SilentlyContinue
    Remove-Item "c:\rollup.*" -ErrorAction SilentlyContinue
    Remove-Item "c:\wufix.*" -ErrorAction SilentlyContinue
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
                    Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {
            #do nothing. This is to stop exceptions from failing process.
        }
    }
    Write-Host "Defraging disk"
    &Defrag.exe c: /H | Out-Null

    Write-Host "Zeroing out free space..."
    $FilePath="c:\zero.tmp"
    $Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
    $ArraySize= 64kb
    $SpaceToLeave= $Volume.Size * 0.05
    $FileSize= $Volume.FreeSpace - $SpacetoLeave
    $ZeroArray= new-object byte[]($ArraySize)

    $Stream= [io.File]::OpenWrite($FilePath)
    try {
    $CurFileSize = 0
        while($CurFileSize -lt $FileSize) {
            $Stream.Write($ZeroArray,0, $ZeroArray.Length)
            $CurFileSize +=$ZeroArray.Length

            $percent = [Math]::Round($CurFileSize / $FileSize * 100)

            Write-Host "Cleaning space [$percent%]"
        }
    }
    finally {
        if($Stream) {
            $Stream.Close()
        }
    }

    Write-Host "Finish Free space clean..."
    Remove-Item $FilePath -Force  

    Start-Sleep 30
}