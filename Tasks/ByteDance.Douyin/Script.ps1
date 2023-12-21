$Object = Invoke-RestMethod -Uri 'https://tron.jiyunhudong.com/api/sdk/check_update?pid=7044145585217083655&branch=master&buildId=&uid='

# Version
$this.CurrentState.Version = $Object.data.manifest.win32.version

# Installer
$this.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object.data.manifest.win32.urls.Where({ $_.region -eq 'cn' }).path.ia32.Replace('lf3-cdn-tos.bytegoofy.com', 'www.douyin.com/download/pc')
}

# ReleaseTime
$this.CurrentState.ReleaseTime = $Object.data.manifest.win32.extra.uploadDate | ConvertFrom-UnixTimeMilliseconds

# ReleaseNotes (zh-CN)
$this.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object.data.releaseNote | Format-Text
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

    $Mutex = [System.Threading.Mutex]::new($false, 'DumplingsDouyin')
    $Mutex.WaitOne(30000) | Out-Null
    if (-not $LocalStorage.Contains('DouyinSubmitting')) {
      $LocalStorage['DouyinSubmitting'] = $ToSubmit = $true
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
