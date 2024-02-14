$ErrorActionPreference = 'Stop'

$zipArchive = 'ProcessExplorer.zip'
$installDir = "C:\Program Files\Sysinternals\ProcessExplorer"
$registryPath = 'HKCU:\SOFTWARE\Sysinternals\Process Explorer'


# This removes the files from the directory
Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName $zipArchive

# Uninstall-ChocolateyZipPackage only removes the files unzipped from the archive
# To Remove the directory the files were unzipped to, you need to do this separetly in the script
Remove-Item $installDir

# Clean up any registry info
if (Test-Path $registryPath) {
    Remove-Item $sysinternalsPath -Recurse -Force
}

# Clean up the shortcut
$shortcutPath = Join-Path $([Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonPrograms)) 'Process Explorer.lnk'
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath
}