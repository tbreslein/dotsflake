;;;; TODO
;;
;;;; REFS
;; - [ ] https://github.com/MiniApollo/kickstart.emacs
;; - [ ] https://github.com/LionyxML/emacs-kick
;; - [ ] https://codeberg.org/ashton314/emacs-bedrock/src/branch/main/extras/org.el
;; - [ ] https://github.com/jakebox/jake-emacs/blob/main/jake-emacs/init.el
;; - [ ] https://github.com/xenodium/dotsies
;; - [ ] https://github.com/LionyxML/emacs-solo

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			             ("org" . "https://orgmode.org/elpa/")
			             ("elpa" . "https://elpa.gnu.org/packages/")
			             ("nongnu" . "http://elpa.nongnu.org/nongnu/")))
(setq package-quickstart t)

;;;; BUILTINS

(defcustom my/modal-pkg "meow"
  "Which package to use for modal editing."
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

  :bind (([escape] . keyboard-escape-quit)
	     ("C-+" . text-scale-increase)
	     ("C--" . text-scale-decrease)
         ("C-S-h" . windmove-left)
         ("C-S-j" . windmove-down)
         ("C-S-k" . windmove-up)
         ("C-S-l" . windmove-right))
  )

(use-package window
  :ensure nil
  :custom
  (display-buffer-alist
   '(
     ("\\*.*e?shell\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . left)
      (slot . -1))
     ("\\*\\(Backtrace\\|Warnings\\|Compile-Log\\|[Hh]elp\\|Messages\\|Bookmark List\\|Ibuffer\\|Occur\\|eldoc.*\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 0))

     ;; Example configuration for the LSP help buffer,
     ;; keeps it always on bottom using 25% of the available space:
     ("\\*\\(lsp-help\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 0))

     ;; Configuration for displaying various diagnostic buffers on
     ;; bottom 25%:
     ("\\*\\(Flymake diagnostics\\|xref\\|ivy\\|Swiper\\|Completions\\)"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 1))
     )))

(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-lah --group-directories-first")
  (dired-dwim-target t)
  (dired-guess-shell-alist-user
   '(("\\.\\(png\\|jpe?g\\|tiff\\)" "imv" "xdg-open" "open")
     ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open" "open")
     (".*" "open" "xdg-open")))
  (dired-kill-when-opening-new-dired-buffer t))

(use-package isearch
  :ensure nil
  :config
  (setq isearch-lazy-count t)
  (setq lazy-count-prefix-format "(%s/%s) ")
  (setq lazy-count-suffix-format nil)
  (setq search-whitespace-regexp ".*?")
  :bind (("C-s" . isearch-forward)
         ("C-r" . isearch-backward)))

(use-package vc
  :ensure nil
  :defer t
  :bind
  (("C-x v d" . vc-dir)
   ("C-x v =" . vc-diff)
   ("C-x v D" . vc-root-diff)
   ("C-x v v" . vc-next-action)))

(use-package smerge-mode
  :ensure nil
  :defer t
  :bind (:map smerge-mode-map
              ("C-c ^ u" . smerge-keep-upper)
              ("C-c ^ l" . smerge-keep-lower)
              ("C-c ^ n" . smerge-next)
              ("C-c ^ p" . smerge-previous)))

(use-package eldoc
  :ensure nil
  :init
  (global-eldoc-mode))

(use-package flymake
  :ensure nil
  :defer t
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-margin-indicators-string
   '((error "!»" compilation-error) (warning "»" compilation-warning)
     (note "»" compilation-info))))

(use-package which-key
  :ensure nil
  :defer t
  :hook
  (after-init . which-key-mode))

(use-package icomplete
  :ensure nil
  :custom
  (max-mini-window-height 12)
  :config
  (fido-vertical-mode))

;;;; EXTERNAL PLUGINS

(use-package eldoc-box
  :ensure t
  :defer t)

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

