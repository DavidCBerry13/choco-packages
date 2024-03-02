$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$filePath = if ((Get-OSArchitectureWidth 64) -and $env:chocolateyForceX86 -ne $true) {
    Write-Host "Installing 64 bit version"
    Get-Item $toolsDir\*-x64.exe 
}
else { 
    Write-Error "This package only contains the 64 bit version of 7-zip.  Cannot install on 32 bit system" 
    return
}

$packageArgs = @{
  packageName    = '7zip'
  fileType       = 'exe'
  softwareName   = '7-zip*'
  file           = $filePath
  silentArgs     = '/S'
  validExitCodes = @(0)
}

# This runs the installer to install the software
Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force

# Get the installed location.  We'll need this to create the shim
$installLocation = Get-AppInstallLocation $packageArgs.softwareName
if (!$installLocation)  { 
    Write-Warning "Can't find 7zip install location"; 
    return 
}
Write-Host "7zip installed to '$installLocation'"

# This creates the shim for the 7z executable
Install-BinFile '7z' $installLocation\7z.exe