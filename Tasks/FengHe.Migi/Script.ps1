$Object = Invoke-RestMethod -Uri 'https://fn.kirakuapp.com/admin/version/listNew' -Method Post -Form @{
  platform = '0'
  prodNo   = '1'
}

# Installer
$InstallerUrl = [uri]::UnescapeDataString($Object.data[0].downloadUrl)
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $InstallerUrl
}

# Version
$Task.CurrentState.Version = [regex]::Match($InstallerUrl, '([\d\.-]+)\.exe').Groups[1].Value

# ReleaseTime
$Task.CurrentState.ReleaseTime = $Object.data[0].createTime | Get-Date | ConvertTo-UtcDateTime -Id 'China Standard Time'

# ReleaseNotes (zh-CN)
$ReleaseNotesObject = $Object.data[0].updateLog | ConvertFrom-Json
$ReleaseNotesList = @()
if ($ReleaseNotesObject.added) {
  $ReleaseNotesList += $ReleaseNotesObject.added -creplace '^', '[+ADDED] '
}
if ($ReleaseNotesObject.changed) {
  $ReleaseNotesList += $ReleaseNotesObject.changed -creplace '^', '[*CHANGED] '
}
if ($ReleaseNotesObject.fixed) {
  $ReleaseNotesList += $ReleaseNotesObject.fixed -creplace '^', '[-FIXED] '
}
$Task.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $ReleaseNotesList | Format-Text
}

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
