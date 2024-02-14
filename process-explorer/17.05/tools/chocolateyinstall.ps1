$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$zipFilePath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)\\ProcessExplorer.zip"
$installDir = "C:\Program Files\Sysinternals\ProcessExplorer"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileFullPath  = $zipFilePath
  destination   = $installDir
}

Get-ChocolateyUnzip @packageArgs


# Not sure what this is for
#@('procexp', 'procexp64') | ForEach-Object {
#    New-Item "$toolsDir\$_.exe.gui" -Type File -Force | Out-Null
#}


# This accepts the license agreement
$registryPath = 'HKCU:\SOFTWARE\Sysinternals\Process Explorer'
if (!(Test-Path $registryPath)) {
    New-Item $registryPath -Force | Out-Null
}
New-ItemProperty -Path $registryPath -Name 'EulaAccepted' -Value 1 -Force | Out-Null


# This will make a shortcut in C:\ProgramData\Microsoft\Windows\Start Menu\Programs
$shortcutPath = Join-Path $([Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonPrograms)) 'Process Explorer.lnk'
if (-not (Test-Path $shortcutPath)) {
    $targetPath = if ([Environment]::Is64BitOperatingSystem) { 'procexp64.exe' } else { 'procexp.exe' }
    Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$installDir\$targetPath"
}