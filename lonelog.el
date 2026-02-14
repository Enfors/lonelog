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

;;; Code:

;;; Faces:

(defgroup lonelog nil
  "Support for Lonelog solo RPG notation."
  :group 'games
  :prefix "lonelog-")

;; The Macro Definition
(defmacro lonelog-define-face (name dark-hex light-hex docstring &optional bold)
  "Define a Lonelog face with NAME, using DARK-HEX and LIGHT-HEX colors.
DOCSTRING provides the documentation for the face.
If BOLD is non-nil, the face will be bold in all themes."
  (let ((weight-spec (if bold '(:weight bold) '())))
    `(defface ,name
       '(
         ;; Dark Background
         (((class color) (background dark))
          :foreground ,dark-hex ,@weight-spec)
         ;; Light Background
         (((class color) (background light))
          :foreground ,light-hex ,@weight-spec)
         ;; Fallback (Terminal / Monochrome)
         (t ,@weight-spec))
       ,docstring
       :group 'lonelog)))

;; --- Face Definitions ---

;; Action (@)
(lonelog-define-face lonelog-action-symbol-face
  "#045ccf" "#003f91"
  "Foreground color for the Lonelog action symbol (the \"@\")."
  t) ;; Bold

(lonelog-define-face lonelog-action-content-face
  "#a3cbff" "#1e4e8c"
  "Foreground color for the Lonelog action.
This is the part that comes after the \"@\".")

;; Oracle (?)
(lonelog-define-face lonelog-oracle-question-symbol-face
  "#b020a0" "#6d207a"
  "Foreground color for the Lonelog oracle question symbol (the \"?\")."
  t) ;; Bold

(lonelog-define-face lonelog-oracle-question-content-face
  "#f490ec" "#5e3fd3"
  "Foreground color for the Lonelog oracle question itself.
This is the part that comes after the \"?\".")

;; Mechanics (d:)
(lonelog-define-face lonelog-mechanics-roll-symbol-face
  "#308018" "#2e7d12"
  "Foreground color for the Lonelog mechanics roll symbol (the \"d:\")."
  t) ;; Bold

(lonelog-define-face lonelog-mechanics-roll-content-face
  "#60ff28" "#206009"
  "Foreground color for the Lonelog mechanics roll itself.
This is the part that comes after the \"d:\".")

;; Result (->)
(lonelog-define-face lonelog-oracle-and-dice-result-symbol-face
  "#a09005" "#99a600"
  "Foreground color for the Lonelog oracle/dice symbol (the \"->\")."
  t) ;; Bold

(lonelog-define-face lonelog-oracle-and-dice-result-content-face
  "#e8fc05" "#708600"
  "Foreground color for the Lonelog oracle/dice result itself.
This is the part that comes after the \"->\".")

;; Consequence (=>)
(lonelog-define-face lonelog-consequence-symbol-face
  "#c04008" "#936400"
  "Foreground color for the Lonelog consequence symbol (the \"=>\")."
  t) ;; Bold

(lonelog-define-face lonelog-consequence-content-face
  "#ffa050" "#b37400"
  "Foreground color for the Lonelog consequence itself.
This is the part that comes after the \"=>\".")

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
     (1 'lonelog-oracle-and-dice-result-symbol-face t)    ; t = Override
     (2 'lonelog-oracle-and-dice-result-content-face t)) ; t = Override
   ;; Consequence:
   '("\\(=>\\)\\s-*\\(.*\\)"
     (1 'lonelog-consequence-symbol-face t)     ; t = Override
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

(provide 'lonelog)

;;; lonelog.el ends here
