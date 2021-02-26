# nix-config #

My [nixos](https://nixos.org) nixpkgs single user config (macOS)


## Installation ##

### PREREQUISITES ###

Install [nix](https://nixos.org/nix/) purely functional package manager (single-user).

### Clone Location ###

``` shell
git clone git@github.com:ldeck/nix-config.git ~/.config
```

### Install/update myPackages environment ###

``` shell
nix-env -iA nixpkgs.myPackages
```

NB: nothing will change if you've not changed any config and/or updated nix itself. See [Upgrading Nix](https://nixos.org/manual/nix/unstable/installation/upgrading.html).


## Install macOS derivations ##

See list of macOS apps in overlay [30-apps.nix](nixpkgs/overlays/30-apps.nix)

``` shell
nix-env -i IntelliJIDEA
```

## Custom scripts ##

### app-path ###

Usage: app-path fuzzyname...

### future-git ###

Usage: future-git <hours> [<git args>]

### idownload ###

Description: downloads .*icloud files
Usage: idownload <file|dir>

### java_home ###

Usage: java_home -v <version>

### jqo ###

Description: pipe stdout to jqo to handle intermixed json and standard messages

### nix-link-macapps ###

Description: symlinks ~/.nix-profile/Applications/* to ~/Applications
Usage: nix-link-macapps

### nix-open ###

Description: open nix or system-installed apps (found using app-path)
Usage: nix-open application [args...]

### nix-reopen ###

Description: re-open nix or system-installed apps (found using app-path)
Usage: nix-reopen application [args...]

### sudo-with-touch ###

Description: configures sudo to be used with Touch ID
Usage: sudo-with-touch
