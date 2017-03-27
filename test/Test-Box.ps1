param($boxpath, $hypervisor, $boxname, [switch]$checkpatches, [switch]$HaltAtEnd, [switch]$showstdio)

$reporoot = Resolve-Path "$PSScriptRoot\.."
$boxpath = $boxpath.Replace("\", "/")
$DirectoryBeforeTest = Get-Location

function Write-Text {
    param([Parameter(ValueFromPipeline=$true, 
    ValueFromPipelineByPropertyName=$true,Position = 0 )][string]$value)

    if($showstdio) { $value | Write-Host}

}

$result = Describe "Test box settings" {
    BeforeAll {
        Write-Text "Please wait loading box..."
        #Setup vagrant folder structure and copy in vagrant file.
        Remove-item "$reporoot\boxtest\$boxname" -Force -Recurse -ErrorAction SilentlyContinue
        New-item "$reporoot\boxtest" -ItemType Directory -ErrorAction SilentlyContinue
        New-item "$reporoot\boxtest\$boxname" -ItemType Directory -ErrorAction SilentlyContinue
        New-item "$reporoot\boxtest\$boxname\vagrant" -ItemType Directory
        #New-item "$reporoot\boxtest\$boxname\vagrantboxdata" -ItemType Directory
        Copy-item "$reporoot\Test\Vagrantfile" "$reporoot\boxtest\$boxname\vagrant\Vagrantfile"

        #Setup vagrant root to test folder. This is so tests dont impact installed vagrant environment.
        #$env:VAGRANT_HOME = "$reporoot\boxtest\$boxname\vagrantboxdata"

        #Import testbox
        &vagrant box remove sutbox -f | Write-Text
        &vagrant box add sutbox $boxpath | Write-Text

        #Start VM
        Set-Location "$reporoot\boxtest\$boxname\vagrant"

        if($hypervisor -eq "virtualbox") {
            &vagrant up --provider virtualbox | Write-Text
        }
        
        if($hypervisor -eq "vmware") {
            &vagrant up --provider vmware_workstation | Write-Text
        }
    }

    AfterAll {
        if($HaltAtEnd) { Read-Host "Press enter key to destroy environment"}
        
        Write-Text "Please wait destroying test environment..."
        #Destory VM and remove box from vagrant.
        &vagrant destroy -f | Write-Text

        #Nuke test folder so nothing is left over.
        Set-Location $DirectoryBeforeTest
        Remove-item "$reporoot\$boxname\boxtest" -Force -Recurse -ErrorAction SilentlyContinue    
    }

    It "RDP Port accessable" {
        #Getting mapped port from vagrant, this can change dynamically which is why we need to get it from here.
        
        $vagrantdata = &vagrant port
        $port = [int]::Parse([regex]::Match($vagrantdata, ".*3389 \(guest\) => ([0-9]{1,7}) \(host\).*").captures.groups[1].value)
        Write-Text "Bound Local Host Port: $port"

        #Testing if a TCP connection can be made.
        (Test-NetConnection -ComputerName "127.0.0.1" -Port $port).TcpTestSucceeded | should be $true
    }

    It "Can connect via WinRM" {
        $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "write-host testing"))
        $vagrantdata | Write-Text

        $vagrantdata | Should BeLike "*testing*"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has vagrant account in local admin" {
        $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "net user vagrant"))
        $vagrantdata | Write-Text

        $vagrantdata | Should BeLike "*Administrators*"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has Windows Update set to Manual" {
        $auoptions = [string]::Join("`n", (&vagrant powershell -c "`$x = 'AUOptions:' + (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update').AUOptions;`$x"))
        $auoptions | Write-Text
        $austate = [string]::Join("`n", (&vagrant powershell -c "`$x = 'AUState:' + (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update').AUState;`$x"))
        $austate | Write-Text

        $auoptions | Should BeLike "*AUOptions:1*"
        $auoptions | Should BeLike "*executed succesfully with output code 0.*"

        $austate | Should BeLike "*AUState:7*"
        $austate | Should BeLike "*executed succesfully with output code 0.*"
    }

<#
    if($checkpatches) {
        It "Has no outstanding Windows Updates" {
            #Check for outstanding windows updates. If there are some this fails.
        }
    }

    #>

    It "Has Chocolatey Installed" {
        $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "&choco config"))
        $vagrantdata | Write-Text

        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has no hiberfil.sys file" {
        $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "Test-Path c:\\hiberfil.sys"))
        $vagrantdata | Write-Text

        $vagrantdata | Should BeLike "*False*"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    if($checkpatches)
    {
        It "Has Powershell 5+ installed" {
            $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "`$PSVersionTable.PSVersion.Major -ge 5"))
            $vagrantdata | Write-Text

            $vagrantdata | Should BeLike "*True*"
            $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
        }
    }

    It "Has Powershell execution policy set to unrestricted" {
        $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "Get-ExecutionPolicy -Scope LocalMachine"))
        $vagrantdata | Write-Text

        $vagrantdata | Should BeLike "*Unrestricted*"
        $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"
    }

    It "Has VMTools installed" {

        if($hypervisor -eq "virtualbox") 
        {
            $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "Test-Path 'C:\\Program Files\\Oracle\\VirtualBox Guest Additions\\VBoxControl.exe'"))
            $vagrantdata | Write-Text

            $vagrantdata | Should BeLike "*True*"
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
            $vagrantdata = [string]::Join("`n", (&vagrant powershell -c "Test-Path '$p'"))
            $vagrantdata | Write-Text

            $vagrantdata | Should BeLike "*False*"
            $vagrantdata | Should BeLike "*executed succesfully with output code 0.*"

        }
    }

    <#It "testing fail" {
        $false | should be $true
    }#>
}

$result | Format-List