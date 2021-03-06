(require 'package)


(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    ein
    elpy
    flycheck
    py-autopep8))

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)


(setq evil-want-integration t) ;; This is optional since it's already set to t by default.
(setq evil-want-keybinding nil)
(add-to-list 'load-path "~/.emacs.d/evil")
(require 'evil)
(evil-mode 1)
(when (require 'evil-collection nil t)
  (evil-collection-init))

(add-to-list 'load-path "~/.emacs.d/emacs-terraform-mode")
(require 'terraform-mode)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("bf390ecb203806cbe351b966a88fc3036f3ff68cd2547db6ee3676e87327b311" default)))
 '(package-selected-packages
   (quote
    (auto-complete flymake-go flymake-go-staticcheck go-autocomplete go-impl go-imports go-mode go-playground ansible ansible-doc ansible-vault cliphist neotree ac-ispell ace-window company-quickhelp company-terraform centaur-tabs github-review anaconda-mode company company-ansible company-go company-restclient sr-speedbar spacemacs-theme sql-indent flycheck-yamllint doom-themes py-isort evil-collection multi-term k8s-mode treemacs-icons-dired treemacs-projectile treemacs-evil treemacs groovy-mode jenkins nord-theme frame-local ov s-buffer dash-functional dirtree exotica-theme flycheck-pycheckers flycheck flycheck-pyflakes all-the-icons smart-mode-line-atom-one-dark-theme smart-mode-line atom-one-dark-theme python-docstring powerline helm-projectile flycheck-mypy flymake-json helm-core helm ggtags material-theme importmagic exec-path-from-shell dockerfile-mode docker ranger markdown-mode projectile ag magit format-sql org-link-minor-mode yaml-mode elpy cyberpunk-theme)))
 '(terraform-indent-level 2))





;; BASIC CUSTOMIZATION
;; --------------------------------------

(setq inhibit-startup-message t) ;; hide the startup message
; (load-theme 'material t) ;; load material theme
(load-theme 'exotica t)
; (load-theme 'spacemacs-dark t)
(global-linum-mode t) ;; enable line numbers globally
(require 'powerline)
(powerline-default-theme)
(show-paren-mode 1)
(require 'sr-speedbar)

(defun kill-other-buffers ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer
          (delq (current-buffer)
                (remove-if-not 'buffer-file-name (buffer-list)))))


(setq-default indent-tabs-mode nil)
(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))
(add-hook 'before-save-hook 'whitespace-cleanup)

;; ORG CUSTOMIZATION
;; --------------------------------------

(setq org-agenda-files '("~/.org"))


;; Window CONFIGURATION
;; --------------------------------------
(global-set-key (kbd "M-p") 'ace-window)
(global-set-key (kbd "C-'") 'neotree-toggle)


;; MAGIT CONFIGURATION
;; --------------------------------------
;; full screen magit-status


;; PYTHON CONFIGURATION
;; --------------------------------------

(elpy-enable)
(setq elpy-rpc-python-command "python3")
(setq python-shell-interpreter "python3"
      python-shell-interpreter-args "-i")
(pyvenv-activate "/Users/prajakt.shastry/Documents/Projects/virtualenvs/emacs")

(add-hook 'after-init-hook #'global-flycheck-mode)
(global-flycheck-mode 1)
(require 'flycheck-yamllint)
(with-eval-after-load 'flycheck
  (add-hook 'flycheck-mode-hook #'flycheck-pycheckers-setup)
  (add-hook 'flycheck-mode-hook #'flycheck-pycheckers-setup)
  (add-hook 'flycheck-mode-hook 'flycheck-yamllint-setup))


(flycheck-define-checker
    python-mypy ""
    :command ("mypy"
              "--ignore-missing-imports" "--fast-parser"
              "--python-version" "3.7"
              source-original)
    :error-patterns
    ((error line-start (file-name) ":" line ": error:" (message) line-end))
    :modes python-mode)


(add-to-list 'flycheck-checkers 'python-mypy t)
    (flycheck-add-next-checker 'python-pylint 'python-mypy t)

;; enable autopep8 formatting on save
(require 'py-autopep8)
;(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
;(add-hook 'elpy-mode-hook 'importmagic-mode)
(require 'py-isort)
(add-hook 'before-save-hook 'py-isort-before-save)
(require 'blacken)
(setq blacken-skip-string-normalization "false")
(add-hook 'python-mode-hook 'blacken-mode)

;; SNIPPET CONFIGURATION
;; --------------------------------------
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/snippets")

;; YAML CONFIGURATION
;; --------------------------------------

(require 'yaml-mode)
    (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

(add-hook 'yaml-mode-hook
    '(lambda ()
       (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

(require 'k8s-mode)


;; MYSQL CONFIGURATION
;; --------------------------------------
(setq sql-postgres-login-params
      '((user :default "p.shastry")
        (database :default "eicache")
        (server :default "bi-master.db.vividseats.com")
        (port :default 3306)))

(eval-after-load "sql"
  '(load-library "sql-indent"))

;; Navigation CONFIGURATION
;; --------------------------------------

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(require 'ranger)
(eval-after-load 'dired
  '(progn
     (define-key dired-mode-map (kbd "C-c n") 'my-dired-create-file)
     (defun my-dired-create-file (file)
       "Create a file called FILE.
If FILE already exists, signal an error."
       (interactive
        (list (read-file-name "Create file: " (dired-current-directory))))
       (let* ((expanded (expand-file-name file))
              (try expanded)
              (dir (directory-file-name (file-name-directory expanded)))
              new)
         (if (file-exists-p expanded)
             (error "Cannot create file %s: file exists" expanded))
         ;; Find the topmost nonexistent parent dir (variable `new')
         (while (and try (not (file-exists-p try)) (not (equal new try)))
           (setq new try
                 try (directory-file-name (file-name-directory try))))
         (when (not (file-exists-p dir))
           (make-directory dir t))
         (write-region "" nil expanded t)
         (when new
           (dired-add-file new)
           (dired-move-to-filename))))))

(require 'helm-config)

(global-set-key (kbd "M-x") 'helm-M-x)

(setq backup-directory-alist `(("." . "~/.saves")))

(defun to-underscore ()
  (interactive)
  (progn (replace-regexp "\\([A-Z]\\)" "_\\2" nil (region-beginning) (region-end)) (downcase-region (region-beginning) (region-end))
))
(require 'multi-term)
(setq multi-term-program "/bin/zsh")
(add-to-list 'load-path "~/.local/share/icons-in-terminal/") ;; If it's not already done
;(add-to-list 'load-path "~/.emacs.d/sidebar.el/")
;(require 'sidebar)
;(global-set-key (kbd "C-x C-f") 'sidebar-open)
;(global-set-key (kbd "C-x C-a") 'sidebar-buffers-open)

;; smart-mode-line
(setq sml/theme 'respectful)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
