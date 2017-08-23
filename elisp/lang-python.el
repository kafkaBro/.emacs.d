;;; package --- python configs
;;; Commentary:
;;; Contains my python configs

;;; Code:
(defcustom bgs-emacs-use-pyenv (> (length (getenv "EMACS_USE_PYENV")) 0) "using pyenv?")

(use-package python
  :mode ("\\.py" . python-mode)
  :config
  (bind-keys :map inferior-python-mode-map
	     ("M-p" . comint-previous-matching-input-from-input)
	     ("M-n" . comint-next-matching-input-from-input))
  (bind-keys :map python-mode-map
	     ("C-c C-l" . python-shell-send-file)))

(use-package elpy
  :init
  (setq elpy-rpc-backend "rope")
  ;; (add-hook 'python-mode-hook 'py-autopep8-enable-on-save)
  ;;flycheck-python-flake8-executable "/usr/local/bin/flake8"
  (elpy-enable)
  (bind-keys :map elpy-mode-map
	     ("M-." . elpy-goto-definition)
	     ("M-," . pop-tag-mark))
  (setq bgs-python-common-map (make-sparse-keymap))
  (bind-keys :map bgs-python-common-map
	     ("d" . elpy-doc))
  (bind-key "C-c E" bgs-python-common-map elpy-mode-map)
  (bind-key "C-c E" bgs-python-common-map inferior-python-mode-map)

  )

(use-package pip-requirements
  :config
  (add-hook 'pip-requirements-mode-hook #'pip-requirements-auto-complete-setup))

(use-package py-autopep8)


(use-package pyenv-mode
  :init
  (add-to-list 'exec-path "~/.pyenv/shims")
  (setenv "WORKON_HOME" "~/.pyenv/versions/")
  :config
  (pyenv-mode (if bgs-emacs-use-pyenv 1 -1))
  :bind
  ("C-x p e" . pyenv-activate-current-project))

(defun pyenv-init()
  (setq global-pyenv (replace-regexp-in-string "\n" "" (shell-command-to-string "pyenv global")))
  (message (concat "Setting pyenv version to " global-pyenv))
  (pyenv-mode-set global-pyenv)
  (defvar pyenv-current-version nil global-pyenv))

(defun pyenv-activate-current-project ()
  "Automatically activates pyenv version if .python-version file exists."
  (interactive)
  (f-traverse-upwards
   (lambda (path)
     (message path)
     (let ((pyenv-version-path (f-expand ".python-version" path)))
       (if (f-exists? pyenv-version-path)
          (progn
            (setq pyenv-current-version (s-trim (f-read-text pyenv-version-path 'utf-8)))
            (pyenv-mode-set pyenv-current-version)
            (pyvenv-workon pyenv-current-version)
            (message (concat "Setting virtualenv to " pyenv-current-version))))))))

(add-hook 'after-init-hook 'pyenv-init)
(add-hook 'projectile-after-switch-project-hook 'pyenv-activate-current-project)
(add-hook 'python-mode-hook 'flycheck-mode)
(add-hook 'python-mode-hook (lambda () (toggle-truncate-lines 1)))

(provide 'lang-python)
;;; base-python.el ends here
