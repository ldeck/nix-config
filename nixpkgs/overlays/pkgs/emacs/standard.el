;;; standard.el --- standard packages configuration

;;; Commentary:
;;

;;; Code:
;;

;; functions

(defun with-ldeck-magit-mode-customisations ()
  "Add custom magit popup and transient switch."
  (interactive)
  (transient-append-suffix 'magit-commit "a"
    '("n" "Reshelve commit" magit-commit-reshelve))
  (transient-append-suffix 'magit-rebase "s"
    '("t" "Reshelve since" magit-reshelve-since))
  (transient-append-suffix 'magit-push "-n"
    '("=O" "Set extra push option #1" "--push-option=" read-from-minibuffer))
  (transient-append-suffix 'magit-push "-n"
    '("=P" "Set extra push option #2" "--push-option=" read-from-minibuffer))
  (transient-append-suffix 'magit-push "-n"
    '("-S" "Skip gitlab pipeline creation" "--push-option=ci.skip"))
  )


;; load some packages
(use-package undo-tree
  :config (global-undo-tree-mode))

(use-package docker
  :ensure t
  :bind ("C-c D" . docker))

(use-package dockerfile-mode
  :ensure t
  :mode ("Dockerfile\\'" . dockerfile-mode))

(use-package docker-compose-mode)

(use-package browse-at-remote
  :ensure t
  :commands browse-at-remote
  :bind ("C-c g r" . browse-at-remote))

(use-package company
  :defer 1
  :bind ("<C-tab>" . company-complete)
  :diminish company-mode
  :commands (company-mode global-company-mode)
  :init (setq company-dabbrev-downcase nil)
  :config (global-company-mode))

;; (use-package counsel
;;   :commands (counsel-descbinds)
;;   :bind (([remap execute-extended-command] . counsel-M-x)
;;          ("C-x C-f" . counsel-find-file)
;;          ("C-c g f" . counsel-git)
;;          ("C-c j" . counsel-git-grep)
;;          ("C-c k" . counsel-ag)
;;          ("C-x l" . counsel-locate)
;;          ("M-y" . counsel-yank-pop)))

(use-package crux
  :ensure t
  :bind
  ("C-S-k" . crux-smart-kill-line)
  ("C-c d" . crux-duplicate-current-line-or-region)
  ("C-c n" . crux-cleanup-buffer-or-region)
  ("C-c f" . crux-recentf-find-file)
  ("C-a" . crux-move-beginning-of-line))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("i" . dired-subtree-insert)
              (";" . dired-subtree-remove)
              ("<tab>" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle)))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package expand-region
  :ensure t
  :bind ("M-m" . er/expand-region))

(use-package flycheck
  :defer 2
  :config (global-flycheck-mode))

(use-package forge
  :ensure t
  :after magit
  :config
  (setq forge-owned-accounts '())
  (let ((accounts (remove nil
                          (list
                           (getenv "FORGE_OWNED_ACCOUNTS")
                           (getenv "USER")))))
    (if accounts
        (progn
          (message "Configuring forge-owned-accounts: %s" accounts)
          (add-to-list 'forge-owned-accounts accounts)
          ))))

(use-package forge-custom
  :after forge
  :if (file-readable-p "~/.config/custom/forge-custom.el")
  :ensure nil
  :load-path "~/.config/custom/")

(use-package format-all)

(use-package git-messenger
  :ensure t
  :commands git-messenger:popup-message
  :bind (("C-c g m" . git-messenger:popup-message))
  :config
  (setq git-messenger:show-detail t))

(use-package git-timemachine
  :ensure t)

(use-package helm
  :defer 2
  :config
  ;;(helm-mode 1)
  (require 'helm-config)


  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-h f") 'helm-apropos)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x b") 'helm-mini)
  (global-set-key (kbd "C-c y") 'helm-show-kill-ring)
  (global-set-key (kbd "C-x C-r") 'helm-recentf))

(use-package helm-descbinds
  :after (helm)
  :commands helm-descbinds
  :config
  (global-set-key (kbd "C-h b") 'helm-descbinds))


(use-package helm-flyspell
  :after (helm)
  :commands helm-flyspell-correct
  :config (global-set-key (kbd "C-;") 'helm-flyspell-correct))

;; (use-package helm-projectile
;;		:after (helm projectile)
;;		:commands helm-projectile
;;		:config
;;		  (global-set-key (kbd "C-x c p") 'helm-projectile))

(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :config
  (helm-projectile-on))

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
         ("C-x G" . magit-dispatch))
  :init (setq magit-completing-read-function 'ivy-completing-read)
  :hook (magit-mode . with-ldeck-magit-mode-customisations))

(use-package markdown-mode
  :mode ("\\.markdown\\'" "\\.md\\'"))

(use-package move-text
  :defer 1
  :config (move-text-default-bindings))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package projectile
  :commands projectile-mode
  :bind-keymap ("C-c p" . projectile-command-map)
  :defer 5
  :config
  (projectile-mode)
  (setq projectile-switch-project-action 'projectile-find-file)
  (projectile-register-project-type 'yarn '("package.json" "yarn.lock")
                                  :compile "yarn install"
                                  :test "yarn test"
                                  :run "yarn start"
                                  :test-suffix ".test")
  )

(use-package plantuml-mode
  :mode "\\.puml\\'"
  :init
  (setq plantuml-executable-path (locate-file "plantuml" exec-path))
  (setq plantuml-default-exec-mode 'executable)
  )

(use-package dtrt-indent
  :ensure t
  :config
  (autoload 'dtrt-indent-mode "dtrt-indent" "Adapt to foreign indentation offsets" t)
  (add-hook 'c-mode-common-hook 'dtrt-indent-mode))

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode 1)
    (show-paren-mode t)))

(use-package terraform-mode
  :init
  (add-hook 'terraform-mode-hook #'terraform-format-on-save-mode))

(use-package undo-propose
  :commands undo-propose
  :defer 1
  :init
  :bind ("C-c u" . undo-propose))

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode +1))

(use-package yaml-mode
  :mode ("\\.yml$" "\\.yaml$")
  :init
  (add-hook 'yaml-mode-hook (lambda () (electric-indent-local-mode -1))))


(provide 'standard)

;;; standard.el ends here