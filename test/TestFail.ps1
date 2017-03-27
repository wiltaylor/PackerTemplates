Describe 'A test that fails' {
    It 'should fail' {
        $false | should be $true
    }
}