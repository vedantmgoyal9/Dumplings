$Config = @{
    Identifier = 'Tencent.COSBrowser'
    Skip       = $false
}

$Ping = {
    $Uri = 'https://cos5.cloud.tencent.com/cosbrowser/latest.yml'
    $Prefix = 'https://cos5.cloud.tencent.com/cosbrowser/'

    $Result = Invoke-WebRequest -Uri $Uri | Read-ResponseContent | ConvertFrom-Yaml | ConvertFrom-ElectronUpdater -Prefix $Prefix

    # ReleaseNotesUrlCN
    $Result.ReleaseNotesUrlCN = 'https://github.com/TencentCloud/cosbrowser/blob/master/changelog.md'

    return $Result
}

return @{
    Config = $Config
    Ping   = $Ping
}
