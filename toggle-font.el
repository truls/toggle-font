;;; toggle-font.el --- Toggle fonts -*- lexical-binding: t -*-
;;;
;;; Author:
;;; Truls Asheim <truls@asheim.dk>
;;;
;;; Commentary:
;;; Toggle between the default and an alternative font face
;;;
;;; Based on code Dennis Ogbe
;;; https://ogbe.net/blog/toggle-serif.html
;;;
;;; Version: 1.0
;;; URL: https://github.com/truls/toggle-font
;;;
;;; Package-Requires: ((emacs "24.4"))
;;;
;;; Code:
;;;

(defcustom toggle-font-preserve-default-list
  '(;; LaTeX markup
    font-latex-math-face
    font-latex-sedate-face
    font-latex-warning-face
    ;; org markup
    org-latex-and-related
    org-meta-line
    org-verbatim
    org-block-begin-line
    ;; syntax highlighting using font-lock
    font-lock-builtin-face
    font-lock-comment-delimiter-face
    font-lock-comment-face
    font-lock-constant-face
    font-lock-doc-face
    font-lock-function-name-face
    font-lock-keyword-face
    font-lock-negation-char-face
    font-lock-preprocessor-face
    font-lock-regexp-grouping-backslash
    font-lock-regexp-grouping-construct
    font-lock-string-face
    font-lock-type-face
    font-lock-variable-name-face
    font-lock-warning-face)
  "A list holding the faces that preserve the default family and
  height when TOGGLE-FONT is used."
  :group 'toggle-font)


(defcustom toggle-font-alternative-family
  "Liberation Serif"
  "The font family to toggle to."
  :group 'toggle-font
  :type '(string))

(defcustom toggle-font-alternative-height
  120
  "The font weight to toggle to."
  :group 'toggle-font
  :type '(integer))


(defun toggle-font (&optional set)
  "Change the default face of the current buffer to use a serif family."
  (interactive)
  (when (display-graphic-p)  ;; this is only for graphical emacs
    ;; the serif font familiy and height, save the default attributes
    (if (bound-and-true-p toggle-font--default-cookie)
        (progn
          (toggle-font-turn-off)
          (message "Restored default fonts."))
      (progn
        (toggle-font-turn-on)
        (message "Turned on serif writing font.")))))


(defun toggle-font-turn-on ()
  (when (display-graphic-p)
    (when (not (bound-and-true-p toggle-font--default-cookie))
      (let ((serif-fam toggle-font-alternative-family)
            (serif-height toggle-font-alternative-height)
            (default-fam (face-attribute 'default :family))
            (default-height (face-attribute 'default :height)))
        (make-local-variable 'toggle-font--default-cookie)
        (make-local-variable 'toggle-font--preserve-default-cookies-list)
        (setq toggle-font--preserve-default-cookies-list nil)
        ;; remap default face to serif
        (setq toggle-font--default-cookie
              (face-remap-add-relative
               'default :family serif-fam
               :height serif-height))
        ;; keep previously defined monospace fonts the same
        (dolist (face toggle-font-preserve-default-list)
          (add-to-list 'toggle-font--preserve-default-cookies-list
                       (face-remap-add-relative
                        face :family default-fam
                        :height default-height)))))))


(defun toggle-font-turn-off ()
  ;; undo changes
  (when (display-graphic-p)
    (when (bound-and-true-p toggle-font--default-cookie)
      (face-remap-remove-relative toggle-font--default-cookie)
      (dolist (cookie toggle-font--preserve-default-cookies-list)
        (face-remap-remove-relative cookie))
      (setq toggle-font--default-cookie nil)
      (setq toggle-font--preserve-default-cookies-list nil))))

(provide 'toggle-font)
;;; toggle-font.el ends here
