{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {

    myProfile = pkgs.writeText "my-profile" ''
      export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/sbin:/bin:/usr/sbin:/usr/bin
      export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:/usr/share/man
      export IDEA_VM_OPTIONS=~/Library/Preferences/IntelliJIdea2019.3/idea.vmoptions
    '';
    
    myPackages = with pkgs; buildEnv {
      name = "my-packages";
      paths = [
        (runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/my-profile.sh
        '')
	# bash scripts
	argbash
	bash
	bash-boilerplate

	# cloud
	cloudfoundry-cli
	google-cloud-sdk
	terraform

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
	jdk11
	jq
	jump
	kotlin
	kryptco.kr
	maven
	nixops
	nox
	perl
	scala
	silver-searcher
	taskwarrior
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
    # editor derivations
    # =======================

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

      # MELPA packages
      (with epkgs.melpaStablePackages; [
        ag
      	company
      	counsel
      	flycheck
      	ivy
      	mac-pseudo-daemon
      	magit
      	markdown-mode
      	move-text
      	projectile
      	undo-propose
      	use-package
      	yaml-mode
      ]));

    myEmacsConfig = writeText "default.el" ''
      ;; general options
      (tool-bar-mode -1)
      (server-start)
      
      ;; initialize package
      (require 'package)
      (package-initialize 'noactivate)
      (eval-when-compile
        (require 'use-package))
      
      ;; load some packages
      (use-package undo-tree
        :config (global-undo-tree-mode))

      (use-package company
        :bind ("<C-tab>" . company-complete)
        :diminish company-mode
        :commands (company-mode global-company-mode)
        :defer 1
	:init (setq company-dabbrev-downcase nil)
        :config (global-company-mode))
      
      (use-package counsel
        :commands (counsel-descbinds)
        :bind (([remap execute-extended-command] . counsel-M-x)
          ("C-x C-f" . counsel-find-file)
          ("C-c g" . counsel-git)
          ("C-c j" . counsel-git-grep)
          ("C-c k" . counsel-ag)
          ("C-x l" . counsel-locate)
          ("M-y" . counsel-yank-pop)))
      
      (use-package flycheck
        :defer 2
        :config (global-flycheck-mode))
      
      (use-package ivy
        :defer 1
        :bind (("C-c C-r" . ivy-resume)
        	 ("C-x C-b" . ivy-switch-buffer)
        	 :map ivy-minibuffer-map
      	 ("C-j" . ivy-call))
        :diminish ivy-mode
        :commands ivy-mode
        :config (ivy-mode 1))
      
      (use-package magit
        :defer
        :if (executable-find "git")
        :bind (("C-x g" . magit-status)
        	 ("C-x G" . magit-dispatch-popup))
        :init
        (setq magit-completing-read-function 'ivy-completing-read))
      
      (use-package markdown-mode
        :mode ("\\.markdown\\'" "\\.md\\'"))

      (use-package move-text
        :defer 1
        :config (move-text-default-bindings))

      (use-package projectile
        :commands projectile-mode
        :bind-keymap ("C-c p" . projectile-command-map)
        :defer 5
        :config
        (projectile-global-mode))

      (use-package undo-propose
        :commands undo-propose
	:defer 1
	:init
	:bind ("C-c u" . undo-propose))

      (use-package yaml-mode
        :mode ("\\.yml$" "\\.yaml$"))
    '';	  
  };
}