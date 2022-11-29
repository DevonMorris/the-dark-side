;; Remove startup message
(setq inhibit-startup-message t)

;; Minimalist UI
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

;; Font
(set-face-attribute 'default nil :font "Fira Code Nerd Font" :height 160)

;; Line Numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)
(column-number-mode)

;; Save History
(use-package savehist
  :init
  (savehist-mode))

(setq read-extended-command-predicate
  #'command-completion-default-include-p)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook
		shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Keyboard Escape Quit
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Basic Package Setup
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Finding configuration
(use-package vertico
  :bind (:map vertico-map
         ("C-n" . vertico-next)
         ("C-p" . vertico-previous)
         ("C-l" . vertico-exit))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-M-l" . consult-imenu)
         ("C-M-j" . persp-switch-to-buffer*)
         :map minibuffer-local-map
         ("C-r" . consult-history)))
(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))
(use-package marginalia
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))
(use-package savehist
  :init
  (savehist-mode))
(use-package embark
  :bind
  (("M-." . embark-act))         ;; pick some comfortable binding
  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Help Configuration
(use-package helpful
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))

;; Mode Line Configuration
(use-package all-the-icons)
(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Themes
(use-package doom-themes
 :init (load-theme 'doom-gruvbox t))

;; Make lisp like languages easier to read
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 2.0))

;; Keybindings and EVIL
(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer devo/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(devo/leader-keys
  "t" '(:ignore t :which-key "toggles")
  "tt" '(load-theme :which-key "choose theme"))

(devo/leader-keys
  "b" '(switch-to-buffer :which-key "buffers"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-C-i-jump t)
  (setq evil-want-Y-yank-to-eol t)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "C-j") 'evil-switch-to-windows-last-buffer))

;; Highlight on evil-yank (vim)
(use-package pulse)
(defun devo/evil-yank-advice (orig-fn beg end &rest args)
  (pulse-momentary-highlight-region beg end)
  (apply orig-fn beg end args))
(advice-add 'evil-yank :around 'devo/evil-yank-advice)
