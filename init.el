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

(use-package consult
  :bind (;; C-c bindings in `mode-specific-map'
	 ("C-c M-x" . consult-mode-command)
	 ("C-c h" . consult-history)
	 ("C-c k" . consult-kmacro)
	 ("C-c m" . consult-man)
	 ("C-c i" . consult-info)
	 ([remap Info-search] . consult-info)
	 ;; C-x bindings in `ctl-x-map'
	 ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
	 ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
	 ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
	 ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
	 ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
	 ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
	 ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
	 ;; Custom M-# bindings for fast register access
	 ("M-#" . consult-register-load)
	 ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
	 ("C-M-#" . consult-register)
	 ;; Other custom bindings
	 ("M-y" . consult-yank-pop)                ;; orig. yank-pop
	 ;; M-g bindings in `goto-map'
	 ("M-g e" . consult-compile-error)
	 ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
	 ("M-g g" . consult-goto-line)             ;; orig. goto-line
	 ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
	 ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
	 ("M-g m" . consult-mark)
	 ("M-g k" . consult-global-mark)
	 ("M-g i" . consult-imenu)
	 ("M-g I" . consult-imenu-multi)
	 ;; M-s bindings in `search-map'
	 ("M-s d" . consult-find)                  ;; Alternative: consult-fd
	 ("M-s c" . consult-locate)
	 ("M-s g" . consult-grep)
	 ("M-s G" . consult-git-grep)
	 ("M-s r" . consult-ripgrep)
	 ("M-s l" . consult-line)
	 ("M-s L" . consult-line-multi)
	 ("M-s k" . consult-keep-lines)
	 ("M-s u" . consult-focus-lines)
	 ;; Isearch integration
	 ("M-s e" . consult-isearch-history)
	 :map isearch-mode-map
	 ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
	 ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
	 ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
	 ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
	 ;; Minibuffer history
	 :map minibuffer-local-map
	 ("M-s" . consult-history)                 ;; orig. next-matching-history-element
	 ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
	register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
	xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
)

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
