# nix-config #

My **DEPRECATED** [nixos](https://nixos.org) nixpkgs single user config (macOS)

## Deprecated? ##

Yes, this was my first adventure in nix, doing it the harder way without [home-manager](https://github.com/nix-community/home-manager).

See my [nix-home](https://github.com/ldeck/nix-home) for a [niv](https://github.com/nmattia/niv)/[home-manager](https://github.com/nix-community/home-manager) based flexible config instead.

## Installation ##

### PREREQUISITES ###

Install [nix](https://nixos.org/nix/) purely functional package manager (single-user).

Go to [Single User Installation](https://nixos.org/manual/nix/unstable/installation/installing-binary.html#single-user-installation)

It be may required for you to create a Nix Store volume because the default drive is encrypted.

    sudo diskutil apfs addVolume disk1 'APFS' 'Nix Store' -mountpoint /nix
    sh <(curl -L https://nixos.org/nix/install) --no-daemon


### Clone Location ###

``` shell
git clone git@github.com:ldeck/nix-config.git ~/.config
```

### Install/update myPackages environment ###

``` shell
nix-env -iA nixpkgs.myPackages
```

NB: nothing will change if you've not changed any config and/or updated nix itself. See [Upgrading Nix](https://nixos.org/manual/nix/unstable/installation/upgrading.html).

### Link Shell ###

e.g., ~/.zshrc

    #!/bin/sh
    source $HOME/.config/shell/.profile

## Install macOS apps ##

See list of macOS apps in [nixpkgs/custom/apps/default.nix](nixpkgs/custom/apps/default.nix)

``` shell
nix-env -iA nixpkgs.myApps
```

## Custom scripts ##

### app-path ###

Finds a single application via fuzzy matching if possible.
If a single app can't be found, the matching applications are printed (if any), then app-path usage is printed.

    Usage: app-path fuzzyname...

Locations searched (in order):
  * `~/.nix-profile/Applications`
  * `~/.nix-profile/Applications/Utilities`
  * `~/Applications`
  * `~/Applications/Utilities`
  * `/Applications`
  * `/Applications/Utilities`
  * `/System/Applications`
  * `/System/Applications/Utilities`

Examples:

    % app-path cont
    Matches:
    | Contacts.app
    | Mission Control.app
    Usage: app-path fuzzyname...

    % app-path conta
    /System/Applications/Contacts.app

    % app-path idea
    /Users/ldeck/.nix-profile/Applications/IntelliJ IDEA.app

     % app-path ins
    Matches:
    | Insomnia Designer.app |
    | Insomnia.app          |
    Usage: app-path fuzzyname...

    % app-path ins de
    /Users/ldeck/.nix-profile/Applications/Insomnia Designer.app

    # same as this regex
    % app-path 'ins.*de'
    /Users/ldeck/.nix-profile/Applications/Insomnia Designer.app


### future-git ###

    Usage: future-git <hours> [<git args>]

### idownload ###

Downloads unresolved .*icloud files or directories.

    Usage: idownload <file|dir>

### java_home ###

    Usage: java_home -v <version>

### jqo ###

Pipe stdout to jqo to handle intermixed json and standard messages

    Usage: ... | jqo

### jqj ###

Pipe stdout to jqj to handle intermixed json and standard messages

    Usage: ... | jqj

### jqr ###

Pipe stdout to jqr to handle intermixed json and standard messages

    Usage: ... | jqr

### nix-cache-versions ###

pin versions in ~/.cache/pinned-versions.tsv

### nix-create-shell ###

shell.nix template with pinned pkgs

### nix-link-macapps ###

Symlinks `~/.nix-profile/Applications/*` to `~/Applications`.

    Usage: nix-link-macapps

### nix-open ###

Open nix or system-installed apps (found using app-path).

    Usage: nix-open application [args...]

### nix-reopen ###

Re-open nix or system-installed apps (found using app-path).

    Usage: nix-reopen application [args...]

### nix-system ###

Shortcut for `nix-shell -p nix-info --run "nix-info -m"`

### nix-update ###

update nix, nixpkgs, myPackages, myApps and symlinks

### nix-version ###

shortcut for `nix-instantiate --eval -A 'lib.version' '<nixpkgs>' | xargs`

### sudo-with-touch ###

Configures sudo to be used with Touch ID.

    Usage: sudo-with-touch
