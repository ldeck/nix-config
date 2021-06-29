{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {

    myNix = pkgs.callPackage ./custom/nix { pkgs = pkgs; };

    myApps = pkgs.callPackage ./custom/apps { pkgs = pkgs; };

    myPackages = buildEnv {
      name = "my-packages";
      paths = [
        #nix
        niv
        nixfmt
        nix-prefetch-github
        nix-prefetch-scripts
        undmg
        styx

        # bash scripts
        argbash
        bash

        # cloud
        ansible
        # aws-sam-cli
        awscli2
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
        visualvm

        # js
        nodejs-14_x
        yarn

        #node packages
        nodePackages.node2nix
        nodePackages.prettier

        # devtools
        geckodriver
        liquibase
        myEmacs
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
        maven
        nginx
        #nixops
        nox
        perl
        ripgrep
        silver-searcher
        taskwarrior
        tree
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
    # editor derivations
    # =======================

    myEmacsConfig = ./overlays/pkgs/emacs;
    myBaseDir = "${toString ./..}";

    myEmacs = emacsWithPackages (epkgs:
      # CONFIG setup
      [
        (runCommand "default.el" {} ''
          mkdir -p $out/share/emacs/site-lisp
          cp ${myEmacsConfig}/*.el $out/share/emacs/site-lisp/

          if [ -d ${myBaseDir}/custom/emacs ]; then
            mkdir -p $out/share/emacs/site-lisp/custom
            cp ${myBaseDir}/custom/emacs/*.el $out/share/emacs/site-lisp/custom/
          fi
        '')
      ] ++

      # ELPA packages
      (with epkgs.elpaPackages; [
        undo-tree
      ]) ++

      (with epkgs.melpaPackages; [
        company
        company-terraform
        # counsel
        dap-mode
        dired-subtree
        direnv
        docker
        docker-compose-mode
        dockerfile-mode
        dtrt-indent
        dumb-jump
        editorconfig
        editorconfig-custom-majormode
        editorconfig-domain-specific
        editorconfig-generate
        expand-region
        flycheck
        flycheck-plantuml
        forge
        gitlab-ci-mode
        gitlab-ci-mode-flycheck
        helm-flyspell
        helm-lsp
        hydra
        ivy
        lsp-java
        lsp-metals
        lsp-mode
        lsp-treemacs
        lsp-ui
        magit
        plantuml-mode
        sbt-mode
        scala-mode
        symbol-overlay
        terraform-doc
        undo-propose
        vterm
        yasnippet
      ]) ++

      # MELPA stable packages
      (with epkgs.melpaStablePackages; [
        ag
        browse-at-remote
        crux
        expand-region
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
