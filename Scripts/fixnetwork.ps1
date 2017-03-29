#Setting Network Interfaces to Home Profile
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
foreach($connection in $networkListManager.GetNetworkConnections())
{
    $connection.GetNetwork().SetCategory(1)
}