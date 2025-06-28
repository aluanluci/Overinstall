# OverInstall (Bash Version) [Experimental]

## Install apks without having to uninstall the original app, even if the certificate is different

## Useful for:

* Install apk Mods
* Test/Fix errors
* Automation of tasks
* And more...

## Requeriments:
* Sudo
* Android device
* Terminal with Bash interpreter
* Apk to be installed
* And a brain

## Installation:
### Clone this repo:
    
    git clone https://github.com/aluanluci/overinstall/

### Setup

    cd Overinstall/;
    chmod +x overinstall.sh

## Usage

### Simple script
    sudo ./overinstall.sh
### Direct Overinstall
    sudo ./overinstall <package> <apk_path>
Replace <strong>\<package></strong> and <strong>\<apk_path></strong> with package name of installed app and new apk file path, respectively.

### Help
    ./overinstall --help


## Caution:

### This is an experimental project intended for rooted android devices, so please handle with caution, I'm not responsible for any damage caused, use at your own risk.