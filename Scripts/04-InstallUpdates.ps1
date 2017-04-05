
if($env:patchvm -ne $null -and $env:patchvm.ToLower() -eq "true") {
    
    if(-not(Test-Path "c:\psexec.exe")) {
        Write-Host "Downloading psexec.exe..."
        (New-Object System.Net.WebClient).DownloadFile("https://live.sysinternals.com/psexec.exe", "c:\psexec.exe")
    }

    remove-item -Path "c:\patching.txt" -ErrorAction SilentlyContinue

    Write-Host "Starting patch process under system account..."
    $process = Start-Process -FilePath "c:\psexec.exe" -ArgumentList @("-s", "-accepteula", "cmd.exe",  "/c powershell.exe -file c:\InstallUpdates.ps1 > c:\patching.txt") -PassThru

    $line = 0
    while($process.HasExited -eq $false) {
        Start-Sleep -Milliseconds 100
        if(Test-Path "c:\patching.txt") {
            Get-Content "c:\patching.txt" | Select-Object -Skip $line  | ForEach-Object {
                $line += 1
                Write-Host "$_"
            }
        }
    }

    if(Test-Path "c:\patching.txt") {
        Get-Content "c:\patching.txt" | Select-Object -Skip $line  | ForEach-Object {
            $line += 1
            Write-Output "$_"
        }

        Remove-Item "c:\patching.txt" -ErrorAction SilentlyContinue
    }

    Write-Host "Patching completed..."
}
