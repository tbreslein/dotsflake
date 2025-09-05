;; TODO
;; REFS
;;   - [ ] https://github.com/MiniApollo/kickstart.emacs
;;   - [ ] https://github.com/LionyxML/emacs-kick

;; the default is 800 kB (measured in bytes)
;; reset this to a smaller value at the end for shorter gc pauses
(setq gc-cons-threshold (* 50 1000 1000))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "http://elpa.nongnu.org/nongnu/")))
(setq package-quickstart t)

(defcustom my/modal-pkg "meow"
  "which package to use for modal editing"
  :type 'string
  :group 'my-config)
  
  (use-package emacs
  :custom
  (tool-bar-mode nil)
  (scroll-bar-mode nil)
  (menu-bar-mode nil)
  (tooltip-mode nil)
  (global-display-line-numbers-mode t)
  (global-hl-line-mode 1)
  (electric-indent-mode t)
  (blink-cursor-mode nil)
  (tab-width 4)
  (indent-tabs-mode nil)
  (tab-always-indent 'complete)
  (scroll-step 1)
  (scroll-margin 5)
  (scroll-conservatively 10) ;; 10000
  (mouse-wheel-progessive-speed nil)

  (savehist-mode t)
  (history-length 25)

  (use-dialog-box nil)
  (use-short-answers t)
  (auto-window-vscroll nil)
  (display-line-numbers-type 'visual)
  (display-line-numbers-width-start t)

  (make-backup-files nil)
  (auto-save-default nil)
  (create-lockfiles nil)

  (treesit-font-lock-level 4)
  (truncate-lines t)

  (ring-bell-function 'ignore)
  (inhibit-startup-screen t)
  (initial-scratch-message "")

  ;; (frame-title-format nil)
  (enable-recursive-minibuffers t)

  :hook
  (prog-mode . display-line-numbers-mode)
  
  :config
  (setopt display-fill-column-indicator-column 80)
  (global-display-fill-column-indicator-mode +1)
  (modify-coding-system-alist 'file "" 'utf-8)
  (global-auto-revert-mode t)
  (setq read-process-output-max (* 1024 1024 4))
  ;; (add-to-list 'default-frame-alist '(inhibit-double-buffering . t))
  (setq custom-file "~/.emacs.d/custom.el")
  (load custom-file 'noerror 'nomessage)
  (save-place-mode 1)
  
  (defun skip-these-buffers (_window buffer _bury-or-kill)
    "Function for `switch-to-prev-buffer-skip'."
    (string-match "\\*[^*]+\\*" (buffer-name buffer)))
  (setq switch-to-prev-buffer-skip 'skip-these-buffers)
  
  (set-face-attribute 'default nil :family "Hack Nerd Font" :height (if (eq system-type 'darwin) 170 240))
  (add-to-list 'default-frame-alist '(alpha-background . 90))
  (when (eq system-type 'darwin)
    (setq mac-command-modifier 'meta))

  (add-hook 'after-init-hook
            (lambda ()
              (message "Emacs has fully loaded.")
              (with-current-buffer (get-buffer-create "*scratch*")
                (insert (format
                         ";;  Loading time : %s
;;  Packages     : %s
"
                         (emacs-init-time)
                         (number-to-string (length package-activated-list)))))))
      
  :bind (
	 ([escape] . keyboard-escape-quit)
	 ("C-+" . text-scale-increase)
	 ("C--" . text-scale-decrease)
  )
  )

(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker t))

;; (use-package doom-themes
;;   :ensure t
;;   :config
;;   (setq doom-themes-enable-bold t
;;         doom-themes-enable-italic t)
;;   (load-theme 'doom-gruvbox t)
;;   (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :custom
  (doom-modeline-height 25)
  :hook (after-init . doom-modeline-mode))

(use-package nerd-icons :ensure t :if (display-graphic-p))
(use-package diminish :ensure t)

  (use-package meow
    :ensure t
    :config
    (defun meow-setup ()
     (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
     (meow-motion-define-key
      '("j" . meow-next)
      '("k" . meow-prev)
      '("<escape>" . ignore))
     (meow-leader-define-key
      ;; Use SPC (0-9) for digit arguments.
      '("1" . meow-digit-argument)
      '("2" . meow-digit-argument)
      '("3" . meow-digit-argument)
      '("4" . meow-digit-argument)
      '("5" . meow-digit-argument)
      '("6" . meow-digit-argument)
      '("7" . meow-digit-argument)
      '("8" . meow-digit-argument)
      '("9" . meow-digit-argument)
      '("0" . meow-digit-argument)
      '("/" . meow-keypad-describe-key)
      '("?" . meow-cheatsheet))
     (meow-normal-define-key
      '("0" . meow-expand-0)
      '("9" . meow-expand-9)
      '("8" . meow-expand-8)
      '("7" . meow-expand-7)
      '("6" . meow-expand-6)
      '("5" . meow-expand-5)
      '("4" . meow-expand-4)
      '("3" . meow-expand-3)
      '("2" . meow-expand-2)
      '("1" . meow-expand-1)
      '("-" . negative-argument)
      '(";" . meow-reverse)
      '("," . meow-inner-of-thing)
      '("." . meow-bounds-of-thing)
      '("[" . meow-beginning-of-thing)
      '("]" . meow-end-of-thing)
      '("a" . meow-append)
      '("A" . meow-open-below)
      '("b" . meow-back-word)
      '("B" . meow-back-symbol)
      '("c" . meow-change)
      '("d" . meow-delete)
      '("D" . meow-backward-delete)
      '("e" . meow-next-word)
      '("E" . meow-next-symbol)
      '("f" . meow-find)
      '("g" . meow-cancel-selection)
      '("G" . meow-grab)
      '("h" . meow-left)
      '("H" . meow-left-expand)
      '("i" . meow-insert)
      '("I" . meow-open-above)
      '("j" . meow-next)
      '("J" . meow-next-expand)
      '("k" . meow-prev)
      '("K" . meow-prev-expand)
      '("l" . meow-right)
      '("L" . meow-right-expand)
      '("m" . meow-join)
      '("n" . meow-search)
      '("o" . meow-block)
      '("O" . meow-to-block)
      '("p" . meow-yank)
      '("q" . meow-quit)
      '("Q" . meow-goto-line)
      '("r" . meow-replace)
      '("R" . meow-swap-grab)
      '("s" . meow-kill)
      '("t" . meow-till)
      '("u" . meow-undo)
      '("U" . meow-undo-in-selection)
      '("v" . meow-visit)
      '("w" . meow-mark-word)
      '("W" . meow-mark-symbol)
      '("x" . meow-line)
      '("X" . meow-goto-line)
      '("y" . meow-save)
      '("Y" . meow-sync-grab)
      '("z" . meow-pop-selection)
      '("'" . repeat)
      '("<escape>" . ignore)))
  (meow-setup)
  (meow-global-mode 1))

 ;;  (use-package undo-tree
 ;;    :defer t
 ;;    :ensure t
 ;;    :hook (after-init . global-undo-tree-mode)
 ;;    :init
 ;;    (setq undo-tree-visualizer-timestamps t
 ;;          undo-tree-visualizer-diff t
 ;;          undo-limit 800000
 ;;          undo-strong-limit 12000000
 ;;          undo-outer-limit 120000000)
 ;;    :config
 ;;    (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/.cache/undo"))))
  
 ;; (use-package evil
 ;;   :ensure t
 ;;   :defer t
 ;;   :hook (after-init . evil-mode)
 ;;   :init
 ;;   (setq evil-want-integration t
 ;;         evil-want-keybinding nil
 ;;         evil-want-C-u-scroll t
 ;;         evil-want-C-u-delete t)
 ;;   :config
 ;;   (evil-set-undo-system 'undo-tree)
 ;;   (setq evil-leader/in-all-states t
 ;;         evil-want-fine-undo t)
 ;;   (evil-set-leader 'normal (kbd "SPC"))
 ;;   (evil-set-leader 'visual (kbd "SPC"))

 ;;   (evil-define-key 'normal 'global (kbd "<leader> s f") 'consult-find
 ;;                                    (kbd "<leader> s g") 'consult-grep
 ;;                                    (kbd "<leader> s G") 'consult-git-grep
 ;;                                    (kbd "<leader> s r") 'consult-ripgrep
 ;;                                    (kbd "<leader> s h") 'consult-info
 ;;                                    (kbd "<leader> /") 'consult-line)

 ;;   (evil-define-key 'normal 'global (kbd "] d") 'flymake-goto-next-error
 ;;                                    (kbd "[ d") 'flymake-goto-prev-error
 ;;                                    (kbd "<f4>") 'flymake-goto-next-error
 ;;                                    (kbd "<f3>") 'flymake-goto-prev-error)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> x d") 'dired
 ;;                                    (kbd "<leader> x j") 'dired-jump
 ;;                                    (kbd "<leader> x f") 'find-file)
 ;;   (evil-define-key 'normal 'global (kbd "] h") 'diff-hl-next-hunk
 ;;                                    (kbd "<f11>") 'diff-hl-next-hunk
 ;;                                    (kbd "[ h") 'diff-hl-prev-hunk
 ;;                                    (kbd "<f12>") 'diff-hl-prev-hunk)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> g g") 'magit-status)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> g l") 'magit-log-current)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> g d") 'magit-diff-buffer-file)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> g D") 'diff-hl-show-hunk)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> g b") 'vc-annotate)
 ;;   (evil-define-key 'normal 'global (kbd "] b") 'switch-to-next-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "[ b") 'switch-to-prev-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "<f6>") 'switch-to-next-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "<f5>") 'switch-to-prev-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> b i") 'consult-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> b b") 'ibuffer)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> b d") 'kill-current-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> b s") 'save-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> p b") 'consult-project-buffer)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> p p") 'project-switch-project)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> p f") 'project-find-file)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> p g") 'project-find-regexp)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> p k") 'project-kill-buffers)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> p D") 'project-dired)
 ;;   (evil-define-key 'normal 'global (kbd "<leader> u") 'undo-tree-visualize)
 ;;   ;; NOTE: meow has these practically built-in through keypac SPC h
 ;;   (evil-define-key 'normal 'global (kbd "<leader> h m") 'describe-mode
 ;;                                    (kbd "<leader> h f") 'describe-function
 ;;                                    (kbd "<leader> h v") 'describe-variable
 ;;                                    (kbd "<leader> h k") 'describe-key)
 ;;   (evil-define-key 'normal 'global (kbd "] t") 'tab-next)
 ;;   (evil-define-key 'normal 'global (kbd "[ t") 'tab-previous)
 ;;   (evil-define-key 'normal 'global (kbd "<f2>") 'tab-next)
 ;;   (evil-define-key 'normal 'global (kbd "<f1>") 'tab-previous)
 ;;   (evil-define-key 'normal 'lsp-mode-map
 ;;                    (kbd "grr") 'lsp-find-references
 ;;                    (kbd "gra") 'lsp-execute-code-action
 ;;                    (kbd "grn") 'lsp-rename
 ;;                    (kbd "gri") 'lsp-find-implementation
 ;;                    (kbd "gff") 'lsp-format-buffer)
 ;;   )
  
;; (use-package evil
        ;;   :ensure t
        ;;   :demand t
        ;;   :after undo-fu
;;   :init
;;   (setq evil-want-keybinding nil)
;;   (setq evil-undo-system 'undo-fu)
;;   :config
;;   (setq evil-want-C-d-scroll t)
;;   (setq evil-want-C-u-scroll t)
;;   (setq evil-split-window-below t)
;;   (setq evil-vsplit-window-right t)
;;   (setq evil-insert-state-cursor 'box)
;;   (setq evil-want-Y-yank-to-eol t)
;;   (evil-set-leader nil (kbd "SPC"))
;;   (evil-global-set-key 'normal (kbd "C-d") (lambda () (interactive) (evil-scroll-down 0) (recenter)))
;;   (evil-global-set-key 'normal (kbd "C-u") (lambda () (interactive) (evil-scroll-up 0) (recenter)))
;;   (evil-global-set-key 'visual (kbd "C-d") (lambda () (interactive) (evil-scroll-down 0) (recenter)))
;;   (evil-global-set-key 'visual (kbd "C-u") (lambda () (interactive) (evil-scroll-up 0) (recenter)))
;;   (evil-global-set-key 'normal (kbd "n") (lambda () (interactive) (evil-search-next) (recenter)))
;;   (evil-global-set-key 'normal (kbd "N") (lambda () (interactive) (evil-search-previous) (recenter)))
;;   (evil-global-set-key 'visual (kbd "J") (lambda () (interactive) (drag-stuff-down 1) (evil-indent)))
;;   (evil-global-set-key 'visual (kbd "K") (lambda () (interactive) (drag-stuff-up 1) (evil-indent)))
;;   (evil-global-set-key 'motion (kbd "j") 'evil-next-visual-line)
;;   (evil-global-set-key 'motion (kbd "k") 'evil-previous-visual-line)
;;   (evil-global-set-key 'normal (kbd "M-m") 'compile)
;;   (evil-global-set-key 'normal (kbd "C-h") 'evil-window-left)
;;   (evil-global-set-key 'normal (kbd "C-j") 'evil-window-down)
;;   (evil-global-set-key 'normal (kbd "C-k") 'evil-window-up)
;;   (evil-global-set-key 'normal (kbd "C-l") 'evil-window-right)
;;   (evil-global-set-key 'normal (kbd "<leader>gg") 'magit)
;;   (evil-global-set-key 'normal (kbd "<leader>sj") 'evil-window-new)
;;   (evil-global-set-key 'normal (kbd "<leader>sl") 'evil-window-vnew)
;;   (evil-global-set-key 'normal (kbd "<leader>tj") (lambda () (interactive) (evil-window-new 20 "") (vterm)))
;;   (evil-global-set-key 'normal (kbd "<leader>tl") (lambda () (interactive) (evil-window-vnew nil "") (vterm)))
;;   (evil-mode))

;; (use-package evil-collection
;;   :ensure t
;;   :after evil
;;   :config
;;   (evil-collection-init))

;; (use-package evil-commentary
;;   :ensure t
;;   :after evil
;;   :config
;;   (evil-define-operator +evil-join-a (beg end)
;;     "Join the selected lines.
;; This advice improves on `evil-join' by removing comment delimiters when joining
;; commented lines, by using `fill-region-as-paragraph'.
;; From https://github.com/emacs-evil/evil/issues/606"
;;     :motion evil-line
;;     (let* ((count (count-lines beg end))
;; 	   (count (if (> count 1) (1- count) count))
;; 	   (fixup-mark (make-marker)))
;;       (dotimes (var count)
;; 	(if (and (bolp) (eolp))
;; 	    (join-line 1)
;; 	  (let* ((end (line-beginning-position 3))
;; 		 (fill-column (1+ (- end beg))))
;; 	    (set-marker fixup-mark (line-end-position))
;; 	    (fill-region-as-paragraph beg end nil t)
;; 	    (goto-char fixup-mark)
;; 	    (fixup-whitespace))))
;;       (set-marker fixup-mark nil)))
;;   (evil-global-set-key 'normal (kbd "J") '+evil-join-a)
;;   (evil-commentary-mode))


(setq gc-cons-threshold (* 2 1000 1000))

;; (use-package volatile-highlights :ensure t :config (volatile-highlights-mode t))



; ;; path and direnv
; ;; ensure that emacs sees the same path as the login shell
; (use-package exec-path-from-shell
;   :ensure t
;   :config
;   (dolist (var '("LC_CTYPE" "NIX_PROFILES" "NIX_SSL_CERT_FILE"))
;     (add-to-list 'exec-path-from-shell-variables var))
;   (when (memq window-system '(mac ns x))
;     (exec-path-from-shell-initialize)))
;
; ;; automatically load envrc
; (use-package envrc
;   :ensure t
;   :custom
;   (envrc-show-summary-in-minibuffer nil)
;   :hook (elpaca-after-init . envrc-global-mode))
;
;
; ;; projects
; (use-package compile
;   :ensure nil
;   :config
;   (setq compilation-scroll-output t))
;
; ;; NAVIGATION
; (use-package perspective
;   :ensure t
;   :bind
;   ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
;   :custom
;   (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
;   :init
;   (persp-mode))
;
; ;; ;; EGLOT SOMEHOW NEEDS THIS TO CORRECTLY DETERMINE THE PROJECT ROOT
; ;; ;; This SHOULD take care of the problem that project-root-override tries to solve,
; ;; ;; but for some reason it does not work. I have no idea why, but I don't seem to
; ;; ;; be the only one.
; ;; (setq project-vc-extra-root-markers
; ;;       '("Cargo.toml" "pyproject.toml"))
;
; (defun project-root-override (dir)
;   "Find DIR's project root by searching for a '.project.el' file.
;
;   If this file exists, it marks the project root.  For convenient compatibility
;   with Projectile, '.projectile' is also considered a project root marker.
;
;   https://blog.jmthornton.net/p/emacs-project-override"
;   (let ((root (or (locate-dominating-file dir ".project.el")
; 		  (locate-dominating-file dir ".projectile")
; 		  (locate-dominating-file dir "Cargo.toml")
; 		  (locate-dominating-file dir "setup.py")
; 		  (locate-dominating-file dir "requirements.txt")
; 		  (locate-dominating-file dir "pyproject.toml")))
; 	(backend (ignore-errors (vc-responsible-backend dir))))
;     (when root (list 'vc backend root))))
;
; ;; Note that we cannot use :hook here because `project-find-functions' doesn't
; ;; end in "-hook", and we can't use this in :init because it won't be defined
; ;; yet.
; (use-package project
;   :ensure t
;   :config
;   (add-hook 'project-find-functions #'project-root-override))
;
; (use-package persp-projectile :ensure t)
;
; (use-package rg :ensure t)
;
; (use-package projectile
;   :ensure t
;   :custom
;   (projectile-project-search-path
;    '(("~/code" . 1)
;      ("~/.dotfiles" . 0)
;      ("~/notes" . 0)
;      ("~/work" . 1)
;      ("~/work/repos" . 1)))
;   (projectile-require-project-root nil)
;   (projectile-sort-order 'recentf)
;   :config
;   (defcustom projectile-project-root-functions
;     '(projectile-root-local
;       projectile-root-marked
;       projectile-root-top-down
;       projectile-root-top-down-recurring
;       projectile-root-bottom-up)
;     "A list of functions for finding project roots."
;     :group 'projectile
;     :type '(repeat function))
;   ;; (evil-global-set-key 'normal (kbd "<leader>f") 'projectile-command-map)
;   (projectile-mode +1))
;
; ;; completion
; (when (< emacs-major-version 31)
;   (advice-add #'completing-read-multiple :filter-args
;               (lambda (args)
;                 (cons (format "[CRM%s] %s"
;                               (string-replace "[ \t]*" "" crm-separator)
;                               (car args))
;                       (cdr args)))))
;
; ;; ;; (setq text-mode-ispell-word-completion nil) ;; use cape-dict instead
;
; ;; Hide commands in M-x which do not work in the current mode.  Vertico
; ;; commands are hidden in normal buffers. This setting is useful beyond
; ;; Vertico.
; (setq read-extended-command-predicate #'command-completion-default-include-p)
;
; ;; ;; Do not allow the cursor in the minibuffer prompt
; (setq minibuffer-prompt-properties
;  '(read-only t cursor-intangible t face minibuffer-prompt))
;
; (use-package orderless
;   :ensure t
;   :after evil
;   :custom
;   (completion-styles '(orderless-flex basic))
;   (completion-category-overrides '((file (styles basic partial-completion)))))
;
; (use-package vertico
;   :ensure t
;   :after orderless
;   :hook (elpaca-after-init . vertico-mode)
;   :custom
;   (vertico-count 10)
;   (vertico-resize nil)
;   (vertico-cycle t)
;   (completion-styles '(flex basic))
;   ;:config
;   ;(evil-define-key 'normal 'vertico-map (kbd "M-h") 'vertico-next-group)
;   ;(evil-define-key 'normal 'vertico-map (kbd "M-j") 'vertico-next)
;   ;(evil-define-key 'normal 'vertico-map (kbd "M-k") 'vertico-previous)
;   ;(evil-define-key 'normal 'vertico-map (kbd "M-;") 'vertico-previous-group)
;   )
;
; (use-package marginalia
;   :ensure t
;   :after vertico
;   :config
;   (marginalia-mode 1))
;
; (use-package corfu
;   :ensure t
;   :custom
;   (corfu-cycle t)
;   (corfu-auto t)
;   (corfu-auto-prefix 1)
;   (corfu-echo-delay 0.1)
;   (corfu-preview-current nil)
;   (corfu-auto-delay 0)
;   (corfu-popupinfo-delay '(0.1 . 0.1))
;
;   ;:config
;   ;(evil-define-key 'insert 'corfu-map (kbd "C-j") 'corfu-next)
;   ;(evil-define-key 'insert 'corfu-map (kbd "C-k") 'corfu-previous)
;   ;(evil-define-key 'insert 'corfu-map (kbd "C-l") 'corfu-insert)
;   ;(evil-define-key 'insert 'corfu-map (kbd "C-h") 'corfu-insert-separator)
;
;   :init
;   (global-corfu-mode))
;
; (use-package cape
;   :ensure t
;   :after corfu
;   :init
;   (add-to-list 'completion-at-point-functions #'cape-file))
;
; ;; languages
; (use-package markdown-mode :ensure t)
; (use-package nix-mode :ensure t :mode "\\.nix\\'")
; (use-package zig-mode :ensure t :mode "\\.zig\\'")
; (use-package rust-mode :ensure t :mode "\\.rs\\'" :custom (rust-mode-treesitter-derive t))
; (use-package cargo :ensure t :hook (rust-ts-mode . cargo-minor-mode))
;   ;; :config (evil-define-key 'normal 'cargo-mode-map (kbd "C-c") 'cargo-minor-mode-command-map))
;
; ;; flymake ++ lsp
; (use-package flymake
;   :ensure nil
;   :after evil
;   :config
;   (add-hook 'emacs-lisp-mode-hook 'flymake-mode)
;   ;(evil-define-key 'normal 'flymake-mode-map (kbd "]d") 'flymake-goto-next-error)
;   ;(evil-define-key 'normal 'flymake-mode-map (kbd "[d") 'flymake-goto-prev-error)
;   ;(evil-define-key 'normal 'flymake-mode-map (kbd "gq") 'flymake-show-project-diagnostics)
;   (flymake-mode 1))
;
; (use-package flymake-diagnostic-at-point
;   :ensure t
;   :after flymake
;   :config
;   (add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode))
;
; (use-package apheleia
;   :ensure t
;   :config
;   (setf (alist-get 'black apheleia-formatters)
;         '("poetry" "run" "black" "-"))
;   (setf (alist-get 'nixpkgs-fmt apheleia-formatters)
;         '("nixpkgs-fmt"))
;   (setf (alist-get 'nix-mode apheleia-mode-alist)
;         '(nixpkgs-fmt))
;   (apheleia-global-mode +1))
;
; (use-package eglot
;   :ensure nil
;   :hook
;   ((python-ts-mode
;     rust-ts-mode
;     zig-ts-mode
;     go-ts-mode
;     tuareg-mode
;     ) . eglot-ensure)
;   :config
;   (setq eglot-ignored-server-capabilities '(:inlayHintProvider :colorProvider))
;   ;; (add-to-list 'eglot-server-programs
;   ;;              '((python-mode python-ts-mode)
;   ;; 		 "basedpyright-langserver" "--stdio"))
;   (eglot-inlay-hints-mode -1))
;
; (use-package yasnippet :ensure t :config (yas-global-mode 1))
;
; ;; (use-package eglot-booster
; ;;   :vc (:url "https://github.com/jdtsmith/eglot-booster.git")
; ;;   :after eglot
; ;;   :config (eglot-booster-mode))
