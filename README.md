# nix-config #

My [nixos](https://nixos.org) nixpkgs single user config (macOS)

## PREREQUISITES ##

Install [nix](https://nixos.org/nix/) purely functional package manager (single-user).

## Clone Location ##

``` shell
git clone git@github.com:ldeck/nix-config.git ~/.config
```

## Install myPackages environment ##

``` shell
nix-env -iA nixpkgs.myPackages
```
