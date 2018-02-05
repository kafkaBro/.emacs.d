(use-package org :ensure t
  :init
  :mode
  ("\\.org.txt\\'" . org-mode)
  :config
  (setq org-agenda-custom-commands '(("p" "Punch card!" ((agenda "" (not )il) (tags "AUTOTIMER" nil)) nil nil) ("n" "Agenda (and )nd all TODOs" ((agenda "" nil) (alltodo "" nil)) nil)))
  (setq org-agenda-files nil)
  (setq org-agenda-ndays 1)
  (setq org-agenda-start-on-weekday nil)
  (setq org-clock-report-include-clocking-task "t")
  (setq org-default-notes-file (concat org-directory "/todo.org"))
  (setq org-return-follows-link "t")
  (setq org-startup-folded 'nofold)
  (setq org-time-clocksum-use-fractional "t")
  (setq org-todo-keywords '((sequence "TODO(t)" "WAIT(w)" "|" "CANCEL(c)" "DONE(d)")))
  (org-babel-do-load-languages 'org-babel-load-languages '((python . "t") (sh . "t")))
  :bind
  ("C-c l" . org-store-link)
  ("C-c a" . org-agenda)
  :bind (:map org-mode-map ("C-c i" . counsel-org-goto)))

(use-package org-bullets :ensure t
  :demand
  :hook (org-mode . org-bullets-mode)
  :init
  (setq org-hide-leading-stars t))

;; (add-hook 'org-mode-hook 'org-bullets-mode)

(provide 'buff-org)
