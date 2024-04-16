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

(use-package nerd-icons
  :config
  ;; Download nerd-icons if directory not found
  (unless (car (file-expand-wildcards
		(concat user-emacs-directory "elpa/nerd-icons-*")))
    (nerd-icons-install-fonts t)))

(use-package doom-modeline
  :config (doom-modeline-mode 1)
  :custom
  (doom-modeline-buffer-file-name-style 'truncate-with-project "display project/./filename")
  (doom-modeline-buffer-encoding nil "dont care about UTF-8 badge")
  (doom-modeline-vcs-max-length 30 "limit branch name length")
  (doom-modeline-enable-word-count t "turn on wordcount"))

;; Builtin Emacs minor mode highlights line at point
(global-hl-line-mode 1)

;; Flash cursor location when switching buffers
(use-package beacon
  :config (beacon-mode 1))

;; Use bar for cursor instead of box
(defvar standard-cursor-type 'bar)
(setq-default cursor-type standard-cursor-type)

(defun jh/hollow-cursor-if-magit-blob-mode ()
  "Change cursor to hollow-box if viewing magit-blob file"
  (if magit-blob-mode
      (setq cursor-type 'hollow)
    (setq cursor-type standard-cursor-type)))

(add-hook 'magit-blob-mode-hook 'jh/hollow-cursor-if-magit-blob-mode)

;; Global minor mode to highlight thing under point
(use-package highlight-thing
  :demand t
  :hook (prog-mode org-mode)
  :custom
  (highlight-thing-exclude-thing-under-point t)
  (highlight-thing-all-visible-buffers t)
  (highlight-thing-case-sensitive-p t)
  (highlight-thing-ignore-list
	'("False" "True", "return", "None", "if", "else", "self",
	  "import", "from", "in", "def", "class")))

;; Builtin Emacs minor-mode shows column number in mode-line
(column-number-mode 1)

;; Hook builtin Emacs minor-mode to only display line numbers in prog-mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Do not ask if I want to kill a buffer (C-x C-k)
(setq kill-buffer-query-functions nil)

;; Kill current buffer instead of selecting it from minibuffer
(global-set-key (kbd "C-x M-k") 'kill-current-buffer)

(defun crm-indicator (args)
  "Add indicator to completion promp when using 'completing-read-multiple'"
  (cons (format "[CRM%s] %s"
		(replace-regexp-in-string
		 "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
		 crm-separator)
		(car args))
	(cdr args)))
(advice-add #'completing-read-multiple :filter-args #'crm-indicator)

(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

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
  :after (marginalia nerd-icons)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config (nerd-icons-completion-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package org
  :demand t
  :hook (;; Refresh inline images after executing scr-block
	 (org-babel-after-execute . (lambda () (org-display-inline-images nil t)))
	 ;; Cleanup whitespace when entering/exiting org-edit-src buffer
	 (org-src-mode . whitespace-cleanup))

  :custom
  ;; Org-Mode structure settings
  (org-hide-leading-stars t "Use org-modern bullets for header level")
  (org-startup-folded t     "Fold headers by default")
  (org-startup-indented t   "Align text vertically with header level")
  (org-adapt-indentation t  "Indent w.r.t. org-header level")

  ;; Text behavior settings
  (org-hide-emphasis-markers t "Remove =STR= emphasis markers")
  (org-special-ctrl-a/e t      "C-a/e jump to start/end of headline text")

  ;; Babel / Source code settings
  (org-confirm-babel-evaluate nil "Do not confirm src-block evaluation")
  (org-src-window-setup 'current-window "Use current buffer for src-context")
  (org-src-preserve-indentation t "Align src code with leftmost column")
  (org-src-ask-before-returning-to-edit-buffer t "Turn off prompt before edit buffer")

  ;; Figure settings
  (org-display-remote-inline-images 'cache "Allow inline display of remote images")
  (org-startup-with-inline-images t "Include images when opening org-file")

  ;; File path settings
  (org-link-file-path-type 'relative "Use relative links for org-insert-link")

  ;; Misc. settings
  ;; Cache error -- https://emacs.stackexchange.com/a/42014
  (org-element-use-cache nil "Turn off due to frequent error")
  (org-ellipsis "▾"          "Indicator for collapsed header")

  ;; ? speed-key opens Speed Keys help.
  (org-use-speed-commands
   ;; If non-nil, 'org-use-speed-commands' allows efficient
   ;; navigation of headline text when cursor is on leading
   ;; star. Custom function allows use of Speed keys if on ANY
   ;; stars.
   (lambda ()
     (and (looking-at org-outline-regexp)
	  (looking-back "^\**"))))

  :config
  ;; Improved vertical scrolling when images are present
  (use-package iscroll
    :hook (org-mode)))

;; Improve visuals by styling headlines, keywords, tables, etc
(use-package org-modern
  :after org
  :commands (org-modern-mode org-modern-agenda)
  :hook ((org-mode                 . org-modern-mode)
	 (org-agenda-finalize-hook . org-modern-agenda))
  :custom((org-modern-block-fringe 5)
	  (org-modern-star '("◉" "○" "●" "○" "●" "○" "●"))))

(use-package org-appear
  :hook (org-mode)
  :custom (org-appear-inside-latex t))

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

;;; init.el ends here
