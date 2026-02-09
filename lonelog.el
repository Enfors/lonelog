;;;; lonelog.el --- Solo RPG notation support  -*- lexical-binding: t; -*-

;; Author: Christer Enfors <christer.enfors@gmail.com>
;; Maintainer: Christer Enfors <christer.enfors@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: games, convenience, wp
;; URL: https://github.com/enfors/lonelog

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Lonelog is a minor mode that provides syntax highlight and support
;; for the "Lonelog" solo RPG notation system, designed by Loreseed
;; Workshop: https://zeruhur.itch.io/lonelog
;; The lonelog minor mode is designed to be agnostic to the underlying
;; major mode, working equally well in org-mode, Markdown, or plain
;; text.
;;
;; Features include:
;; - Highlighting for core symbols (@, ?, d:, ->, =>)
;;
;; To use this package, add the following to your configuration:
;;
;;   (require 'lonelog)
;;   (add-hook 'text-mode-hook 'lonelog-mode)

;;; Code:

;;; Faces:

;; Action
(defface lonelog-action-symbol-face
  '((t :foreground "#045CCF" :weight bold))
  "Face for the Lonelog player action symbol.")

(defface lonelog-action-content-face
  '((t :foreground "#A3CBFF"))
  "Face for the Lonelog player action.")

;; Oracle question
(defface lonelog-oracle-question-symbol-face
  '((t :foreground "#B637CC" :weight bold))
  "Face for the Lonelog oracle question symbol.")

(defface lonelog-oracle-question-content-face
  '((t :foreground "#BC73C9"))
  "Face for the Lonelog oracle question itself.")

;; Mechanics roll
(defface lonelog-mechanics-roll-symbol-face
  '((t :foreground "#3E991D" :weight bold))
  "Face for the Lonelog mechanics roll symbol.")

(defface lonelog-mechanics-roll-content-face
  '((t :foreground "#7BB865"))
  "Face for the Lonelog mehcanics roll itself.")

;; Oracle / dice result
(defface lonelog-oracle-and-dice-result-symbol-face
  '((t :foreground "#e8fc05" :weight bold))
  "Face for the Lonelog oracle and dice result symbol.")

(defface lonelog-oracle-and-dice-result-content-face
  '((t :foreground "#e8fc80"))
  "Face for the Lonelog oracle and dice result itself.")

;; Consequence
(defface lonelog-consequence-symbol-face
  '((t :foreground "#FF7D9B" :weight bold))
  "Face for the Lonelog consequence symbol.")

(defface lonelog-consequence-content-face
  '((t :foreground "#FFA0C0"))
  "Face for the Lonelog consequence itself..")

;; Face rules:

(defvar lonelog-font-lock-keywords
  (list
   ;; Action:
   '("^\\(@\\)\\s-\\(.*\\)"
     (1 'lonelog-action-symbol-face)
     (2 'lonelog-action-content-face))
   ;; Oracle question:
   '("^\\(\\?\\)\\s-\\(.*\\)\\(->\\)?"
     (1 'lonelog-oracle-question-symbol-face)
     (2 'lonelog-oracle-question-content-face))
   ;; Mechanics roll:
   '("^\\(d:\\)\\s-\\(.*\\)\\(->\\)?"
     (1 'lonelog-mechanics-roll-symbol-face)
     (2 'lonelog-mechanics-roll-content-face))
   ;; Oracle and dice result:
   '("\\(->\\)\\s-\\(.*\\)"
     (1 'lonelog-oracle-and-dice-result-symbol-face t)   ;; t = Override
     (2 'lonelog-oracle-and-dice-result-content-face t)) ;; t = Override
   ;; Consequence:
   '("^\\(=>\\)\\s-\\(.*\\)"
     (1 'lonelog-consequence-symbol-face)
     (2 'lonelog-consequence-content-face)))
  "Highlighting rules for Lonelog mode.")

;;; Minor mode itself:

(define-minor-mode lonelog-mode
  "Toggles local `lonelog-mode'."
  :init-value nil
  :global nil
  :lighter " Lonelog"
  :keymap
  (list (cons (kbd "C-c C-d .")
              (lambda ()
                (interactive)
                (message "Lonelog key binding used."))))

  (if lonelog-mode
      ;; If ON:
      (progn
        (font-lock-add-keywords nil lonelog-font-lock-keywords)
        (font-lock-flush)
        (message "Lonelog-mode activated."))
    ;; If OFF:
    (progn
      (font-lock-remove-keywords nil lonelog-font-lock-keywords)
      (font-lock-flush)
      (message "Lonelog-mode deactivated."))))

;; Hooks:

(add-hook 'lonelog-mode-hook (lambda () (message "Hook was executed.")))
(add-hook 'lonelog-mode-on-hook (lambda () (message "Lonelog turned on.")))
(add-hook 'lonelog-mode-off-hook (lambda () (message "Lonelog turned off.")))

(provide 'lonelog)

(provide 'lonelog)

;;; lonelog.el ends here
