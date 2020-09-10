{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {

    myProfile = pkgs.writeText "my-profile" ''
      export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/sbin:/bin:/usr/sbin:/usr/bin
      export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:/usr/share/man
      export IDEA_VM_OPTIONS=~/Library/Preferences/IntelliJIdea2019.3/idea.vmoptions
      export CL_HOME=~/Documents/work/corelogic

      function cdmkdir() {
        if [[ $# -ne 1 ]]; then
          echo "Usage: cdmkdir <dir>"
          exit 1
        fi
        mkdir -p $1
        cd $1
      }
    '';

    future-git = pkgs.writeShellScriptBin "future-git" ''
      function help {
        echo "Usage: $0 <hours> [<git args>]"
        exit 1
      }

      if [ $# -eq 0 ]; then
        help
      fi

      items=( "$@" )
      (for e in "''${items[@]}"; do [[ "$e" =~ ^(--)?help$ ]] && exit 0; done; exit 1) && help

      HOURS=4
      re='^[0-9]+$'
      if [[ $1 =~ $re ]]; then
        HOURS=$1
        shift
      fi

      DATE="$(date -d +''${HOURS}hours)"
      GIT_AUTHOR_DATE="''${DATE}" GIT_COMMITTER_DATE="''${DATE}" git "$@"
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

    java_home = pkgs.writeShellScriptBin "java_home" ''
      if [ "$#" -ne 2 ] || [ "$1" != "-v" ] || [ "$2" -lt 8 ]; then
        echo "Usage: $0 -v <version>";
        exit 1;
      fi
      JDK08_HOME="${pkgs.jdk}"
      JDK11_HOME="${pkgs.jdk11}"
      JDK14_HOME="${pkgs.jdk14}"
      case "$2" in
        8)
          JDK=$JDK08_HOME
          ;;
        11)
          JDK=$JDK11_HOME
          ;;
        *)
          JDK=$JDK14_HOME
          ;;
        esac
        echo "$JDK"
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

    sudo-with-touch = pkgs.writeShellScriptBin "sudo-with-touch" ''
      primary=$(cat /etc/pam.d/sudo | head -2 | tail -1 | awk '{$1=$1}1' OFS=",")
      if [ "auth,sufficient,pam_tid.so" != "$primary" ]; then
        newsudo=$(mktemp)
        awk 'NR==2{print "auth       sufficient     pam_tid.so"}7' /etc/pam.d/sudo > $newsudo
        sudo mv $newsudo /etc/pam.d/sudo
      fi
    '';

    myPackages = buildEnv {
      name = "my-packages";
      paths = [
        (runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/my-profile.sh
      '')

        #nix
        nix-prefetch-github
        nix-prefetch-scripts

        # custom
        future-git
        idownload
        java_home
        jqo
        jqj
        jqr
        sudo-with-touch

        # bash scripts
        argbash
        bash
        bash-boilerplate

        # cloud
        ansible
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
        nodePackages.prettier
        python38Packages.yamllint


        #scala
        sbt
        scala

        # general
        aspell
        bc
        coreutils
        direnv
        emacs
        #emscripten
        ffmpeg
        gdb
        go
        git
        hello
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

    kryptco.kr = stdenv.mkDerivation rec {
      name = "kr-${version}";
      version = "2.4.15";

      src = fetchFromGitHub {
        owner = "kryptco";
        repo = "kr";
        rev = "1937e31606e4dc0f7263133334d429f956502276";
        sha256 = "13ch85f1y4j2n4dbc6alsxbxfd6xnidwi2clibssk5srkz3mx794";
      };

      buildInputs = with pkgs; [ go ];

      makeFlags = [
        "PREFIX=$(out)"
        "GOPATH=$(out)/share/go"
        "GOCACHE=$(TMPDIR)/go-cache"
      ];

      preInstall = ''
        mkdir -p $out/share/go
      '';

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
        dtrt-indent
        terraform-doc
        undo-propose
      ]) ++

      # MELPA stable packages
      (with epkgs.melpaStablePackages; [
        ag
        browse-at-remote
        company
        company-terraform
        counsel
        crux
        expand-region
        flycheck
        format-all
        git-messenger
        git-timemachine
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
