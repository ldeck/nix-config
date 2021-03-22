{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {

    myProfile = pkgs.writeText "my-profile" ''
      export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/sbin:/bin:/usr/sbin:/usr/bin
      export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:/usr/share/man
      export IDEA_VM_OPTIONS=~/Library/Preferences/IntelliJIdea2019.3/idea.vmoptions

      function cdmkdir() {
        if [[ $# -ne 1 ]]; then
          echo "Usage: cdmkdir <dir>"
          exit 1
        fi
        mkdir -p $1
        cd $1
      }
    '';

    app-path = pkgs.writeShellScriptBin "app-path" ''
      color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1
      echoerr() { echo "$@" 1>&2; }
      function indented() {
          (set -o pipefail; { "$@" 2>&3 | sed >&2 's/^/   | /'; } 3>&1 1>&2 | perl -pe 's/^(.*)$/\e[31m   | $1\e[0m/')
      }
      function join_by { local d=$1; shift; local f=$1; shift; printf %s "$f" "''${@/#/$d}"; }
      function usage {
        echo "Usage: app-path fuzzyname..."
        exit 1
      }
      [[ $# -lt 1 ]] && usage

      LOCATIONS=( "$HOME/.nix-profile/Applications" "$HOME/.nix-profile/Applications/Utilities" "$HOME/Applications" "$HOME/Applications/Utilities" "/Applications" "/Applications/Utilities" "/System/Applications" "/System/Applications/Utilities" )
      MATCHER=$(join_by '.*' "$@")

      APP=""
      for l in "''${LOCATIONS[@]}"; do
        if ! [ -d $l ]; then
          continue;
        fi
        NAME=$(ls "$l" | grep -i "$MATCHER")
        COUNT=$(echo "$NAME" | grep -v -e '^$' | wc -l)
        if [[  $COUNT -gt 1 ]]; then
          color echoerr "Matches:"
          indented echoerr "$NAME"
          usage
        fi
        if [[ $COUNT -eq 1 ]]; then
          APP="$l/$NAME"
          break
        fi
      done
      if [ -z "$APP" ]; then
        usage
      else
        echo "$APP"
      fi
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
      JDK08_HOME="${pkgs.jdk8}"
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

    nix-link-macapps = pkgs.writeShellScriptBin "nix-link-macapps" ''
      #see https://raw.githubusercontent.com/matthewbauer/macNixOS/master/link-apps.sh
      NIX_APPS="$HOME"/.nix-profile/Applications
      APP_DIR="$HOME"/Applications

      # create links
      pushd "$APP_DIR" > /dev/null
      find "$NIX_APPS" -type l -exec ln -fs {} . ';'
      popd > /dev/null

      # remove broken links
      find -L "$APP_DIR" -type l -exec rm -- {} +
    '';

    nix-open = pkgs.writeShellScriptBin "nix-open" ''
      function usage {
        echo "Usage: nix-open application [args...]"
        exit 1
      }
      [[ $# -lt 1 ]] && usage
      NAME=$1; shift
      APP=$(${app-path}/bin/app-path "$NAME")
      if [ -z "$APP" ]; then
        usage
      else
        open -a "$APP" "$@"
      fi
    '';

    nix-reopen = pkgs.writeShellScriptBin "nix-reopen" ''
      function usage {
        echo "Usage: nix-reopen application [args...]"
        exit 1
      }
      [[ $# -lt 1 ]] && usage
      LOCATIONS=( "~/.nix-profile/Applications" "~/Applications" "/Applications" )
      NAME=$1
      APP=$(${app-path}/bin/app-path "$NAME")
      if [ -z "$APP" ]; then
        usage
      else
        PNAME=$(defaults read "$APP/Contents/Info" CFBundleExecutable)
        PIDSCOUNT=$(pgrep -i "$PNAME" | wc -l)
        if [[ $PIDSCOUNT -ne 0 ]]; then
          pkill -QUIT -i "$PNAME"
        fi
        ${nix-open}/bin/nix-open "$@"
      fi
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
        undmg
        styx

        # custom
        app-path
        future-git
        idownload
        java_home
        jqo
        jqj
        jqr
        nix-open
        nix-reopen
        nix-link-macapps
        sudo-with-touch

        # bash scripts
        argbash
        bash

        # cloud
        ansible
        cloudfoundry-cli
        google-cloud-sdk
        cloud-sql-proxy
        terraform

        # containers
        kubectl
        fluxctl

        #go
        vgo2nix

        # java
        jdk11
        visualvm

        # js
        nodejs-14_x
        yarn

        # devtools
        geckodriver
        nodePackages.node2nix
        nodePackages.prettier
        plantuml
        python38Packages.yamllint

        #net
        #nss-cacert
        openconnect

        #scala
        sbt
        scala
        mill

        # general
        asciinema
        aspell
        bc
        clang
        coreutils
        direnv
        emacs
        #emscripten
        fd
        ffmpeg
        gdb
        gnupg
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
        #nixops
        nox
        perl
        ripgrep
        silver-searcher
        taskwarrior
        #yq
      ];
      pathsToLink = [ "/share/man" "/share/doc" "/bin" "/etc" "/Applications" ];
      extraOutputsToInstall = [ "man" "doc" ];
    };

    # =======================
    # bash script derivations
    # =======================

    bashew = stdenv.mkDerivation rec {
      name = "bashew-${version}";
      version = "v1.8.2";
      src = fetchFromGitHub {
        owner = "pforret";
        repo = "bashew";
        rev = "0c8d99b10f11fe7fb125b9885ae0036f5d8e7ca0";
        sha256 = "0jqgrpbjxx79qydfb472xnizbmg7r379imp5ppmdlfdsqdf83m0g";
      };
      installPhase = ''
        mkdir -p $out/bin;
        cp bashew.sh $out/bin/bashew;
        chmod +x $out/bin/bashew;
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
        company
        company-terraform
        counsel
        docker
        dockerfile-mode
        docker-compose-mode
        editorconfig
        editorconfig-custom-majormode
        editorconfig-domain-specific
        editorconfig-generate
        flycheck-plantuml
        dired-subtree
        dumb-jump
        forge
        gitlab-ci-mode
        gitlab-ci-mode-flycheck
        helm-flyspell
        ivy
        dtrt-indent
        magit
        plantuml-mode
        terraform-doc
        undo-propose
      ]) ++

      # MELPA stable packages
      (with epkgs.melpaStablePackages; [
        ag
        browse-at-remote
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
        mac-pseudo-daemon
        markdown-mode
        move-text
        nix-mode
        projectile
        smartparens
        terraform-mode
        use-package
        which-key
        yaml-mode
        zoom-window
      ]));
  };
}
