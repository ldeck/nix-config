{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {

    myProfile = pkgs.writeText "my-profile" ''
      export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/sbin:/bin:/usr/sbin:/usr/bin
      export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:/usr/share/man
      export IDEA_VM_OPTIONS=~/Library/Preferences/IntelliJIdea2019.3/idea.vmoptions
    '';

    idownload = pkgs.writeShellScriptBin "idownload" ''
      if [ "$#" -ne 1 ] || ! [ -e $1 ]; then
          echo "Usage: idownload <file|dir>";
          return 1;
        fi
        find . -name '.*icloud' |\
        perl -pe 's|(.*)/.(.*).icloud|$1/$2|s' |\
        while read file; do brctl download "$file"; done
    '';

    jqo = pkgs.writeShellScriptBin "jqo" ''
      ${pkgs.jq}/bin/jq -R -r 'capture("(?<prefix>[^{]*)(?<json>{.+})?(?<suffix>.*)") | .prefix,(.json|try fromjson catch ""),.suffix | select(length > 0)'
    '';

    jqj = pkgs.writeShellScriptBin "jqj" ''
      ${pkgs.jq}/bin/jq -R -r 'capture("(?<prefix>[^{]*)(?<json>{.+})?(?<suffix>.*)") | (.json|try fromjson catch "") | select(length > 0)'
    '';

    jqr = pkgs.writeShellScriptBin "jqr" ''
      ${pkgs.jq}/bin/jq -R -r 'capture("(?<prefix>[^{]*)(?<json>{.+})?(?<suffix>.*)") | .json | select(length > 0)'
    '';

    myPackages = buildEnv {
      name = "my-packages";
      paths = [
        (runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/my-profile.sh
      '')

        # custom
        idownload
        jqo
        jqj
        jqr

        # bash scripts
        argbash
        bash
        bash-boilerplate

        # cloud
        cloudfoundry-cli
        google-cloud-sdk
        cloud-sql-proxy
        terraform

        # java
        jdk11

        # js
        nodejs-10_x
        yarn

        # devtools
        geckodriver

        # general
        aspell
        bc
        coreutils
        direnv
        emacs
        emscripten
        ffmpeg
        gdb
        git
        hello
        jetbrains.idea-ultimate.2019.3
        jq
        jump
        kotlin
        kryptco.kr
        markdown
        maven
        nginx
        nixops
        nox
        perl
        scala
        silver-searcher
        taskwarrior
        yq
      ];
      pathsToLink = [ "/share/man" "/share/doc" "/bin" "/etc" "/Applications" ];
      extraOutputsToInstall = [ "man" "doc" ];
    };

    # =======================
    # bash script derivations
    # =======================

    bash-boilerplate = stdenv.mkDerivation rec {
      name = "bash-boilerplate-${version}";
      version = "1.41";

      src = fetchFromGitHub {
        owner = "pforret";
        repo = "bash-boilerplate";
        rev = "7281a3705c82a92f1cddf4451d3d19a4a5bc2057";
        sha256 = "1s8ilp0ki6fnri24i7814yv3y7gh1z0am37g1k7ilnikhgq5vbrw";
      };

      installPhase = ''
        mkdir -p $out/bin;
        cp script.sh $out/bin/bash-boilerplate;
        chmod +x $out/bin/bash-boilerplate;
      '';
    };

    # =======================
    # oauth derivations
    # =======================

    kryptco.kr = buildGoModule rec {
      name = "kr-${version}";
      version = "2.4.15";

      src = fetchFromGitHub {
        owner = "kryptco";
        repo = "kr";
        rev = "1937e31606e4dc0f7263133334d429f956502276";
        sha256 = "13ch85f1y4j2n4dbc6alsxbxfd6xnidwi2clibssk5srkz3mx794";
      };

      modRoot = "./src";
      goDeps = ./overlays/pkgs/kryptco/kr/deps.nix;
      modSha256 = "1q6vhdwz26qkpzmsnk6d9j6hjgliwkgma50mq7w2rl6rkwashvay";

      meta = with lib; {
        description = "A dev tool for SSH auth + Git commit/tag signing using a key stored in Krypton.";
        homepage = "https://krypt.co";
        license = licenses.unfreeRedistributable;
        platforms = platforms.linux ++ platforms.darwin;
      };
    };

    # =======================
    # symlinks
    # =======================

    markdown = emem.overrideAttrs (oldAttrs: rec {
      installPhase = oldAttrs.installPhase + ''
        ln -fs $out/bin/emem $out/bin/markdown
      '';
    });

    # =======================
    # editor derivations
    # =======================

    myEmacsConfig = ./overlays/pkgs/emacs/default.el;

    emacs = emacsWithPackages (epkgs:
      # CONFIG setup
      [
        (runCommand "default.el" {} ''
          mkdir -p $out/share/emacs/site-lisp
          cp ${myEmacsConfig} $out/share/emacs/site-lisp/default.el
        '')
      ] ++

      # ELPA packages
      (with epkgs.elpaPackages; [
        undo-tree
      ]) ++

      (with epkgs.melpaPackages; [
        dired-subtree
        helm-flyspell
        terraform-doc
        undo-propose
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
        helm-projectile
        ivy
        mac-pseudo-daemon
        magit
        markdown-mode
        move-text
        nix-mode
        projectile
        smartparens
        terraform-mode
        use-package
        which-key
        yaml-mode
      ]));
  };
}
