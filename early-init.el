;;; -*- lexical-binding: t -*-

;; Maximize gc threshold for initialization
(setq gc-cons-threshold most-positive-fixnum)

;; Trigger GC based on %allocation, ignored if < `gc-cons-threshold`
(setq gc-cons-percentage 0.6)

;; Disable unwanted UI elements as early as possible
(menu-bar-mode   -1)
(scroll-bar-mode -1) ; Visible scrollbar
(scroll-all-mode -1) ; Synchronized scrolling of buffers
(tool-bar-mode   -1)
(tooltip-mode    -1)

(setq-default
 inhibit-startup-screen t     ; Disable start-up screen
 inhibit-startup-message t    ; Disable start-up message
 initial-scratch-message ""   ; Empty initial *scratch* buffer
 initil-buffer-choice t)      ; Open *scratch* buffer at init

;; Disable audible dinging and use visible bell
(setq visible-bell t)

;;; early-init.el ends here
