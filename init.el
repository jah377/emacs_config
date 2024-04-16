;;; -*- lexical-binding: t -*-

;; Initialize package resources
(setq package-archives
      '(("gnu elpa"  . "https://elpa.gnu.org/packages/")
	("melpa"     . "https://melpa.org/packages/")
	("nongnu"    . "https://elpa.nongnu.org/nongnu/"))
      package-archive-priorities
      '(("melpa"    . 6)
	("gnu elpa" . 5)
	("nongnu"   . 4)))

;; Is this still necessary since 'use-package' now builtin?
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Standardize `use-package` settings
(require 'use-package-ensure)
(setq use-package-always-ensure t)
(setq use-package-compute-statistics t)
(setq use-package-verbose t)

;; Uncomment to refresh packages everytime Emacs starts
;; (package-refresh-contents t)

;; Keep 'user-emacs-directory' tidy
(use-package no-littering
  :demand t

  :config
  ;; Save customizations in 'etc' sub-directory
  ;; https://github.com/emacscollective/no-littering
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))

  ;; Load file
  (when (file-exists-p custom-file)
    (load custom-file)))

;; Minimize GC interference
(use-package gcmh
  :init (gcmh-mode 1)
  :hook
  ;; Perform GC at the end of startup
  (after-init . garbage-collect)
  ;; Reset GC params after loading startup (after init-hook)
  (emacs-startup . (lambda ()
		     (setq gc-cons-percentage 0.1
			   gcmh-high-cons-threshold (* 32 1024 1024)
			   gcmh-idle-delay 30))))

;; Disable theme before loading to avoid funkiness
(defadvice load-theme (before disable-themes-first activate)
  (mapc #'disable-theme custom-enabled-themes))

(use-package doom-themes
  :custom
  ;; Some themes do not have italics
  (doom-themes-enable-bold t "default")
  (doom-themes-enable-italic t "default")
  (doom-themes-padded-modeline t "pad modeline for readability")

  :config
  ;; Indicate errors by flashing modeline
  (doom-themes-visual-bell-config)
  ;; correct (and improve) org-mode native fontification
  (doom-themes-org-config))

(defun jh/light ()
  "Turn on light theme."
  (interactive)
  (load-theme 'doom-tomorrow-day t))

(defun jh/dark ()
  "Turn on dark theme."
  (interactive)
  (load-theme 'doom-one t))

;; Use light theme on startup
(add-hook 'after-init-hook (lambda () (jh/dark)))

(set-face-attribute 'default nil
                    :font "JetBrains Mono"
                    :height 100
                    :weight 'medium)


;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil
                    :font "JetBrains Mono"
                    :height 100
                    :weight 'medium)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil
                    :font "JetBrains Mono"
                    :height 100
                    :weight 'medium)

;; Mini-buffer completion
(use-package vertico
  :init (vertico-mode 1)
  :custom (vertico-cycle t "Cyle to top of list"))

;; Save minibuffer history for 'Vertico'
(use-package savehist
  :init (savehist-mode 1))

;; Provides additional data to mini-buffer completion
(use-package marginalia
  ;; Same reason as 'vertico' and 'savehist'
  :init (marginalia-mode 1))

;; Add nerd-icons to mini-buffer marginalia
(use-package nerd-icons-completion
  :after marginalia
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config (nerd-icons-completion-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package magit
  :bind ("C-x g" . magit-status)
  :diminish magit-minor-mode
  :hook (git-commit-mode . (lambda () (setq fill-column 72)))
  :mode ("/\\.gitmodules\\'" . conf-mode)
  :custom
  ;; hide ^M chars at the end of the line when viewing diffs
  (magit-diff-hide-trailing-cr-characters t)

  ;; Limit legth of commit message summary
  (git-commit-summary-max-length 50)

  ;; Open status buffer in same buffer
  (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1))

(use-package git-gutter
  :hook (prog-mode org-mode)
  :bind (("C-x P" . git-gutter:previous-hunk)
	 ("C-x N" . git-gutter:next-hunk)
	 ("C-x G" . git-gutter:popup-hunk))
    :config
    ;; Must include if 'linum-mode' activated (common in 'prog-mode')
    ;; because 'git-gutter' does not work with 'linum-mode'.
    (use-package git-gutter-fringe
      :commands git-gutter-mode
      :config (global-git-gutter-mode)))
