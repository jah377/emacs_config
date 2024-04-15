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
