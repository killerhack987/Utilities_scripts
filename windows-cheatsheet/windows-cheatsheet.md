# Windows 10 Cheatsheet

Note: All scripts in this document should be executed in **Windows Powershell as Administrator**.

## Add files/directories to Windows Defender ignore list

```powershell
ForEach ($item in @(
    "${env:WINDIR}\System32\drivers\etc\hosts"
    "D:\Install"
    "D:\Apps"
)) {
   Add-MpPreference -ExclusionPath (Convert-Path -Path $item)
}
```

## Powershell

Update help for all Powershell commands:

```powershell
Update-Help
```

Allow to run PS scripts:

```
Set-ExecutionPolicy RemoteSigned
```

Install powershell modules

```
ForEach ($item in @(
    "Choco" # Chocolatey package manager
    "Microsoft.PowerShell.ConsoleGuiTools" # Adds `Out-ConsoleGridView`
    "nvm" # Node version manager
)) {
   Install-Module -Name $item -Force
}
```

## Choco

[Chocolatey](https://chocolatey.org/) is the Package Manager for Windows.

### Choco setup

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

### Choco commands

#### Choco Upgrade all

Upgrades to latest version all apps installed using Chocolatey:

```powershell
choco upgrade all -y --allowunofficial --ignore-checksum
```

#### Install packages

Installs apps listed in an array:

```powershell
$packages = @(
    # Android things
    "adb" # Android Debug Bridge (adb)
    "universal-adb-drivers" # Android ADB drivers

    # Command line tools
    "curl"  # cUrL is a tool and library for transferring data with URLs 
    "ffmpeg"# Video encoder
    "grep"  # grep is a utility for searching plain-text data sets for lines that match a regular expression
    "jq"    # Command-line JSON processor
    "md5"   # Calculates md5
    "unrar" # RAR unarchiver
    "unzip" # Zip unarchiver
    "youtube-dl" # CLI YouTube downloader
    "zip"   # Zip archiver

    # Internet
    "firefox"       # From mozilla with love
    "googlechrome"  # Thing for collecting personal data
    "qbittorrent"   # Best torrent client
    "slack"         # Corporate chat
    "synologydrive" # Synology Drive client
    "teamviewer"    # Desktop remote control
    "telegram"      # Text me baby
    "warp"          # Cloudflare Warp VPN
    #"discord"      # Gaming chat
    #"filezilla"    # FTP/SFTP client
    #"googledrive"  # Google Drive client
    #"nordvpn"      # NordVPN Client
    #"viber"        # Say hello to your granny

    # System libraries redistributables runtimes drivers
    "directx"      # DirectX library
    "dotnet3.5"    # .NET Framework: v3.5
    "dotnet4.7"    # .NET Framework: v4.7
    "geforce-experience" # Nvidia Geforce Experience
    "openjdk"      # OpenJDK + OpenJDK JRE
    "python3"      # Python3 runtime
    "vcredist-all" # C++ redistributables

    # System
    "7zip"            # Best free archiver
    "hashtab"         # File properties tab with hashes
    "hwinfo"          # System components information
    "lockhunter"      # Searchs what locks application
    #"ccenhancer"     # Cleaner tool advanced settings
    #"ccleaner"       # Cleaner tool
    #"crystaldiskinfo" # Disk information
    #"crystaldiskmark" # Disk benchmark
    #"geekuninstaller" # Uninstall tool
    #"linkshellextension" # Explorer context links for symlinks/hardlinks
    #"rufus"           # Windows/Linux ISO to USB writer
    #"teracopy"
    #"windirstat"      # Visual directory size

    # Office
    "libreoffice-still"  # Not the best but good office. "still" == most stable version
    "simplenote"         # Markdown Notes.
    #"adobereader"      # Adobe Reader
    #"pdfxchangeeditor"   # PDF reader

    # Media
    "k-litecodecpackmega" # Most complete set of codecs
    "vlc"       # Best porn player
    #"audacity" # Simple audio editing
    #"krita"    # Image editor
    #"monosnap"  # Screenshot tool
    #"xnviewmp" # Image viewer

    # Development
    "git.install"      # Version Control System
    "sublimemerge"     # Git GUI tool
    "sublimetext3"     # Fast text/code editor
    "vscode"           # Code editor
    #"awscli"          # Amazon Web Services cli
    #"docker-desktop"  # Docker
    #"gitextensions"   # Git extensions
    #"intellijidea-community" # Java IDE
    #"nodejs-lts"      # Node
    #"phpstorm"        # PHP IDE
    #"pycharm-community" # Python IDE
    #"sourcetree"      # Git GUI tool
    #"yarn"            # Node package manager

    # Games
    #"retroarch"          # Retro games emulation station 
    #"epicgameslauncher" # Epic Games Store
    #"steam"             # Steam

    # Fonts
    "jetbrainsmono"
    "opensans"
    "droidsansmono"
    "hackfont"
    "inconsolata"
    "dejavufonts"
    "robotofonts"
    "ubuntu.font"
    "anonymouspro"
); choco install -y --allowunofficial --ignore-checksum $packages
```

## Visual Studio Code Extensions

Following command installs `code` extensions by their extension id:

```powershell
ForEach ($extension in @(
    "acarreiro.calculate"                     
    "alefragnani.Bookmarks"                   # Bookmarks
    "bbeversdorf.drupal-check"                # Drupal: check for deprecations
    "christian-kohler.npm-intellisense"       # NPM better autocomplete
    "christian-kohler.path-intellisense"      # File path autocomplete
    "coenraads.bracket-pair-colorizer"        # Bracket Pair Colorizer
    "dbaeumer.vscode-eslint"                  # Eslint support
    "editorconfig.editorconfig"               # EditorConfig support
    "esbenp.prettier-vscode"                  # Prettier - Code formatter
    "github.github-vscode-theme"              # GitHub color theme
    "golang.go"                               # Golang support
    "ikappas.composer"                        # Composer support
    "ikappas.phpcs"                           # PHP CodeSniffer
    "mariusschulz.yarn-lock-syntax"           # yarn.lock syntax highlight
    "mhutchie.git-graph"                      # Git graph
    "mikestead.dotenv"                        # .env support
    "ms-azuretools.vscode-docker"             # Docker support
    "ms-python.python"                        # Python support
    "pkief.material-icon-theme"               # Material Icon Theme
    "visualstudioexptteam.vscodeintellicode"  # AI-assisted autocomplete
    "william-voyek.vscode-nginx"              # nginx.conf support
    "yzhang.markdown-all-in-one"              # Markdown tools
    "hookyqr.beautify"                        # HTML/JSON beautifier
    "dakara.transformer"                      # Filter, Sort, Unique, Reverse, Align, CSV, Line Selection, Text Transformations and Macros
)) {
    code --install-extension $extension
}
```

## Common commands

| Action | Command |
| ------ | ------- |
| Disable password prompt on windows load | `netplwiz` |
| Reset DNS | `ipconfig /flushdns; netsh winsock reset` |

## Enabling Windows features

### Enable Hyper-V

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### Enable WSL (Windows Subsystem Linux)

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

#!! RESTART !!

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
wsl --set-default-version 2
```

## Docker for Windows

- Install Docker for Windows:

  ```powershell
  choco install docker-desktop
  ```

- Add your `Projects` directory to Windows Defender Exclusion list for better Docker performance:

  ```powershell
  Add-MpPreference -ExclusionPath "D:\Projects"
  ```

- Add directory to Windows Indexing exclusion list for better Docker performance: `Control Panel -> Indexing Options -> Add all of your development directories`

### Docker daemon config

#### `%APPDATA%\Docker\settings.json`

```json
{
  "cpus": 8,
  "memoryMiB": 32000,
  "swapMiB": 4096,
  "diskSizeMiB": 128000000000,
  "exposeDockerAPIOnTCP2375": true,
}
```

## Windows `ENVIRONMENT` variables

| Variable | Volatile (Read-Only) | Default value assuming the system drive is C: |
|----------|:--------------------:|-----------------------------------------|
| `ALLUSERSPROFILE` | | C:\ProgramData |
| `APPDATA` | | C:\Users\{username}\AppData\Roaming |
| `CD` | Y | The current directory (string). |
| `ClientName` | Y | Terminal servers only - the ComputerName of a remote host. |
| `CMDEXTVERSION` | Y | The current Command Processor Extensions version number. (NT = "1", Win2000+ = "2".) |
| `CMDCMDLINE` | Y | The original command line that invoked the Command Processor. |
| `CommonProgramFiles` | | C:\Program Files\Common Files |
| `COMMONPROGRAMFILES(x86)` | | C:\Program Files (x86)\Common Files |
| `COMPUTERNAME` | | {computername} |
| `COMSPEC` | | C:\Windows\System32\cmd.exe or if running a 32 bit WOW - C:\Windows\SysWOW64\cmd.exe |
| `DATE` | Y | The current date using same region specific format as DATE. |
| `ERRORLEVEL` | Y | The current ERRORLEVEL value, automatically set when a program exits. |
| `FPS_BROWSER_APP_PROFILE_STRING` `FPS_BROWSER_USER_PROFILE_STRING` | | Internet Explorer Default These are undocumented variables for the Edge browser in Windows 10. |
| `HighestNumaNodeNumber` | Y (hidden) | The highest NUMA node number on this computer. |
| `HOMEDRIVE` | Y | C: |
| `HOMEPATH` | Y | \Users\{username} |
| `LOCALAPPDATA` | | C:\Users\{username}\AppData\Local |
| `LOGONSERVER` | | \\{domain_logon_server} |
| `NUMBER_OF_PROCESSORS` | Y | The Number of processors running on the machine. | Y | Operating system on the user's workstation. |
| `PATH` | User and System | C:\Windows\System32\;C:\Windows\;C:\Windows\System32\Wbem;{plus program paths}|
| `PATHEXT` | | .COM; .EXE; .BAT; .CMD; .VBS; .VBE; .JS ; .WSF; .WSH; .MSC Determine the default executable file extensions to search for and use, and in which order, left to right. The syntax is like the PATH variable - semicolon separators. |
| `PROCESSOR_ARCHITECTURE` | Y | AMD64/IA64/x86 This doesn't tell you the architecture of the processor but only of the current process, so it returns "x86" for a 32 bit WOW process running on 64 bit Windows. See detecting OS 32/64 bit |
| `PROCESSOR_ARCHITEW6432` | | =%PROCESSOR_ARCHITECTURE% (but only available to 64 bit processes) |
| `PROCESSOR_IDENTIFIER` | Y | Processor ID of the user's workstation. |
| `PROCESSOR_LEVEL` | Y | Processor level of the user's workstation. |
| `PROCESSOR_REVISION` | Y | Processor version of the user's workstation. |
| `ProgramW6432` | | =%ProgramFiles%(but only available when running under a 64 bit OS) |
| `ProgramData` | | C:\ProgramData |
| `ProgramFiles` | | C:\Program Files or C:\Program Files (x86) |
| `ProgramFiles(x86) 1` | | C:\Program Files (x86) (but only available when running under a 64 bit OS) |
| `PROMPT` | | Code for current command prompt format,usually $P$G C:> |
| `PSModulePath` | | %SystemRoot%\system32\WindowsPowerShell\v1.0\Modules\ |
| `Public` | | C:\Users\Public |
| `RANDOM` | Y | A random integer number, anything from 0 to 32,767 (inclusive). |
| `%SessionName%` | | Terminal servers only - for a terminal server session, SessionName is a combination of the connection name, followed by #SessionNumber. For a console session, SessionName returns "Console". |
| `SYSTEMDRIVE` | | C:|
| `SYSTEMROOT` | | By default, Windows is installed to C:\Windows but there's no guarantee of that, Windows can be installed to a different folder, or a different drive letter. systemroot is a read-only system variable that will resolve to the correct location. Defaults in early Windows versions are C:\WINNT, C:\WINNT35 and C:\WTSRV |
| `TEMP` and `TMP` | User Variable | C:\Users\{Username}\AppData\Local\Temp Under XP this was \{username}\Local Settings\Temp |
| `TIME` | Y | The current time using same format as TIME. |
| `UserDnsDomain` | Y User Variable | Set if a user is a logged on to a domain and returns the fully qualified DNS domain that the currently logged on user's account belongs to. |
| `USERDOMAIN` | | {userdomain} |
| `USERDOMAIN_roamingprofile` | | The user domain for RDS or standard roaming profile paths. Windows 8/10/2012 (or Windows 7/2008 with Q2664408) |
| `USERNAME` | | {username} |
| `USERPROFILE` | | %SystemDrive%\Users\{username} This is equivalent to the $HOME environment variable in Unix/Linux |
| `WINDIR` | | %windir% is a regular User variable and can be changed, which makes it less robust than %SystemRoot% Set by default as windir=%SystemRoot% %WinDir% pre-dates Windows NT, its use in many places has been replaced by the system variable: %SystemRoot% |

## Disable Windows 10 telemetry

Run following command in Powershell (as Administrator):

```powershell
# Add hosts to windows defender ignore list so it will be not reverted to its original content.
Add-MpPreference -ExclusionPath "${env:WINDIR}\System32\drivers\etc\hosts"
# Replace current hosts file with file from URL.
Start-BitsTransfer -Source "https://www.encrypt-the-planet.com/downloads/hosts" -Destination "${env:WINDIR}\System32\drivers\etc\hosts"
```