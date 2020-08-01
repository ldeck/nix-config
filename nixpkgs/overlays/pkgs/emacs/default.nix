{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let

  myEmacsConfig = ./default.el;

in

emacsWithPackages (epkgs:
  # CONFIG setup
  [
    (runCommand "default.el" {} ''
      mkdir =p $out/share/emacs/site-lisp
      cp ${myEmacsConfig} $out/share/emacs/site-lisp/default.el
    '')
  ] ++

  # ELPA packages
  (with epkgs.elpaPackages; [
    undo-tree
  ]) ++

  # MELPA packages
  (with epkgs.melpaPackages; [
    dired-subtree
  ]) ++

  # MELPA stable packages
  (with epkgs.melpaStablePackages; [
    ag
    company
    company-terraform
    counsel
    crux
    expand-region
    flycheck
    format-all
    helm
    helm-ag
    helm-descbinds
    helm-flyspell
    helm-projectile
    ivy
    mac-pseudo-daemon
    magit
    markdown-mode
    move-text
    nix-mode
    projectile
    smartparens
    terraform-doc
    terraform-mode
    undo-propose
    use-package
    which-key
    yaml-mode
  ])
)
