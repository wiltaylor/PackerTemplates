Start-Process -FilePath "a:\vmtools.exe" -Wait -ArgumentList "-p `"/s /v\`"/qr REBOOT=R\`"`""
start-sleep -Seconds 60