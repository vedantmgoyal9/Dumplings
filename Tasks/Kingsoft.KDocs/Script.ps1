$Object = (Invoke-RestMethod -Uri 'https://www.kdocs.cn/kdg/api/v1/configure?idList=kdesktopWinVersion').data.kdesktopWinVersion | ConvertFrom-Json
# $Object = (Invoke-RestMethod -Uri 'https://www.kdocs.cn/kd/api/configure/list?idList=kdesktopWinVersion').data.kdesktopWinVersion | ConvertFrom-Json

# Version
$this.CurrentState.Version = $Object.version

# Installer
$this.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object.url.Replace('1002', '1001')
}

# ReleaseNotes (zh-CN)
$this.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object.changes | Format-Text
}

switch ($this.Check()) {
  ({ $_ -ge 1 }) {
    $this.Write()
  }
  ({ $_ -ge 2 }) {
    $this.Message()
  }
  ({ $_ -ge 3 }) {
    $ToSubmit = $false

    $Mutex = [System.Threading.Mutex]::new($false, 'DumplingsKDocs')
    $Mutex.WaitOne(30000) | Out-Null
    if (-not $LocalStorage.Contains('KDocsSubmitting')) {
      $LocalStorage['KDocsSubmitting'] = $ToSubmit = $true
    }
    $Mutex.ReleaseMutex()
    $Mutex.Dispose()

    if ($ToSubmit) {
      $this.Submit()
    } else {
      $this.Logging('Another task is submitting manifests for this package', 'Warning')
    }
  }
}
