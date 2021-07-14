;;; default --- ldeck emacs config
;;; Commentary:
;; config managed by use-package
;;; Code:
;; general options

;; Minimize startup time
(defvar handler-alist-bak file-name-handler-alist)

(setq gc-cons-threshold most-positive-fixnum
      file-name-handler-alist nil)

(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; Restore defaults after startup
;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (expt 2 23)
                  file-name-handler-alist handler-alist-bak
                  handler-alist-bak nil
                  )))

(server-start)


;; default editor config
(add-hook 'before-save-hook 'whitespace-cleanup)
(delete-selection-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t)
(setq-default indent-tabs-mode nil)
(tool-bar-mode -1)

;; default theme
(load-theme 'wombat t)
(set-cursor-color "#00F900")
(add-to-list 'default-frame-alist '(cursor-color . "#00F900"))

;; set path
;;(add-to-list 'exec-path (expand-file-name "~/.nix-profile/bin"))
;;(setenv "PATH" (mapconcat 'identity exec-path ":"))

;; disable audible bell
(defun ldeck-flash-mode-line ()
  "Ignore audible bell and flash the mode line instead."
  (let ((orig-fg (face-foreground 'mode-line)))
          (set-face-foreground 'mode-line "#F2804F")
          (run-with-idle-timer 0.1 nil
                               (lambda (fg) (set-face-foreground 'mode-line fg))
                               orig-fg)))

(setq visible-bell nil ring-bell-function 'ldeck-flash-mode-line)


;; initialize package
;; (package-initialize 'noactivate)
(package-initialize t)

;; directories and files
(defvar base-dir (file-name-directory load-file-name)
  "The root dir of this nix Emacs distribution.")

(defvar custom-dir (expand-file-name "custom" base-dir)
  "The root dir for user custom packages.")

(defvar standard-modules-file (expand-file-name "standard.el" base-dir)
  "The file containing standard packages configuration.")


;; load standard packages
(when (file-exists-p standard-modules-file)
  (message "Loading standard module files in %s..." standard-modules-file)
  (load standard-modules-file))


;; load the user's custom modules from `custom-dir'
(when (file-exists-p custom-dir)
  (message "Loading custom module files in %s..." custom-dir)
  (mapc 'load (directory-files custom-dir 't "^[^#\.].*\\.el$")))

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq
 backup-directory-alist `((".*" . ,temporary-file-directory))
 auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

(provide 'default)

;;; default.el ends here
