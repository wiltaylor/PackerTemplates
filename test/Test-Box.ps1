param($boxpath, $hypervisor, $checkpatches)

$reporoot = Resolve-Path "$PSScriptRoot\.."
$boxpath = $boxpath.Replace("\", "/")
$DirectoryBeforeTest = Get-Location
Describe "Test box settings" 
{
    BeforeAll {
        #Setup vagrant folder structure and copy in vagrant file.
        Remove-item "$reporoot\boxtest" -Force -Recurse -ErrorAction SilentlyContinue
        New-item "$reporoot\boxtest" -ItemType Directory
        New-item "$reporoot\boxtest\vagrant" -ItemType Directory
        New-item "$reporoot\boxtest\vagrantboxdata" -ItemType Directory
        Copy-item "$reporoot\Test\Vagrantfile" "$reporoot\boxtest\vagrant\Vagrantfile"

        #Setup vagrant root to test folder. This is so tests dont impact installed vagrant environment.
        $env:VAGRANT_HOME = "$reporoot\boxtest\vagrantboxdata"

        #Import testbox
        &vagrant box add sutbox $boxpath

        #Start VM
        Set-Location "$reporoot\boxtest\vagrant"
        &vagrant up
    }

    AfterAll {
        #Destory VM and remove box from vagrant.
        &vagrant destroy -f
        &vagrant box remove sutbox -f -all

        #Nuke test folder so nothing is left over.
        Set-Location $DirectoryBeforeTest
        Remove-item "$reporoot\boxtest" -Force -Recurse -ErrorAction SilentlyContinue    
    }

    It "RDP Port accessable" {
        #Getting mapped port from vagrant, this can change dynamically which is why we need to get it from here.
        $vagrantdata = &vagrant port
        $port = [int]::Parse([regex]::Match($vagrantdata, ".*3389 \(guest\) => ([0-9]{1,7}) \(host\).*").captures.groups[1].value)

        #Testing if a TCP connection can be made.
        (Test-NetConnection -ComputerName "127.0.0.1" -Port $port).TcpTestSucceeded | should be $true
    }

    It "Can connect via WinRM" {
        $vagrantdata = &vagrant powershell -c "write-host testing"

        $vagrantdata | Should BeLike "*testing*"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has vagrant account in local admin" {
        $vagrantdata = &vagrant powershell -c "net user vagrant"

        $vagrantdata | Should BeLike "Administrators"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has Windows Update set to Manual" {
        $auoptions = &vagrant powershell -c "`$x = 'AUOptions:' + (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update').AUOptions;`$x"
        $austate = &vagrant powershell -c "`$x = 'AUState:' + (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update').AUState;`$x"

        $auoptions | Should BeLike "AUOptions:1"
        $auoptions | Should BeLike "*executed succesfully with output code 0.*"

        $austate | Should BeLike "AUState:7"
        $austate | Should BeLike "*executed succesfully with output code 0.*"
    }

    if($checkpatches) {
        It "Has no outstanding Windows Updates" {
            #Check for outstanding windows updates. If there are some this fails.
        }
    }

    It "Has Chocolatey Installed" {
        $vagrantdata = &vagrant powershell -c "&choco config"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has no hiberfil.sys file" {
        $vagrantdata = &vagrant powershell -c "Test-Path c:\\hiberfil.sys"

        $vagrantdata | Should BeLike "True"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    if($checkpatches)
    {
        It "Has Powershell 5+ installed" {
            $vagrantdata = &vagrant powershell -c "`$PSVersionTable.PSVersion.Major -ge 5"

            $vagrantdata | Should BeLike "True"
            $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
        }
    }

    It "Has Powershell execution policy set to unrestricted" {
        $vagrantdata = &vagrant powershell -c "Get-ExecutionPolicy -Scope LocalMachine"

        $vagrantdata | Should BeLike "Unrestricted"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has VMTools installed" {

        if($hypervisor -eq "virtualbox") 
        {
            $vagrantdata = &vagrant powershell -c "Test-Path 'C:\\Program Files\\Oracle\\VirtualBox Guest Additions\\VBoxControl.exe'"

            $vagrantdata | Should BeLike "True"
            $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"

        }
    }

    It "Has Provisioning scripts removed from root of filesystem" {
        $cleanobjects = @(
            "c:\\vmtools.ps1" #Need to use \\ instead of \ for vagrant.
            "c:\\setupcomplete.cmd"
            "c:\\postunattend.xml"
            "c:\\config.psd1"
            "c:\\shutdown.cmd"
            "c:\\servicepack"
            "c:\\zero.tmp"
            "c:\\rollup.msu"
            "c:\\wufix.msu"
            "c:\\sp.exe"
        )

        foreach($p in $cleanobjects) {
            $vagrantdata = &vagrant powershell -c "Test-Path '$p'"

            $vagrantdata | Should BeLike "False"
            $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"

        }
    }
}