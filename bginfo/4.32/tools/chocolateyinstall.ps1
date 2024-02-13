$ErrorActionPreference = 'Stop'; # stop on all errors

$zipFilePath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)\\BGInfo.zip"
$installDir = "C:\Program Files\Sysinternals\BGInfo"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileFullPath  = $zipFilePath
  destination   = $installDir
}

Get-ChocolateyUnzip @packageArgs

# Add it to the path
Install-ChocolateyPath -PathToInstall $installDir -PathType 'Machine'


# Accept the EULA
$registryPath = 'HKCU:\SOFTWARE\Sysinternals\BGInfo'
if (!(Test-Path $registryPath)) {
    New-Item $registryPath -Force | Out-Null
}
New-ItemProperty -Path $registryPath -Name 'EulaAccepted' -Value 1 -Force | Out-Null