 param($box, $hypervisor, $boxname)
 
 
 $Parameters = @{
      boxpath = $box
      Hypervisor = $hypervisor
      boxname = $boxname
}

$script = @{
    Path = ".\test\Test-Box.ps1"
    Parameters = $Parameters
}

$result = Invoke-Pester -Script $script -PassThru

if($result.FailedCount -eq 0) {
    Write-Host "Test Ran ok"
    
    exit 0
} else {
    Write-Host "Test Failed"
    exit 500
}