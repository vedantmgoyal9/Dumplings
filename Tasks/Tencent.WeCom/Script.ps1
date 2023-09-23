# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $InstallerUrl = Get-RedirectedUrl -Uri 'https://work.weixin.qq.com/wework_admin/commdownload?platform=win'
}

# Version
$Task.CurrentState.Version = [regex]::Match($InstallerUrl, '([\d\.]+)\.exe').Groups[1].Value

switch (Compare-State) {
  ({ $_ -ge 1 }) {
    Write-State
  }
  ({ $_ -ge 2 }) {
    Send-VersionMessage
  }
  ({ $_ -ge 3 }) {
    New-Manifest
  }
}