(use-package markdown-mode
  :defer t
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package nix-mode :ensure t :mode "\\.nix\\'")
(use-package zig-mode :ensure t :mode "\\.zig\\'")
(use-package rust-mode :ensure t :mode "\\.rs\\'" :custom (rust-mode-treesitter-derive t))
(use-package cargo :ensure t :hook (rust-ts-mode . cargo-minor-mode))
(use-package yaml-mode :ensure t)
(use-package json-mode :ensure t)

(use-package treesit-auto
  :ensure t
  :after emacs
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))

(use-package nerd-icons :ensure t :if (display-graphic-p))
(use-package diminish :ensure t)

;; path and direnv
;; ensure that emacs sees the same path as the login shell
(use-package exec-path-from-shell
  :ensure t
  :config
  (dolist (var '("LC_CTYPE" "NIX_PROFILES" "NIX_SSL_CERT_FILE"))
    (add-to-list 'exec-path-from-shell-variables var))
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; automatically load envrc
(use-package envrc
  :ensure t
  :custom
  (envrc-show-summary-in-minibuffer nil)
  :hook (after-init . envrc-global-mode))

;; ;; EGLOT SOMEHOW NEEDS THIS TO CORRECTLY DETERMINE THE PROJECT ROOT
;; ;; This SHOULD take care of the problem that project-root-override tries to solve,
;; ;; but for some reason it does not work. I have no idea why, but I don't seem to
;; ;; be the only one.
;; (setq project-vc-extra-root-markers
;;       '("Cargo.toml" "pyproject.toml"))
(defun project-root-override (dir)
  "Find DIR's project root by searching for a '.project.el' file.

  If this file exists, it marks the project root.  For convenient compatibility
  with Projectile, '.projectile' is also considered a project root marker.

  https://blog.jmthornton.net/p/emacs-project-override"
  (let ((root (or (locate-dominating-file dir ".project.el")
		          (locate-dominating-file dir ".projectile")
		          (locate-dominating-file dir "Cargo.toml")
		          (locate-dominating-file dir "setup.py")
		          (locate-dominating-file dir "requirements.txt")
		          (locate-dominating-file dir "pyproject.toml")
		          (locate-dominating-file dir ".git/")))
	    (backend (ignore-errors (vc-responsible-backend dir))))
    (when root (list 'vc backend root))))

;; Note that we cannot use :hook here because `project-find-functions' doesn't
;; end in "-hook", and we can't use this in :init because it won't be defined
;; yet.
(use-package project
  :ensure nil
  :config
  (add-hook 'project-find-functions #'project-root-override))

;; (use-package compile
;;   :ensure nil
;;   :config
;;   (setq compilation-scroll-output t))

;; ;; NAVIGATION
;; (use-package perspective
;;   :ensure t
;;   :bind
;;   ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
;;   :custom
;;   (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
;;   :init
;;   (persp-mode))

;; (use-package persp-projectile :ensure t)

;; (use-package rg :ensure t)

;; (use-package projectile
;;   :ensure t
;;   :custom
;;   (projectile-project-search-path
;;    '(("~/code" . 1)
;;      ("~/.dotfiles" . 0)
;;      ("~/notes" . 0)
;;      ("~/work" . 1)
;;      ("~/work/repos" . 1)))
;;   (projectile-require-project-root nil)
;;   (projectile-sort-order 'recentf)
;;   :config
;;   (defcustom projectile-project-root-functions
;;     '(projectile-root-local
;;       projectile-root-marked
;;       projectile-root-top-down
;;       projectile-root-top-down-recurring
;;       projectile-root-bottom-up)
;;     "A list of functions for finding project roots."
;;     :group 'projectile
;;     :type '(repeat function))
;;   ;; (evil-global-set-key 'normal (kbd "<leader>f") 'projectile-command-map)
;;   (projectile-mode +1))

(use-package apheleia
  :ensure t
  :config
  (setf (alist-get 'black apheleia-formatters)
        '("poetry" "run" "black" "-"))
  (setf (alist-get 'nixpkgs-fmt apheleia-formatters)
        '("nixpkgs-fmt"))
  (setf (alist-get 'nix-mode apheleia-mode-alist)
        '(nixpkgs-fmt))
  (apheleia-global-mode +1))

(use-package eglot
  :ensure nil
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)
  :hook
  ((python-ts-mode rust-ts-mode) . eglot-ensure)
  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider :colorProvider))
  ;; (add-to-list 'eglot-server-programs
  ;;              '((python-mode python-ts-mode)
  ;; 		 "basedpyright-langserver" "--stdio"))
  (eglot-inlay-hints-mode -1))

(use-package yasnippet :ensure t :config (yas-global-mode 1))

;; (use-package eglot-booster
;;   :vc (:url "https://github.com/jdtsmith/eglot-booster.git")
;;   :after eglot
                                        ; ;;   :config (eglot-booster-mode))

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

(use-package repeat-fu
  :ensure t
  :commands (repeat-fu-mode repeat-fu-execute)

  :config
  (setq repeat-fu-preset 'meow)

  :hook
  ((meow-mode)
   .
   (lambda ()
     (when (and (not (minibufferp)) (not (derived-mode-p 'special-mode)))
       (repeat-fu-mode)
       (define-key meow-normal-state-keymap (kbd "C-'") 'repeat-fu-execute)
       (define-key meow-insert-state-keymap (kbd "C-'") 'repeat-fu-execute)))))

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
;;   (setq evil-split-window-below t)
;;   (setq evil-vsplit-window-right t)
;;   (setq evil-insert-state-cursor 'box)
;;   (setq evil-want-Y-yank-to-eol t)
;;   (evil-set-leader nil (kbd "SPC"))
;;   ;(evil-global-set-key 'normal (kbd "C-d") (lambda () (interactive) (evil-scroll-down 0) (recenter)))
;;   ;(evil-global-set-key 'normal (kbd "C-u") (lambda () (interactive) (evil-scroll-up 0) (recenter)))
;;   ;(evil-global-set-key 'visual (kbd "C-d") (lambda () (interactive) (evil-scroll-down 0) (recenter)))
;;   ;(evil-global-set-key 'visual (kbd "C-u") (lambda () (interactive) (evil-scroll-up 0) (recenter)))
;;   (evil-global-set-key 'normal (kbd "n") (lambda () (interactive) (evil-search-next) (recenter)))
;;   (evil-global-set-key 'normal (kbd "N") (lambda () (interactive) (evil-search-previous) (recenter)))
;;   (evil-global-set-key 'motion (kbd "j") 'evil-next-visual-line)
;;   (evil-global-set-key 'motion (kbd "k") 'evil-previous-visual-line)
;;   (evil-global-set-key 'normal (kbd "M-m") 'compile)
;;   (evil-global-set-key 'normal (kbd "C-h") 'evil-window-left)
;;   (evil-global-set-key 'normal (kbd "C-j") 'evil-window-down)
;;   (evil-global-set-key 'normal (kbd "C-k") 'evil-window-up)
;;   (evil-global-set-key 'normal (kbd "C-l") 'evil-window-right)

;;   (evil-define-key 'normal 'global (kbd "<leader> s f") 'consult-find
;;                                    (kbd "<leader> s g") 'consult-grep
;;                                    (kbd "<leader> s G") 'consult-git-grep
;;                                    (kbd "<leader> s r") 'consult-ripgrep
;;                                    (kbd "<leader> s h") 'consult-info
;;                                    (kbd "<leader> /") 'consult-line

;;                                    (kbd "] d") 'flymake-goto-next-error
;;                                    (kbd "[ d") 'flymake-goto-prev-error
;;                                    (kbd "<f4>") 'flymake-goto-next-error
;;                                    (kbd "<f3>") 'flymake-goto-prev-error

;;                                    (kbd "<leader> x d") 'dired
;;                                    (kbd "<leader> x j") 'dired-jump
;;                                    (kbd "<leader> x f") 'find-file

;;                                    (kbd "] h") 'diff-hl-next-hunk
;;                                    (kbd "<f11>") 'diff-hl-next-hunk
;;                                    (kbd "[ h") 'diff-hl-prev-hunk
;;                                    (kbd "<f12>") 'diff-hl-prev-hunk

;;                                    (kbd "<leader> g g") 'magit-status
;;                                    (kbd "<leader> g l") 'magit-log-current
;;                                    (kbd "<leader> g d") 'magit-diff-buffer-file
;;                                    (kbd "<leader> g D") 'diff-hl-show-hunk
;;                                    (kbd "<leader> g b") 'vc-annotate

;;                                    (kbd "] b") 'switch-to-next-buffer
;;                                    (kbd "[ b") 'switch-to-prev-buffer
;;                                    (kbd "<f6>") 'switch-to-next-buffer
;;                                    (kbd "<f5>") 'switch-to-prev-buffer
;;                                    (kbd "<leader> b i") 'consult-buffer
;;                                    (kbd "<leader> b b") 'ibuffer
;;                                    (kbd "<leader> b d") 'kill-current-buffer
;;                                    (kbd "<leader> b s") 'save-buffer
;;                                    (kbd "<leader> p b") 'consult-project-buffer
;;                                    (kbd "<leader> p p") 'project-switch-project
;;                                    (kbd "<leader> p f") 'project-find-file
;;                                    (kbd "<leader> p g") 'project-find-regexp
;;                                    (kbd "<leader> p k") 'project-kill-buffers
;;                                    (kbd "<leader> p D") 'project-dired
;;                                    (kbd "<leader> u") 'undo-tree-visualize
;;   ;; NOTE: meow has these practically built-in through keypac SPC h
;;                                    (kbd "<leader> h m") 'describe-mode
;;                                    (kbd "<leader> h f") 'describe-function
;;                                    (kbd "<leader> h v") 'describe-variable
;;                                    (kbd "<leader> h k") 'describe-key

;;                                    (kbd "] t") 'tab-next
;;                                    (kbd "[ t") 'tab-previous
;;                                    (kbd "<f2>") 'tab-next
;;                                    (kbd "<f1>") 'tab-previous)

;;   (evil-define-key 'normal 'lsp-mode-map
;;                     (kbd "grr") 'lsp-find-references
;;                     (kbd "gra") 'lsp-execute-code-action
;;                     (kbd "grn") 'lsp-rename
;;                     (kbd "gri") 'lsp-find-implementation
;;                     (kbd "gff") 'lsp-format-buffer)
;;   )

;;   (defun ek/lsp-describe-and-jump ()
;;     "Show hover documentation and jump to *lsp-help* buffer."
;;     (interactive)
;;     (lsp-describe-thing-at-point)
;;     (let ((help-buffer "*lsp-help*"))
;;       (when (get-buffer help-buffer)
;;         (switch-to-buffer-other-window help-buffer))))

;;   ;; Emacs 31 finaly brings us support for 'floating windows' (a.k.a. "child frames")
;;   ;; to terminal Emacs. If you're still using 30, docs will be shown in a buffer at the
;;   ;; inferior part of your frame.
;;   (evil-define-key 'normal 'global (kbd "K")
;;     (if (>= emacs-major-version 31)
;;         #'eldoc-box-help-at-point
;;         #'ek/lsp-describe-and-jump))

;;   (evil-define-key 'normal 'global (kbd "gcc")
;;                    (lambda ()
;;                      (interactive)
;;                      (if (not (use-region-p))
;;                          (comment-or-uncomment-region (line-beginning-position) (line-end-position)))))

;;   (evil-define-key 'visual 'global (kbd "gc")
;;                    (lambda ()
;;                      (interactive)
;;                      (if (use-region-p)
;;                          (comment-or-uncomment-region (region-beginning) (region-end)))))

;;   (evil-mode 1))

;; (use-package evil-collection
;;   :defer t
;;   :ensure t
;;   :custom
;;   (evil-collection-want-find-usages-bindings t)
;;   :hook
;;   (evil-mode . evil-collection-init))

;; (use-package evil-matchit
;;   :ensure t
;;   :after evil-collection
;;   :config
;;   (global-evil-matchit-mode 1))

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

;; (use-package volatile-highlights :ensure t :config (volatile-highlights-mode t))

