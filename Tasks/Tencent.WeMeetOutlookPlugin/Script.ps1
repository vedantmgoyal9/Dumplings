# Download
$Version1 = @($Global:LocalStorage['WeMeetOutlookPlugin1'].Keys)[-1] ?? '0'
# Upgrade
$Version2 = @($Global:LocalStorage['WeMeetOutlookPlugin2'].Keys)[-1] ?? '0'

if ((Compare-Version -ReferenceVersion $Version1 -DifferenceVersion $Version2) -le 0) {
  # Version
  $this.CurrentState.Version = $Version = $Version1

  # Installer
  $this.CurrentState.Installer += [ordered]@{
    InstallerUrl = $Global:LocalStorage['WeMeetOutlookPlugin1'].$Version1.InstallerUrl
  }
} else {
  # Version
  $this.CurrentState.Version = $Version = $Version2

  # Installer
  $this.CurrentState.Installer += [ordered]@{
    InstallerUrl = $Global:LocalStorage['WeMeetOutlookPlugin2'].$Version2.InstallerUrl
  }
}

if ($Global:LocalStorage['WeMeetOutlookPlugin1'].Contains($Version)) {
  # ReleaseTime
  $this.CurrentState.ReleaseTime = $Global:LocalStorage['WeMeetOutlookPlugin1'].$Version.ReleaseTime
}

if ($Global:LocalStorage['WeMeetOutlookPlugin2'].Contains($Version)) {
  # ReleaseNotes (zh-CN)
  $this.CurrentState.Locale += [ordered]@{
    Locale = 'zh-CN'
    Key    = 'ReleaseNotes'
    Value  = $Global:LocalStorage['WeMeetOutlookPlugin2'].$Version.ReleaseNotesCN
  }
}

switch -Regex ($this.Check()) {
  'New|Changed|Updated' {
    $this.Write()
  }
  'Changed|Updated' {
    $this.Print()
    $this.Message()
  }
  'Updated' {
    $this.Submit()
  }
}
