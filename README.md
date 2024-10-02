# Choco Packages

This is a repository for experimenting with how to build Chocolatey packages, primarilly for internal use.  

If you are using Chocolatey within an organization, Chocolatey recomends *against* using the [Chocolatey Community Repository](https://community.chocolatey.org/) because:

- The community repo uses URLs from original software sources.  This can cause reliability issues when using inside a company because sites may be blocked, down, etc.
- Inside a company, you often want to control what software is available and what can be installed rather than allowing anything and everything.  This is especially important because different software may have different licensing

The solution is to setup an internal Chocolatey repository.  An internal Chocolatey repository is a NuGet server that servers out Chocolatey packages.  It can be as simple as a file share or a robust, commecial NuGet server.

In any case, you will need to package up software to be loaded into your Chocolatey repository.  This GitHub repo is designed to learn how and experiment with the diferent Chocolatey commands and options.

## Repos Setup

This repo will store not just the Chocolatey configuration for each package, but also the software to be installed itself, usually in the form of an msi, exe, or zip file.  Since these installation packages can be large, this neccessitates setting up the repo with [Git LFS (Large File Storage)](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github).  

To use Git LFS with a repo containing Chocolatey packages, follow these steps.

1. **Check if you already have Git LFS installed**

    Navigate to your repository in a terminal window (either CMD or PowerShell) and run the command `git lfs install`.

    ```Terminal
    git lfs install
    ```

    If you see a line saying `Git LFS initialized, you can skip steps 2 and 3 below.

2. **Install the Git LFS software on your workstation**

   If Git LFS is not installed on your system, you need to install it.

   Navigate to [git-lfs.com](https://git-lfs.com) and download the Git LFS installer.  Once downloaded, run the installer to install Git LFS on your machine.

3. **Setup Git LFS on your system**

    Now that Git LFS is installed, you need to set it up on your system by using the [`git lfs install`](file:///C:/Program%20Files/Git/mingw64/share/doc/git-doc/git-lfs.html) command.  This only needs to be be once per user account.  That is, if you have already done this for another repository, you do not need to do it again.

    ```Terminal
    git lfs install
    ```

    You should see a line saying `Git LFS initialized` confirming Git LFS is now set up.

4. **Add file types to track using Git LFS in your repo**

    Navigate to your repository in a terminal window.  Then use the 'git lfs track` command to track the file types to manage with Git LFS.

    For a repository containing chocolatey packages, this would typically be MSI (*.msi), EXE (*.exe), and ZIP (*.zip) files.  However, you can add additional file types as neccessary.

    ```Terminal
    git lfs track "*.msi"
    git lfs track "*.exe"
    git lfs track "*.zip"
    ```

    After doing this, you will see that a `.gitattributes` file has been created in your repository directory.  This contains the information on what files are managed with Git LFS.

    You will need to make sure to do a `git add` on the `.gitattributes` file and commit it to the repository.

## Repo Organization

### Overview

This repo organizes its contents by package and version in a hierarchy that looks like the following:

- 7zip
  - 16.04
  - 19.00
  - 23.04
- notepad-plus-plus
  - 8.5.8
  - 8.6.0
  - 8.6.2
- process-explorer
  - 17.05

This heierachy allows the repo to contain multiple package versions for the same app.  Top level directories (7zip, notepad-plus-plus, process-explorer) will be referred to as *parent package* directories in this document.  The subdirectories under these parent directories will be referrred to as *package version* directories since they represent individual versions of each package.

This structure also means that each package version should be immutable once it is checked in and merged into the repo.  When you need to add a new version for a package, you add a new directory for that version under tha parent package folder.

The following naming conventions should be observed for these directories:

**For *parent package* directories**

- The name of the folder should be the package name in all lower case letters
- Words should be separated by the hyphen (`\`) character

**For *package version* directories**

- Use the full version as it is specified for the application or package (eg: `23.01` or `8.6.2`)
- Do not include the pakcage name.  Only include the version number

## Software Redistribution and Licensing

This repo is not intended as a redistribution point or mirror of the packages included within the repo.  However, in order to learn and demonstrate how to create chocolatey packages, it is neccessary to have the installers for these packages in this repo.  For that reason, I've included the license for each package in the repo under the *parent package* directory to try and make sure things are covered from a legal standpoint.  

Again though, this is a learning and demonstration repo.  If you are looking to download and install any of this software, either head to the Chocolately community repository or each packages respective website.

Finally, this repo contains an MIT license in the root folder which is intended to apply to the concepts and learnings of the repo, not the software packages contained within it.  Those software packages still retain their normal licenses.

## Creating a Chocolatey Package

### 1 - Create a new Chocolatey package using choco new

Navigate into the application folder of the application you want to create a package for (for example, the 7zip folder).  Then run the [choco new](https://docs.chocolatey.org/en-us/create/commands/new) command with the application name (no version) to create the package.  For example, you would use `7zip`, `notepad-plus-plus`, or `process-explorer` for the package name.

```PowerShell
choco new <package-name>
```

This will create a subdirectory with the same name as the package (example: 7zip).  We don't want this subdirectory named after the app/package, but rather the vesion, so we'll rename it in the next step.

### 2 - Rename a the directory with the application version

The directory created in the last step by `choco new` has the name of the package, but we want it to have the name of the version so we can support multiple versions of the package in the repo.  For example, if you are creating a package for 7-Zip version 23.01, you will have a directory named `7zip` at this point, but you want this directory to be named `23.01`.  This should just be the package version number without the package name.

Use the PowerShell [Rename-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-item?view=powershell-7.4) command the change the directory name.

```PowerShell
Rename-Item -Path <package-name> -NewName <version>
```

### 3 - Follow the Package Creation Guides at Chocolatey.org

The Chocolatey Docs site contains a number of useful guides for how to create packages depending on if you have an MSI, a portable application (stand alone exe), or a Zip file you want to install.  Follow the guide appropriate for your use case:

- **MSI or EXE Installer** - [How To Create an MSI Installer Package](https://docs.chocolatey.org/en-us/guides/create/create-msi-package)
- **Zip File** - [How To Create a Zip Package](https://docs.chocolatey.org/en-us/guides/create/create-zip-package)
- **Portable Application** - [How To Create a CLI Executable Package](https://docs.chocolatey.org/en-us/guides/create/create-cli-package)

Also, if you are creating packages for internal repositories, you can delete the README, LICENSE, and VERIFICATION files.  These are not needed.

### 4 - Build the Package

```PowerShell
choco pack <path to nuspec file> --out <output directory>
```
