;;; lonelog.el --- Solo RPG notation support  -*- lexical-binding: t; -*-

;; Author: Christer Enfors <christer.enfors@gmail.com>
;; Maintainer: Christer Enfors <christer.enfors@gmail.com>
;; Created: 2026
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: games, convenience, wp
;; URL: https://github.com/enfors/lonelog

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
;;
;; Customization:
;;  Run M-x customize-group RET lonelog RET to change colors.
;;
;; Shortcuts for setting colors depending on your background color:
;;
;;   (lonelog-light-mode)
;;   (lonelog-dark-mode)


;;; Code:

;;; Faces:

;; Face group

(defgroup lonelog nil
  "Support for Lonelog solo RPG notation."
  :group 'games
  :prefix "lonelog-")

;; Action
(defface lonelog-action-symbol-face
  '(
    (((class color) (background dark))
     :foreground "#045ccf" :weight bold)
    (((class color) (background light))
     :foreground "#003f91" :weight bold)
    (t :weight bold)
    )
  "Foreground color for the Lonelog action symbol (the \"@\")."
  :group 'lonelog)

(defface lonelog-action-content-face
  '(
    (((class color) (background dark))
     :foreground "#a3cbff")
    (((class color) (background light))
     :foreground "#1e4e8c")
    (t :weight bold)
    )
  "Foreground color for the Lonelog action.

This is the part that comes after the \"@\"."
  :group 'lonelog)

;; Oracle question
(defface lonelog-oracle-question-symbol-face
  '(
    (((class color) (background dark))
     :foreground "#b637cc" :weight bold)
    (((class color) (background light))
     :foreground "#86d207a")
    (t :weight bold)
    )
  "Foreground color for the Lonelog oracle question symbol (the \"?\")."
  :group 'lonelog)

(defface lonelog-oracle-question-content-face
  '(
    (((class color) (background dark))
     :foreground "#bc73c9")
    (((class color) (background light))
     :foreground "#5e3fd3" :weight bold)
    (t :weight bold)
    )
  "Foreground color for the Lonelog oracle question itself.

This is the part that comes after the \"?\"."
  :group 'lonelog)

;; Mechanics roll
(defface lonelog-mechanics-roll-symbol-face
  '(
    (((class color) (background dark))
     :foreground "#3e991d" :weight bold)
    (((class color) (background light))
     :foreground "#2e7d12" :weight bold)
    (t :weight bold)
    )
  "Foreground color for the Lonelog mechanics roll symbol (the \"d:\")."
  :group 'lonelog)

(defface lonelog-mechanics-roll-content-face
  '(
    (((class color) (background dark))
     :foreground "#58c024")
    (((class color) (background light))
     :foreground "#206009")
    (t :weight bold)
    )
  "Foreground color for the Lonelog mechanics roll itself.

This is the part that comes after the \"d:\"."
  :group 'lonelog)

;; Oracle / dice result
(defface lonelog-oracle-and-dice-result-symbol-face
  '(
    (((class color) (background dark))
     :foreground "#e8fc05" :weight bold)
    (((class color) (background light))
     :foreground "#99a600")
    (t :weight bold)
    )
  "Foreground color for the Lonelog oracle/dice symbol (the \"->\")."
  :group 'lonelog)

(defface lonelog-oracle-and-dice-result-content-face
  '(
    (((class color) (background dark))
     :foreground "#e8fc05")
    (((class color) (background light))
     :foreground "#708600")
    (t :weight bold)
    )
  "Foreground color for the Lonelog oracle/dice result itself.

This is the part that comes after the \"->\"."
  :group 'lonelog)

;; Consequence
(defface lonelog-consequence-symbol-face
  '(
    (((class color) (background dark))
     :foreground "#ff5010" :weight bold)
    (((class color) (background light))
     :foreground "#936400" :weight bold)
    (t :weight bold)
    )
  "Foreground color for the Lonelog consequence symbol (the \"=>\")."
  :group 'lonelog)

(defface lonelog-consequence-content-face
  '(
    (((class color) (background dark))
     :foreground "#ffa050")
    (((class color) (background light))
     :foreground "#b37400")
    (t :weight bold)
    )
  "Foreground color for the Lonelog consequence itself.

This is the part that comes after the \"=>\"."
  :group 'lonelog)

;; Face rules:

(defvar lonelog-font-lock-keywords
  (list
   ;; Action:
   '("^\\(@\\)\\s-*\\(.*\\)"
     (1 'lonelog-action-symbol-face)
     (2 'lonelog-action-content-face))
   ;; Oracle question:
   '("^\\(\\?\\)\\s-*\\(.*\\)"
     (1 'lonelog-oracle-question-symbol-face)
     (2 'lonelog-oracle-question-content-face))
   ;; Mechanics roll:
   '("^\\(d:\\)\\s-*\\(.*\\)"
     (1 'lonelog-mechanics-roll-symbol-face)
     (2 'lonelog-mechanics-roll-content-face))
   ;; Oracle and dice result:
   '("\\(->\\)\\s-*\\(.*\\)"
     (1 'lonelog-oracle-and-dice-result-symbol-face t)   ; t = Override
     (2 'lonelog-oracle-and-dice-result-content-face t)) ; t = Override
   ;; Consequence:
   '("\\(=>\\)\\s-*\\(.*\\)"
     (1 'lonelog-consequence-symbol-face t)    ; t = Override
     (2 'lonelog-consequence-content-face t))) ; t = Override
  "Highlighting rules for Lonelog mode.")

;;; Helper functions:

(defun lonelog-insert-date ()
  "Insert the current date in Lonelog format."
  (interactive)
  (insert (format-time-string "[%Y-%m-%d] ")))

;;; Minor mode itself:

;;;###autoload
(define-minor-mode lonelog-mode
  "Minor mode for the Lonelog solo RPG notation format.

When enabled, this mode provides syntax highlighting for the five core
Lonelog symbols:
 @   Action
 ?   Oracle
 d:  Mechanics roll
 ->  Result
 =>  Consequence

\\{lonelog-mode-map}"
  :init-value nil
  :global nil
  :group 'lonelog
  :lighter " Lonelog"
  :keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-d .") 'lonelog-insert-date)
    map)

  (if lonelog-mode
      ;; If ON:
      (progn
        (font-lock-add-keywords nil lonelog-font-lock-keywords)
        (font-lock-flush)
        (message "Lonelog-mode enabled."))
    ;; If OFF:
    (progn
      (font-lock-remove-keywords nil lonelog-font-lock-keywords)
      (font-lock-flush)
      (message "Lonelog-mode disabled."))))

;; Hooks:

;; (add-hook 'lonelog-mode-hook (lambda () (message "Hook was executed.")))
;; (add-hook 'lonelog-mode-on-hook (lambda () (message "Lonelog turned on.")))
;; (add-hook 'lonelog-mode-off-hook (lambda () (message "Lonelog turned off.")))

(provide 'lonelog)

;;; lonelog.el ends here
