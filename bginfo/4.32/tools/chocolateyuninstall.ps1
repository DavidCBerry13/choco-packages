$ErrorActionPreference = 'Stop' # stop on all errors

$zipArchive = 'BGInfo.zip'
$installDir = "C:\Program Files\Sysinternals\BGInfo"
$registryPath = 'HKCU:\SOFTWARE\Sysinternals\BGInfo'

# This removes the files from the directory
Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName $zipArchive

# Uninstall-ChocolateyZipPackage only removes the files unzipped from the archive
# To Remove the directory the files were unzipped to, you need to do this separetly in the script
Remove-Item $installDir

# Now clean up the registry
if (Test-Path $registryPath) {
    Remove-Item $sysinternalsPath -Recurse -Force
}