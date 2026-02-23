;;; lonelog.el --- Solo RPG notation support  -*- lexical-binding: t; -*-

;; Author: Christer Enfors <christer.enfors@gmail.com>
;; Maintainer: Christer Enfors <christer.enfors@gmail.com>
;; Created: 2026
;; Version: 0.2.0
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
;; - Highlighting for tags ([N:Jonah|friendly|uninjured])
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

;;; Declarations:

(defvar lonelog-mode)

;;; Variables:

(defgroup lonelog nil
  "Support for Lonelog solo RPG notation."
  :group 'games
  :prefix "lonelog-")

(defcustom lonelog-auto-start-tag-tracking t
  "If t, Lonelog-mode will auto-open the tag tracking buffer when started."
  :type 'bool
  :group 'lonelog)

(defcustom lonelog-hud-update-delay 1.0
  "How many seconds of idle time before the HUD automatically updates."
  :type 'number
  :group 'lonelog)

(defvar lonelog--hud-timer nil
  "Internal variable to store the active HUD timer.")


;;; Faces:

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

;; Tags ([..:..|..])
(lonelog-define-face lonelog-tag-symbol-face
                     "#00ff00" "#00cc00"
                     "Foreground color for the Lonelog tag symbols themselves.
They are the `[' and `]' characters.")

(lonelog-define-face lonelog-tag-separator-face
                     "#00aa00" "#008800"
                     "Foreground color for the Lonelog tag separators (| and :).")

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
     (2 'lonelog-consequence-content-face t)) ; t = Override
   ;; Tags (with anchored mini-search for | and :):
   '("\\(\\[\\)\\([^]]+\\)\\(\\]\\)"
     (1 'lonelog-tag-symbol-face t)
     (3 'lonelog-tag-symbol-face t)
     ;; --- The Anchored Matcher ---
     ("[|:]"
      ;; Pre-match form: jump to the start of the tag contents,
      ;; and tell Emacs to stop searching at the end of the tag contents.
      (progn (goto-char (match-beginning 2)) (match-end 2))
      ;; Post-match form: jump back to the end of the closing bracket
      ;; so Emacs can continue highlighting the rest of the file normally.
      (goto-char (match-end 0))
      ;; Subexp-highlighter: apply the face to the | or :
      (0 'lonelog-tag-separator-face t))))
  "Highlighting rules for Lonelog mode.")

;;; Helper functions:

(defun lonelog-insert-date ()
  "Insert the current date in Lonelog format."
  (interactive)
  (insert (format-time-string "[%Y-%m-%d] ")))

;;; Tags handling ==========================================================

;;; Tag extraction

(defun lonelog-extract-latest-tags ()
  "Scan the buffer backwards to extract the latest state of each tag.
Returns a chronologically ordered list of tag strings."
  ;; 1. Save the user's cursor position so we don't yank their screen around.
  (save-excursion
    ;; 2. Jump to the absolute bottom of the document.
    (goto-char (point-max))

    ;; 3. Set up our temporary variables for this run.
    (let ((seen-ids (make-hash-table :test 'equal))
          (latest-tags nil)
          ;; Regex: Group 1 matches anything that isn't a ] or |
          (tag-regex "\\[\\([^]|]+\\)[^]]*\\]"))

      ;; 4. Loop backwards until we run out of matches.
      (while (re-search-backward tag-regex nil t)
        (let ((full-tag (match-string-no-properties 0))
              (tag-id   (match-string-no-properties 1)))
          
          ;; 5. Have we seen this ID before?
          (unless (gethash tag-id seen-ids)
            ;; No? Then this is the newest version.
            ;; Mark it as seen in the hash table.
            (puthash tag-id t seen-ids)
            ;; Add the full tag to the front of our list.
            (push full-tag latest-tags))))

      ;; 6. Return the finalized list.
      latest-tags)))

;;; Tag HUD updater

(defun lonelog--draw-hud-contents (hud-buffer tags)
  "Wipe HUD-BUFFER and cleanly insert TAGS."
  (with-current-buffer hud-buffer
    ;; Save the user's cursor in case they actually clicked inside the HUD
    (save-excursion
      (let ((inhibit-read-only t))
        (unless (eq major-mode 'text-mode)
          (text-mode))
        (erase-buffer)
        (insert "=== Active Tags ===\n\n")
        (if tags
            (dolist (tag tags)
              (insert tag "\n"))
          (insert "Any [tags] will be shown here.\n"))
        (unless lonelog-mode
          (lonelog-mode 1))))))

(defun lonelog-update-hud ()
  "Extract the latest tags and pop open the dedicated side-window HUD."
  (interactive)
  (let ((tags (lonelog-extract-latest-tags))
        (hud-buffer (get-buffer-create "*Lonelog HUD*")))
    (lonelog--draw-hud-contents hud-buffer tags)
    (display-buffer hud-buffer
                    '(display-buffer-in-side-window
                      . ((side . right)
                         (window-width . 35))))))

(defun lonelog--update-hud-background ()
  "Silently update the HUD buffer, but only if the user is looking at it."
  (when (get-buffer-window "*Lonelog HUD*")
    (let ((tags (lonelog-extract-latest-tags))
          (hud-buffer (get-buffer-create "*Lonelog HUD*")))
      (lonelog--draw-hud-contents hud-buffer tags))))

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

Tags are also tracked in a side window:
 [N:Jonah|friendly|Uninjured]

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
        (unless (string= (buffer-name) "*Lonelog HUD*)")
          ;; Start the idle timer.
          (setq lonelog--hud-timer
                (run-with-idle-timer lonelog-hud-update-delay t
                                     #'lonelog--update-hud-background))
          ;; Start tag tracking if lonelog-auto-start-tag-tracking is t
          (when lonelog-auto-start-tag-tracking
            (lonelog-update-hud)))
        (message "Lonelog-mode enabled."))
    ;; If OFF:
    (progn
      (font-lock-remove-keywords nil lonelog-font-lock-keywords)
      (font-lock-flush)
      ;; Stop the idle timer.
      (when lonelog--hud-timer
        (cancel-timer lonelog--hud-timer)
        (setq lonelog--hud-timer nil))
      (message "Lonelog-mode disabled."))))

(provide 'lonelog)

;;; lonelog.el ends here
