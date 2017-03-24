param($boxname, $hypervisor)

$reporoot = Resolve-Path "$PSScriptRoot\.."

Describe "Test box settings" 
{
    BeforeAll {
        #Create temp vagrant folder.

        #Import testbox

        #vagrant up
    }

    AfterAll {
        #vagrant destroy

        #Remove box

        #Clean up temp folders.
    
    }

    It "WinRM Port is accessable" {
        #Get port from vagrant for WinRM
        #Use Test-NetConnection on port.
    }

    It "RDP Port accessable" {
        #Get port from vagrant for RDP
        #Use Test-NetConnection on port.
    }

    It "Can connect via WinRM" {
        #Get vagrant to send write-host "Testing Winrm" and that it is returned
    }

    It "Has vagrant account in local admin" {
        #Check that vagrant is in local admin group
    }

    It "Has Windows Update set to Manual" {
        #Check Windows update is set to manual via windows update api/registry keys.
    }

    It "Has no outstanding Windows Updates" {
        #Check for outstanding windows updates. If there are some this fails.
    }

    It "Has Chocolatey Installed" {
        #make sure can run choco -h. Make sure error isn't returned.
    }

    It "Has no hiberfil.sys file" {
        #Make sure hiberfil.sys doesn't exist.
    }

    It "Has Hibernate off" {
        #Make sure hibernate is switched off
    }

    It "Has Powershell 5+ installed" {
        #Check powershell version
    }

    It "Has Powershell execution policy set to unrestricted" {
        #Check powershell execution policy set to unrestricted
    }

    It "Has VMTools installed" {
        #check if vmtools are installed, use $hypervisor to determine which one to check.
    }

    It "Has Provisioning scripts removed from root of filesystem" {
        #Check provisioning files are gone.
    }
}