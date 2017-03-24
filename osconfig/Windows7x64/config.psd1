@{
    
    ServicePackURL = "https://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-X64.exe"
    ServicePackExtractCommand = "c:\sp.exe /x:c:\servicepack"
    ServicePackInstallCommand = "c:\servicepack\SPInstall.exe /nodialog /norestart /quiet"

    WindowsUpdateFix = "https://download.microsoft.com/download/5/D/0/5D0821EB-A92D-4CA2-9020-EC41D56B074F/Windows6.1-KB3020369-x64.msu"

    RollUp = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows6.1-kb4012215-x64_a777b8c251dcd8378ecdafa81aefbe7f9009c72b.msu"

    SkipUpdates =  @("*language pack*")
}