@{
    
    ServicePackURL = "http://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-X86.exe"
    ServicePackExtractCommand = "c:\sp.exe /x:c:\servicepack"
    ServicePackInstallCommand = "c:\servicepack\SPInstall.exe /nodialog /norestart /quiet"

    WindowsUpdateFix = "https://download.microsoft.com/download/C/0/8/C0823F43-BFE9-4147-9B0A-35769CBBE6B0/Windows6.1-KB3020369-x86.msu"

    RollUp = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/03/windows6.1-kb4012215-x86_e5918381cef63f171a74418f12143dabe5561a66.msu"

    SkipUpdates =  @("*language pack*")
}