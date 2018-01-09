;; Require header
(use-package bind-key :ensure t)

;; Additional Packages

(use-package ace-window :ensure t
  :bind
  ("C-'" . ace-window)
  :config
  ;; note "aw" = ace-window
  (setq aw-dispatch-always "t"))

(use-package ag :ensure t)

(use-package avy :ensure t
  :bind
  ("C-;"     . avy-goto-word-1))

(use-package buffer-move :ensure t
  :bind
  ("<C-S-up>"    . buf-move-up)
  ("<C-S-down>"  . buf-move-down)
  ("<C-S-left>"  . buf-move-left)
  ("<C-S-right>" . buf-move-right)
  :config
  ;; buffer moves instead of swapping the windows
  ;;   buffers are thus like pieces of paper on a desktop
  (setq buffer-move-behavior 'move))

(use-package company :ensure t
  :config
  (defun bgs-print-backend ()
    (interactive)
    (message (format "Active Backend: %s" company-backend)))
  (bind-keys :map company-active-map
	     ("C-n" . company-select-next)
	     ("C-p" . company-select-previous)
	     ("C-b" . bgs-print-backend))
  (global-company-mode))

(use-package dashboard :ensure t
  :config
  (dashboard-setup-startup-hook))

(use-package dumb-jump :ensure t)

(use-package ediff :ensure t
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  (setq-default ediff-highlight-all-diffs 'nil)
  (setq ediff-diff-options "-w"))

(use-package exec-path-from-shell :ensure t
  :config
  ;; Add GOPATH to shell
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-copy-env "GOPATH")
    (exec-path-from-shell-copy-env "PYTHONPATH")
    (exec-path-from-shell-initialize)))

(use-package expand-region :ensure t
  :bind
  ("C-=" . er/expand-region))

(use-package flycheck :ensure t)

(use-package counsel :ensure t
  :init
  (counsel-mode)
  :config
  (use-package ivy :ensure t)
  (defun bgs-counsel-file-jump (&optional initial-input initial-directory)
    "Jump to a file below the current directory.
List all files within the current directory or any of its subdirectories.
INITIAL-INPUT can be given as the initial minibuffer input.
INITIAL-DIRECTORY, if non-nil, is used as the root directory for search."
    (interactive
     (list nil
	   (when current-prefix-arg
	     (read-directory-name "From directory: "))))
    (counsel-require-program "find")
    (let* ((default-directory (or initial-directory default-directory)))
      (ivy-read "Find file: "
		(split-string
		 (shell-command-to-string "find . -type f -not -path '*\/.git*'")
		 "\n" t)
		:matcher #'counsel--find-file-matcher
		:initial-input initial-input
		:action (lambda (x)
			  (with-ivy-window
			    (find-file (expand-file-name x ivy--directory))))
		:preselect (when counsel-find-file-at-point
			     (require 'ffap)
			     (let ((f (ffap-guesser)))
			       (when f (expand-file-name f))))
		:require-match 'confirm-after-completion
		:history 'file-name-history
		:keymap counsel-find-file-map
		:caller 'counsel-file-jump)))

  (bind-keys :map counsel-mode-map
	     :prefix-map counsel-prefix-map
	     :prefix "C-c I"
	     ("l" . counsel-ag)
	     ("f" . bgs-counsel-file-jump)
	     ("d" . counsel-dired-jump)
	     ("x" . counsel-linux-app)
	     ("o" . counsel-outline)
	     ("s" . counsel-set-variable)
	     ("u" . counsel-unicode-char))

  (bind-keys :map counsel-mode-map
	     ("M-s f" . bgs-counsel-file-jump)
	     ("M-s l" . counsel-ag)
	     ("M-s d" . counsel-dired-jump)
	     ("C-h p" . counsel-find-library))

  (eval-after-load "company"
    (if global-company-mode
	(progn
 	  (message "BGS: global company mode on, bind counsel-company to counsel-mode-map")
	  (bind-keys :map counsel-mode-map
		     ("C-:" . counsel-company)))
      (message "BGS: global company mode off, do nothing!")))

  (setq counsel-find-file-at-point "t"
	counsel-mode-lighter "")	; needs patch of counsel in order to work
  )

(use-package counsel-projectile :ensure t
  :demand
  :bind
  ;; ("C-x v" . counsel-projectile) ;; deactive for now
  ("C-x c p" . counsel-projectile-ag)
  :config
  (projectile-mode))

(use-package counsel-pydoc :ensure t)

(use-package counsel-world-clock :ensure t
	     :config
	     (setq counsel-world-clock--time-zones
		   (cons "UTC" counsel-world-clock--time-zones)))

(use-package help-fns+ :ensure t
  ;; this adds keybindings to help-map
  )

(use-package highlight :ensure t
  :demand
  :bind
  ("C-x C-y" . hlt-highlight))

(use-package hlinum :ensure t
  :config
  (hlinum-activate))

(use-package ivy :ensure t
  :init
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers nil)
  (bind-key "C-r" 'counsel-expression-history read-expression-map)
  (bind-keys ("M-s s" . isearch-forward))
  :bind
  ("C-s" . swiper)
  ("C-x C-r" . ivy-resume))

(use-package ivy-hydra :ensure t)

(use-package man :ensure t
  :config
  (setq Man-width 90))

(use-package helpful :ensure t
  :config
  (bind-keys
   ("C-h f" . helpful-function)
   ("C-h c" . helpful-command)
   ("C-h k" . helpful-key)
   ("C-h m" . helpful-macro)
   ("C-h M" . describe-mode) 		; move over
   ;; ("" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h ." . helpful-at-point)
   ("C-h D" . helpful-symbol)))

(use-package linum :ensure t
  :config
  (setq linum-format " %3d ")
  (global-linum-mode -1)
  (add-hook 'prog-mode-hook 'linum-mode)
  (add-hook 'text-mode-hook 'linum-mode))

(use-package magit :ensure t
  :config
  (unbind-key "<C-tab>" magit-mode-map)
  (add-hook 'after-save-hook 'magit-after-save-refresh-status)
  (setq magit-completing-read-function 'ivy-completing-read
	magit-log-arguments
	 (quote
	  ("--graph" "--color" "--decorate" "--follow" "-n256")))
  :bind
  ;; Magic
  ("C-x g s" . magit-status)
  ("C-x g x" . magit-checkout)
  ("C-x g c" . magit-commit)
  ("C-x g p" . magit-push)
  ("C-x g u" . magit-pull)
  ("C-x g e" . magit-ediff-resolve)
  ("C-x g l" . magit-log-popup)
  ("C-x g r" . magit-rebase-interactive))

(use-package magit-filenotify :ensure t
  :config
  (add-hook 'magit-status-mode-hook 'magit-filenotify-mode))

(use-package magit-popup :ensure t)

(use-package move-text :ensure t
  :bind
  ("M-n"      . move-text-down)
  ("M-p"      . move-text-up)
  ("<M-down>" . move-text-down)
  ("<M-up>"   . move-text-up))

(use-package multiple-cursors :ensure t
  :bind
  ("C-S-c C-S-c" . mc/edit-lines)
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-c C->" . mc/mark-all-like-this)
  ("C-c C-<" . mc/mark-more-like-this-extended)
  :bind
  (:map mc/keymap
	("C-c C-n" . mc/insert-numbers)
	("C-'" . mc-hide-unmatched-lines-mode)))

(use-package neotree :ensure t
  :config
  (setq neo-theme 'arrow
        neotree-smart-optn t
        neo-window-fixed-size nil)
  ;; Disable linum for neotree
  (add-hook 'neo-after-create-hook 'disable-neotree-hook))

(use-package page-break-lines :ensure t
  :config
  (global-page-break-lines-mode))

(use-package projectile :ensure t
  :config
  (setq projectile-known-projects-file
        (expand-file-name "projectile-bookmarks.eld" temp-dir)
	projectile-cache-file
        (expand-file-name "projectile-cache" temp-dir))
  (setq projectile-completion-system 'ivy)

  (projectile-global-mode))

(use-package recentf :ensure t
  :config
  (setq recentf-save-file (recentf-expand-file-name "~/.emacs.d/private/cache/recentf"))
  (recentf-mode 1))

(use-package smartparens :ensure t
  :config
  (require 'smartparens-config)
  (smartparens-global-mode))

(use-package smex :ensure t)

(use-package string-inflection :ensure t)

(use-package treemacs :ensure t
  :config
  (setq treemacs-show-hidden-files nil
	treemacs-file-event-delay 5000)
  (treemacs-filewatch-mode t)
  (treemacs-follow-mode t)
  (treemacs-git-mode 'simple)
  ;; mode hook
  (defun bgs-treemacs-mode-hook ()
    (face-remap-add-relative 'hl-line :background "purple4")
    (setq cursor-type t))
  (add-hook 'treemacs-mode-hook #'bgs-treemacs-mode-hook))

(use-package treemacs-projectile :ensure t
  :bind
  ("<f8>" . treemacs-toggle)
  ("<f9>" . treemacs-projectile-toggle))

(use-package undo-tree :ensure t
  :config
  ;; Remember undo history
  (setq
   undo-tree-auto-save-history nil
   undo-tree-history-directory-alist `(("." . ,(concat temp-dir "/undo/"))))
  (global-undo-tree-mode 1))

(use-package vlf :ensure t)

(use-package which-key :ensure t
  :init
  (setq which-key-mode-map (make-sparse-keymap))
  (bind-keys :map which-key-mode-map
	     :prefix-map which-key-prefix-map
	     :prefix "C-c W"
	     ("t" . which-key-show-top-level)
	     ("k" . which-key-show-keymap)
	     ("m" . which-key-show-minor-mode-keymap))
  (which-key-mode)
  :config
  (setq which-key-lighter ""
	which-key-popup-type 'side-window
	which-key-max-description-length 180
	which-key-side-window-max-height .50
	which-key-max-display-columns 1
	which-key-side-window-location (quote right)
	which-key-side-window-max-width 0.433))

(use-package windmove :ensure t
  :bind
  ("<C-up>" . windmove-up)
  ("<C-down>" . windmove-down)
  ("<C-left>" . windmove-left)
  ("<C-right>" . windmove-right))

(use-package wgrep :ensure t)

(use-package yasnippet :ensure t
  :config
  (yas-global-mode 1))

(use-package zygospore :ensure t
  :bind
  ("C-x 1" . zygospore-toggle-delete-other-windows))


(provide '05-base-extensions)
