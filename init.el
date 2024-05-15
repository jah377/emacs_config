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

(use-package which-key
  :config (which-key-mode)
  :custom
  (which-key-show-early-on-C-h t     "Trigger which-key manually")
  (which-key-idle-delay 0.5          "Delay before popup appears")
  (which-key-idle-second-delay 0.05  "Responsiveness after triggered")
  (which-key-popup-type 'minibuffer  "Where to show which-key")
  (which-key-max-display-columns nil "N-cols determined from monotor")
  (which-key-separator " → "         "ex: C-x DEL backward-kill-sentence")
  (which-key-add-column-padding 1    "Padding between columns of keys")
  (which-key-show-remaining-keys t   "Show count of keys in modeline"))

;; Collection of useful keybindings
(use-package crux
  :bind (([remap move-beginning-of-line] . 'crux-move-beginning-of-line)
         ([remap kill-whole-line] . 'crux-kill-whole-line)
         ("M-o" . 'crux-switch-to-previous-buffer)
         ("C-<backspace>" . 'crux-kill-line-backwards)
         ("C-c 3" . 'crux-view-url)))

;; 'Find-File-At-Point' package adds additional functionality to
;; existing keybindings
(ffap-bindings)

;; Close all other windows
(global-set-key (kbd "C-x O") (lambda ()
                                (interactive)
                                (select-window (get-mru-window t t t))))

(global-set-key (kbd "C-c l") 'org-store-link)

(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

(global-set-key (kbd "C-c C-;") 'copy-comment-region)

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

(setq
 c-default-style "linux"
 c-basic-offset 4
 tab-width 4)

;; set indentation for enriched text
(setq-default standard-indent 4)

;; use tab for auto-complete selection
(setq-default tab-always-indent 'complete)

;; prevent extraneous tabs -- affects TeX
(setq-default indent-tabs-mode nil)

;; Builtin Emacs minor-mode wraps long text to next line
(global-visual-line-mode 1)

;; Builtin Emacs variable highlights empty lines
(setq indicate-empty-lines t)

;; Visualize whitespace and remove on cleanup
(use-package whitespace
  :hook ((prog-mode . whitespace-mode)
         (before-save . whitespace-cleanup))
  :custom
  (whitespace-line-column 79)
  (whitespace-style '(face trailing lines-tail empty
                           indentation::space space-before-tab::tab))
  :config
  ;; Turn off global whitespace mode
  (global-whitespace-mode 0))

;; Unique buffers of identical files denoted with parent directory name
(setq uniquify-buffer-name-style 'forward)

;; Change frame title to buffer name
(setq frame-title-format
      '("Emacs: " (:eval (if (buffer-file-name)
                             (abbreviate-file-name (buffer-file-name)) "%b"))))

;; Builtin Emacs minor-mode overwrites active region when typing/pasting
(delete-selection-mode 1)

;; Builtin Emacs mode inserts closing delimiter upon typing an open delimiter
(electric-pair-mode 1)

;; Prevent "())" if hitting ")" after 'electric-pair-mode' completes "()"
(setq electric-pair-skip-self t)

;; Builtin Emacs mode highlights matching delimiter pairs
(show-paren-mode 1)
(setq-default show-paren-style 'parenthesis ;; Highlight delimiters, not contents
              show-paren-when-point-in-periphery t) ;; Highlight even if ws present

;; Do not ask if I want to kill a buffer (C-x C-k)
(setq kill-buffer-query-functions nil)

;; Kill current buffer instead of selecting it from minibuffer
(global-set-key (kbd "C-x M-k") 'kill-current-buffer)

;; Enable recursive minibuffers
(setq enable-recursive-minibuffers t)

;; Mini-buffer completion
(use-package vertico
  :init (vertico-mode 1)
  :custom (vertico-cycle t "Cyle to top of list"))

;; Save minibuffer history for 'Vertico'
(use-package savehist
  :init (savehist-mode 1))

;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

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

;; Closes minibuffer regardless of point location
(advice-add 'keyboard-quit :before (lambda ()
                                     (when (active-minibuffer-window)
                                       (abort-recursive-edit))))

(defun jh/jump-to-minibuffer ()
  "Move point to minibuffer."
  (interactive)
  (when-let ((minibuffer-window (active-minibuffer-window)))
    (select-window minibuffer-window)))

(use-package org
  :demand t
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
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

  ;; TODO :: use yassnippet instead
  (org-structure-template-alist '(("c" . "comment")
                                  ("q" . "quote")
                                  ("p" . "src python")
                                  ("P" . "src python :results silent")
                                  ("e" . "src emacs-lisp")))

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

;; Constant simplifies file paths used by 'org-capture-template'
(defconst jh/agenda-dir "~/agenda/")
(defconst jh/agenda-path-work (concat jh/agenda-dir "work.org"))
(defconst jh/agenda-path-meetings (concat jh/agenda-dir "meetings.org"))
(defconst jh/agenda-path-personal (concat jh/agenda-dir "personal.org"))

;; Temp buffers always start with '.#'; exclude from 'org-agenda-files'
(setq org-agenda-files (directory-files jh/agenda-dir t "^[^.#].*\\.org$"))

;; Open 'org-agenda' buffer in current buffer
(setq org-agenda-window-setup 'current-window)
(setq org-agenda-restore-windows-after-quite t)

;; ;; Set block separator in agenda mode
;; (setq org-agenda-block-separator 8411)
;; (setq org-agenda-start-with-log-mode t)

;; @ to record timestamp; /! to record note
(setq org-todo-keywords
             '((sequence
               "TODO(t@/!)"      ;; Initiate task
               "ACTIVE(a@/!)"    ;; Task in progress
               "WAITING(w@/!)"   ;; Wait for event related to task
               "HOLD(h@/!)"      ;; Task on hold
               "|" "DONE(d!)" "CANCELLED(x@/!)")))

;; By default, 'org-todo' cycles through todo keywords in the sequence
;; defined above. The following changes the behavior to intead open a
;; menu containing fast-access keys.
(setq org-use-fast-todo-selection t)

;; Store timestamps and log notes into a drawer
(setq org-log-into-drawer t)

;; Store logs chronologically -- earliest log at the top of notes
(setq org-log-states-order-reversed nil)

;; (use-package org-fancy-priorities
;;   :after org
;;   :hook org-mode
;;   :custom
;;   (org-fancy-priorities-list '("📕" "📙" "📒")))

;; Return checkbox statistics only for direct todo child header
(setq org-checkbox-hierarchical-statistics t)

;; Remove tags from agenda-view
(setq org-agenda-hide-tags-regexp ".*")

;; Update tag alignment after updating header text
(setq org-auto-align-tags t)

;; My intention is for tags to be context-specific and therefore
;; defined in the #+TAGS file property header. With that said, some
;; tags should persist across all org-agenda files.
(setq org-tag-alist '(("project" . ?P)))


;; Childen task headers should inherit project-level tags, excluding
;; 'project'. This will make it easier to track project tasks in the
;; org-agenda view.
(setq org-use-tag-inheritance t)
(add-to-list 'org-tags-exclude-from-inheritance "project")

(setq org-capture-templates
      '(("m" "Work Meeting" entry (file jh/agenda-path-meetings)
         "* %^{Meeting Title} %^g
:PROPERTIES:
:created: %U
:project: %?
:attendees:
:purpose: %^{Purpose of meeting}
:END:\n\n"
         :empty-lines 1)

      ("p" "Work Project" entry (file jh/agenda-path-work)
         "* TODO %^{Header text} [/] %^g:project:
:PROPERTIES:
:repo:
:category:
:END:
:LOGBOOK:
- State \"TODO\"       from              %U \\\
  %?
:END:"
         :empty-lines 1
         :jump-to-captured t)

      ("t" "Work Task" entry (file jh/agenda-path-work)
         "* TODO %^{Header text} %^g
:PROPERTIES:
:repo:
:category:
:END:
:LOGBOOK:
- State \"TODO\"       from              %U \\\
  %?
:END:"
         :empty-lines 1)

      ("l" "Personal Learning" entry (file jh/agenda-path-personal)
         "* TODO %^{Header text} %^g
:LOGBOOK:
- State \"TODO\"       from              %U \\\
  %?
:END:"
         :empty-lines 1
         :jump-to-captured t)))

(use-package org-ql
  :ensure t
  :defer t
  :after org)

(defun extract-header-names (org-filepath)
  "Return names of top-level org-headers in ORG-FILEPATH."
  (defun remove-checkbox-stats (element)
    "Remove [/] or [%] stats from name of ELEMENT"
    (replace-regexp-in-string " \\[.*?\\]$" ""
                              (org-element-property :raw-value element)))
  ;; 'org-filepath' must exist and readable
  (unless (file-readable-p org-filepath)
    (error "Org file %s is not readable or does not exist." org-filepath))
  (mapcar 'remove-checkbox-stats
          (org-ql-select org-filepath
            '(level 1)
            :action 'element-with-markers)))

(use-package org-super-agenda
  :defer t
  :after org
  :hook (org-agenda-mode . org-super-agenda-mode)
  :config
  (set-face-attribute 'org-super-agenda-header nil :weight 'bold))

;; (setq org-agenda-custom-commands
;;       '(;; Return org-headers containing children tasks (ie projects)
;;         ("w" "Ongoing Work Projects"
;;          ((todo "" ((org-agenda-overriding-header "Work Projects")
;;                     (org-agenda-files '("~/agenda/work.org"))
;;                     (org-super-agenda-groups
;;                      '((:name none ;; Disble super group header
;;                               :children t)
;;                        (:discard (:anything t))))))))))

;; (setq org-agenda-custom-commands
;;       '(("s" "Project Summary View"
;;          ((alltodo "" ((org-agenda-overriding-header "")
;;                        (org-super-agenda-groups
;;                         '((:name "MLPScore-Motor"
;;                                  :tag "motor"
;;                                  :auto-property "ProjectId"
;;                                  :order 10)
;;                           (:name "MLPScore-Home"
;;                                  :tag "home"
;;                                  :auto-property "ProjectId"
;;                                  :order 12)
;;                           (:name "AF-Robovisor"
;;                                  :tag "robovisor"
;;                                  :auto-property "ProjectId"
;;                                  :order 14)
;;                           (:name "MLP Emacs Config"
;;                                  :tag "config"
;;                                  :auto-property "ProjectId"
;;                                  :order 13)
;;                           (:name "Enrichments"
;;                                  :tag "enrichments"
;;                                  :auto-property "ProjectId"
;;                                  :order 15)
;;                           (:name "MLP-Docs"
;;                                  :tag "mlpdocs"
;;                                  :auto-property "ProjectId"
;;                                  :order 30)))))))))

;; (use-package org
;;   :after consult
;;   :bind (("C-c a" . org-agenda)
;;          ("C-c A" . consult-org-agenda))
;;   :custom
;;   (org-agenda-files '("~/agenda/"))
;;   (org-agenda-window-setup 'current-window "Open in same window as called")
;;   (org-agenda-restore-windows-after-quit t "Keep window format after quit")
;;   (org-agenda-block-separator 8411         "Separator character")
;;   (org-use-fast-todo-selection t "Select todo keywords from menu")
;;   (org-log-into-drawer t         "Collapse log entries into drawer under task")
;;   (org-agenda-start-with-log-mode t)

;;   ;; Only use tags to organize tasks
;;   (org-agenda-hide-tags-regexp ".*")

;;   ;; Disable state changing via S-left or S-right
;;   (org-treat-S-cursor-todo-selection-as-state-change nil)

;;   ;; Set span for agenda to be just daily.
;;   (org-agenda-span 1          "Default: 10 days")
;;   (org-agenda-start-day "+0d" "Default: -3d, before current date")

;;   ;; Remove completed tasks from agenda views
;;   (org-agenda-skip-timestamp-if-done t)
;;   (org-agenda-skip-deadline-if-done t)
;;   (org-agenda-skip-scheduled-if-deadline-is-shown t)
;;   (org-agenda-skip-timestamp-if-deadline-is-shown t)

;;   ;; Simplify time-grid agenda display
;;   (org-agenda-current-time-string ""        "Remove agenda 'now...' indicator")
;;   (org-agenda-time-grid '((daily) () "" "") "Remove empty hours from grid")

;;   ;; TODO(t)    :: set fast-access key from agenda view
;;   ;; TODO(t@)   :: record note with timestamp
;;   ;; TODO(t@/!) :: record timestamp when leaving state
;;   (org-todo-keywords '((sequence
;;                         "TODO(t@/!)"      ;; Document task
;;                         "ACTIVE(a@/!)"    ;; Actively working on task
;;                         "WAITING(w@/!)"   ;; Waiting for event related to task
;;                         "HOLD(h@/!)"      ;; Task on hold
;;                         "|" "DONE(d!)" "CANCELLED(x@/!)")))

;;   ;; Automatically assign tags to tasks based on state changes
;;   (org-todo-state-tags-triggers
;;    '(("TODO" ("START" . t))
;;      ("ACTIVE" ("TO-START") ("ACTION" . t))
;;      ("WAITING" ("TO-START") ("ACTION") ("WAITING" . t))
;;      ("TODO" ("ACTION") ("WAITING") ("HOLD") ("CANCELLED"))
;;      ("DONE" ("TO-START") ("ACTION") ("WAITING") ("HOLD") ("CANCELLED"))))

;;   ;; ;; Restructure order of information displayed in agenda-view
;;   ;; (org-agenda-prefix-format '((agenda . "  %?-2i %t ")
;;   ;;                             (todo .   " %i %-12:c")
;;   ;;                             (tags .   " %i %-12:c")
;;   ;;                             (search . " %i %-12:c")))

;;   ;; (org-agenda-category-icon-alist
;;   ;;  '(("mlps-motor",
;;   ;;     (list (nerd-icons-faicon "nf-fa-car")) nil nil :ascent center)
;;   ;;    ("mlps-home" ,
;;   ;;     (list (nerd-icons-sucicon "nf-custom-home")) nil nil :ascent center)
;;   ;;    ("enrichments",
;;   ;;     (list (nerd-icons-faicon "nf-fa-wand_magic")) nil nil :ascent center)
;;   ;;    ("emacs",
;;   ;;     (list (nerd-icons-sucicon "nf-custom-emacs")) nil nil :ascent center)
;;   ;;    ("reading",
;;   ;;     (list (nerd-icons-octicon "nf-oct-book")) nil nil :ascent center)
;;   ;;    ("linux",
;;   ;;     (list (nerd-icons-flicon "nf-linux-archlinux")) nil nil :ascent center)))

;;   )

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

(use-package projectile
  :init (projectile-mode 1)
  ;; :custom
  ;; ;; cache to prevent slow 'projectil-find-file' on larger projects
  ;; (projectile-enable-caching t)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

(use-package yankpad
  :ensure t
  :defer 10
  :init (setq yankpad-file "~/.org/yankpad.org")
  :config
  ;; Always require user to provide snippet category before 'yankpad-insert'
  (advice-add 'yankpad-insert :before (lambda () (setq yankpad-category nil))))

;; alternative to built-in Emacs help
(use-package helpful
  :bind (("C-h j" . helpful-at-point)
         ("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-c C-d" . helpful-at-point)
         ("C-h F" . helpful-function)))

(defun create-file-link-from-current-buffer ()
  "Build [[:file file-path][file-name]] org-link from current
buffer.

The function 'buffer-file-name' returns the absolute path of the
buffer, which breaks should other users open the link. Instead,
the relative path is referenced using the 'abbreviate-file-name'
function."

  (interactive)
  (if-let ((absolute-path (buffer-file-name)))
      (kill-new (message "[[file:%s][%s]]"
                         (abbreviate-file-name absolute-path)
                         (buffer-name)))
    (message "Buffer is not a file")))

(global-set-key (kbd "C-c L") 'create-file-link-from-current-buffer)

;; (defun jh/format-input-str (input-string)
;;   "Format INPUT-STRING.

;; INPUT-STRING converted to downcase, stripped of leading/trailing
;; whitespaces, and symbols/white-spaces replaced with -."

;;   (let ((input-string (string-trim (downcase input-string))))
;;     (if (string= input-string "")
;;         (error "Input string cannot be empty")
;;       (replace-regexp-in-string "[^[:alnum:]]\\| " "-" input-string))))

(defun format-test (input)
  "Format INPUT.

If INPUT is a string, it's converted to lowercase, stripped of
leading/trailing whitespaces, and symbols/white-spaces replaced
with -. If INPUT is a list, each element is processed
recursively. For other types of inputs, an error is returned."

  (cond
    ((stringp input)
      (let ((formatted-input (string-trim (downcase input))))
        (if (string= formatted-input "")
            (error "Input string cannot be empty")
          (replace-regexp-in-string "[^[:alnum:]]+" "-" formatted-input))))
    ((listp input)
      (mapcar #'format-test input))
    (t
      (error "Input must be a string or a list"))))

;; Example usage:
(format-test "mlp__emacs__config")
(format-test '("mlp-docs" "af-robovisor" "ogi-products"))
;; (format-test 42)

;; (format-test 42)

;;; init.el ends here
