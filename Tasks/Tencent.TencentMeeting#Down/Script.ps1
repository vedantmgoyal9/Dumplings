$Object = Invoke-RestMethod -Uri 'https://meeting.tencent.com/web-service/query-download-info?q=[{%22package-type%22:%22app%22,%22channel%22:%220300000000%22,%22platform%22:%22windows%22}]&nonce=AAAAAAAAAAAAAAAA'

# Version
$Task.CurrentState.Version = $Object.'info-list'[0].version

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object.'info-list'[0].url
}

# ReleaseTime
$Task.CurrentState.ReleaseTime = $Object.'info-list'[0].'sub-date' | Get-Date -Format 'yyyy-MM-dd'

switch (Compare-State) {
  ({ $_ -ge 1 }) {
    Write-State
  }
  ({ $_ -ge 2 }) {
    Send-VersionMessage
  }
}
