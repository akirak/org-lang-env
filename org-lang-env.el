;;; org-lang-env.el --- Per-entry language environment -*- lexical-binding: t -*-

;; Copyright (C) 2022 Akira Komamura

;; Author: Akira Komamura <akira.komamura@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "25.1"))
;; Keywords: i18n wp convenience
;; URL: https://github.com/akirak/org-lang-env

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This minor mode switches `current-language-environment' according to a
;; property of an Org entry being clocked in.

;;; Code:

(defconst org-lang-env-prop-name "language_environment"
  "Name of the property.")

(defun org-lang-env-switch ()
  "Switch to the language environment according to property."
  (when-let (language (org-entry-get nil org-lang-env-prop-name t))
    (set-language-environment language)))

(defun org-lang-env-restore ()
  "Switch back to the default language environment."
  (pcase (get 'current-language-environment 'standard-value)
    (`nil)
    (`(,value) (set-language-environment (eval value)))))

;;;###autoload (autoload 'org-lang-env-mode "org-lang-env")
(define-minor-mode org-lang-env-mode
  "Setting the language environment on clocking in."
  :lighter " OrgLang"
  (if (bound-and-true-p org-lang-env-mode)
      (progn
        (add-hook 'org-clock-in-hook #'org-lang-env-switch nil t)
        (add-hook 'org-clock-out-hook #'org-lang-env-restore nil t))
    (progn
      (remove-hook 'org-clock-in-hook #'org-lang-env-switch t)
      (remove-hook 'org-clock-out-hook #'org-lang-env-restore t))))

;;;###autoload (autoload 'org-lang-env-global-mode "org-lang-env")
(define-globalized-minor-mode org-lang-env-global-mode org-lang-env-mode
  (lambda ()
    (when (derived-mode-p 'org-mode)
      (org-lang-env-mode))))

;;;###autoload
(defun org-lang-env-set ()
  "Set the language environment property."
  (interactive)
  (let ((language (read-language-name nil "Language to use in this subtree: "
                                      (org-entry-get nil org-lang-env-prop-name))))
    (org-entry-put nil org-lang-env-prop-name language)
    (when (and (not org-lang-env-mode)
               (yes-or-no-p "Turn on org-lang-env-mode through a property line?"))
      (save-excursion
        (add-file-local-variable-prop-line 'eval '(org-lang-env-mode t)))
      (org-lang-env-mode t))))

(provide 'org-lang-env)
;;; org-lang-env.el ends here
