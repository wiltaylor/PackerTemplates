param($boxname, $version, $provider, $Username = $env:ATLAS_USERNAME, $APIKey=$env:ATLAS_TOKEN)

$url = "https://atlas.hashicorp.com/api/v1/box/$Username/$boxname/version/$version/provider/$provider/upload?access_token=$APIKey"

$target = Invoke-WebRequest -Uri $url


