;; Description: hub's init.el
;; Author: hub <hub@ngc.is.ritsumei.ac.jp>
;; Created: 2017-08-18
; (prog1 "環境固有設定の読み込み(proxy設定などを含むため、必ず最初に実行する)"
;   (load "~/.emacs.d/private-conf.el" t))

(prog1 "Proxy設定"
  ; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
  (setq url-proxy-services
    '(("no_proxy" . "^\\(localhost\\|10.*\\)")
      ("http" . "localhost:3128")
      ("https" . "localhost:3128"))))

(prog1 "leaf"
  (prog1 "install leaf"
    (custom-set-variables
     '(package-archives
       '(("org"   . "https://orgmode.org/elpa/")
         ("melpa" . "https://melpa.org/packages/")
         ("gnu"   . "https://elpa.gnu.org/packages/"))))
    (package-initialize)

    (unless (package-installed-p 'leaf)
      (package-refresh-contents)
      (package-install 'leaf)))
  
    (leaf leaf-keywords
      :ensure t
      :init
      (leaf hydra
        :ensure t)
      (leaf el-get
        :ensure t)
      (leaf blackout
        :ensure t)
      (leaf smartrep
        :ensure t)
      (leaf bind-key
        :ensure t)
      (leaf-keywords-init))
    (leaf imenu-list
      :ensure t
      :bind
      ("M-i" . imenu-list-smart-toggle)
      :custom
      (imenu-list-focus-after-activation . t)
      :config
      (leaf leaf-tree
        :ensure t
        :mode))
    (leaf leaf-convert
      :ensure t))

(leaf *customizeの出力先設定
  :config
  (setq custom-file "~/.emacs.d/custom-config.el")
  (if (file-exists-p (expand-file-name "~/.emacs.d/custom-config.el"))
      (load (expand-file-name custom-file) t nil nil)))

(leaf *基本設定
  :config
  (leaf *日本語
    :config
    (set-language-environment "Japanese")
    (prefer-coding-system 'utf-8)
    (leaf mozc
      :ensure t
      :require t
      :setq
      (default-input-method . "japanese-mozc")))
  (leaf *バックアップファイル
    :config
    (setq make-backup-files nil)
    (setq delete-auto-save-files t))

  (leaf *タブ設定
    :config
    (setq-default tab-width 4)
    (setq-default indent-tabs-mode nil))

  (leaf font
    :config
    (leaf unicode-fonts
      :ensure t)
    (leaf all-the-icons
      :ensure t)
    (let* ((family "Cica")
           (fontspec (font-spec :family family :weight 'normal)))
      (set-face-attribute 'default nil :family family :height 120)
      (set-fontset-font nil 'ascii fontspec nil 'append)
      (set-fontset-font nil 'japanese-jisx0208 fontspec nil 'append))
    (add-to-list 'face-font-rescale-alist '(".*icons.*" . 0.9))
    (add-to-list 'face-font-rescale-alist '(".*FontAwesome.*" . 0.9))
    (leaf text-scale
      :hydra
      (hydra-zoom ()
                  "Zoom"
                  ("i" text-scale-increase "in")
                  ("o" text-scale-decrease "out")
                  ("r" (text-scale-set 0) "reset")
                  ("0" (text-scale-set 0) :bind nil :exit t))
      :bind ("<f2>" . hydra-zoom/body))))

(leaf *ユーティリティ
  :config
  (leaf *README表示
    :config
    (defun show-help()
      (interactive)
      (switch-to-buffer (find-file-read-only "~/.emacs.d/readme.org"))))

  (leaf *開いているファイルの再読込
    :config
    (defun revert-buffer-no-confirm (&optional force-reverting)
      (interactive "P")
      (if (or force-reverting (not (buffer-modified-p)))
          (revert-buffer :ignore-auto :noconfirm)
        (error "The buffer has been modified")))
    (bind-key "<f5>" 'revert-buffer-no-confirm))
  (leaf which-key
    :doc "キーバインドのプレフィックスを入力すると、そこから繋がるキーバインドが表示される"
    :ensure t
    :blackout t
    :setq
    (which-key-idle-delay . 1.0)
    (which-key-idle-secondary-delay . 0.5)
    :config
    (which-key-mode))
  (leaf ivy
    :ensure t
    :blackout t
    :custom
    ((ivy-re-builders-alist . '((t . ivy--regex-fuzzy)
                                (swiper . ivy--regex-plus)))
     (ivy-use-selectable-prompt . t))
    :setq
    (ivy-use-virtual-buffers . t)
    (enable-recursive-minibuffers . t)
    (ivy-truncate-lines . nil)
    (ivy-wrap . t)
    :init
    (leaf *ivy-requirements
      :config
      (leaf swiper
        :ensure t
        :setq
        (swiper-include-line-numer-in-search . t)
        :bind*
        ("C-s" . swiper))
      (leaf counsel
        :ensure t
        :blackout t
        :bind*
        ("M-x" . counsel-M-x)
        ("M-y" . counsel-yank-pop)
        ("C-M-z" . counsel-fzf)
        ("C-M-f" . counsel-ag)
        :config
        (counsel-mode 1)))
    :bind
    (:ivy-minibuffer-map
     ("<escape>" . minibuffer-keyboard-quit))
    :config
    (ivy-mode 1)
    (leaf avy-migemo
      :ensure t
      :hook (ive-mode-hook . avy-migemo-mode))
    (leaf ivy-rich
      :ensure t
      :hook
      (ivy-mode-hook . ivy-rich-mode)
      :config
      (ivy-rich-mode 1)))

  (leaf smex
    :ensure t
    :require t
    :blackout t
    :after ivy
    :setq
    (smex-history-length . 35)
    (smex-completion-method . 'ivy))

  (leaf recentf
    :ensure t
    :require t
    :after counsel
    :setq
    (recentf-save-file . "~/.emacs.d/.recentf")
    (recentf-max-saved-items . 200)
    (recentf-exclude '(".recentf"))
    (recentf-auto-cleanup . 'never)
    :bind*
    ("C-x C-r" . counsel-recentf)
    :config
    (run-with-idle-timer 30 t '(lambda () (with-suppressed-message (recentf-save-list))))
    (leaf recentf-ext :ensure t :require t))

  (leaf *Window間移動
    :smartrep*
    ("C-x"
     (("o" . other-window))))

  (leaf e2wm
    :ensure t
    :require t
    :defun
    start-e2wm stop-e2wm e2wm:stop-management
    :bind*
    ("M-+" . start-e2wm)
    ("M-_" . stop-e2wm)
    :config
    (leaf maxframe
      :ensure t)
    (defun start-e2wm()
      (interactive)
      (maximize-frame)
      (sleep-for 0.1)
      (e2wm:start-management))
    (defun stop-e2wm()
      (interactive)
      (e2wm:stop-management)
      (restore-frame)))

  (leaf open-junk-file
    :ensure t
    :require t
    :setq (open-junk-file-format . "~/Documents/org/junk/%Y/%m/%d.org")
    :bind*
    ("C-o j" . open-junk-file))

  (leaf expand-region
    :ensure t
    :bind*
    ("C-." . er/expand-region)
    ("C-," . er/contract-region))

  (leaf multiple-cursors
    :ensure t
    :smartrep*
    ("C-t"
     (("C-t" . mc/mark-next-like-this)
      ("n" . mc/mark-next-like-this)
      ("p" . mc/mark-next-like-this)
      ("*" . mc/mark-all-like-this))))

  (leaf undo-tree
    :ensure t
    :bind
    ("C-x u" . undo-tree-visualize)
    :config
    (global-undo-tree-mode t))

  ;; (leaf perspective
  ;;   :ensure t
  ;;   :after projectile
  ;;   :defvar
  ;;   (persp-switch-prefix persp-first-perspective persp-top-perspective persp-bottom-perspective)
  ;;   :setq
  ;;   (persp-state-default-file . "~/.emacs.d/persp-state-file")
  ;;   (persp-switch-prefix . "C-M-%d")
  ;;   (persp-first-perspective . "2")
  ;;   (persp-top-perspective . "0")
  ;;   (persp-bottom-perspective . "5")
  ;;   :config
  ;;   (persp-mode t)
  ;;   (defun persp-set-keybind ()
  ;;     (mapc (lambda (i)
  ;;             (persp-switch (int-to-string i))
  ;;             (global-set-key (kbd (persp-switch-prefix i))
  ;;                             `(lambda ()
  ;;                                (interactive)
  ;;                                (persp-switch ,(int-to-string i)))))
  ;;           (number-sequence (string-to-number persp-top-perspective)
  ;;                            (string-to-number persp-bottom-perspective))))
  ;;   (defun persp-my-setup ()
  ;;     (persp-set-keybind)
  ;;     (persp-switch persp-first-perspective)
  ;;     (persp-kill "main"))
  ;;   :bind*
  ;;   ("C-x b" . persp-ivy-switch-buffer)
  ;;   ("C-x C-M-b" . persp-bs-show)
  ;;   :hook
  ;;   (kill-emacs-hook . persp-state-save)
  ;;   (persp-state-after-load-hook . persp-my-setup)
  ;;   (after-init-hook . persp-my-setup))
  ;; (leaf persp-mode
  ;;   :ensure t
  ;;   :blackout
  ;;   :after projectile
  ;;   :setq
  ;;   (wg-morph-on . nil)
  ;;   (persp-autokill-buffer-on-remove . 'kill-weak)
  ;;   :custom
  ;;   (persp-keymap-prefix (kbd "C-x p"))
  ;;   (persp-nil-name "default")
  ;;   (persp-set-last-persp-for-new-frames nil)
  ;;   (persp-auto-resume-time 0)
  ;;   :hook
  ;;   (after-init . persp-mode)
  ;;   )
  
  (leaf *テンプレート
    :config
    (setq auto-insert-directory "~/.emacs.d/templates")
    (auto-insert-mode t))
  )

(leaf *appearance
  :config
  (leaf *スクロールを1行ずつ
    :setq-default
    (scroll-conservatively . 1)
    (scroll-margin . 3))
  
  (leaf all-the-icons
    :ensure t)

  (leaf doom-themes
    :ensure t
    :setq
    (doom-themes-enable-italic . t)
    (doom-themes-enable-bold . t)
    :config
    (load-theme 'doom-dark+ t)
    (doom-themes-neotree-config)
    (doom-themes-org-config))

  (leaf *モードライン
    :config
    (leaf spaceline
      :ensure t
      :require t
      :setq-default
      (mode-line-format '("%e" (:eval (spaceline-ml-main)))))
    (leaf spaceline-config
      :ensure spaceline
      :defvar
      powerline-default-separator
      ns-use-srgb-colorspace
      mode-icons-grayscale-transform
      :setq
      (powerline-default-separator . 'slant)
      (ns-use-srgb-colorspace . nil)
      (mode-icons-grayscale-transform . nil)
      :config
      (spaceline-emacs-theme )))
  
  (leaf *対応する括弧の強調表示
      :config
      (setq show-paren-style 'mixed)
      (show-paren-mode t))
  
  (leaf *行番号表示
      :config
      (if (version<= "26.0.50" emacs-version)
          (global-display-line-numbers-mode t)
        (global-linum-mode t)))
  (leaf highlight-indent-guides
    :ensure t
    :blackout t
    :hook
    ((prog-mode-hook yaml-mode-hook) . highlight-indent-guides-mode)
    :custom
    ((highlight-indent-guides-method . 'character)
     (highlight-indent-guides-auto-enabled . t)
     (highlight-indent-guides-responsive . t)
     (highlight-indent-guides-character . ?\|)))
  )

(leaf *プログラミング支援
  :config
  (leaf *コンパイル・実行
    :config
    (bind-key* "C-c c" 'compile)
    (leaf quickrun
      :ensure t
      :require t
      :bind*
      ("C-x x" . quickrun)))

  (leaf yafolding
    :ensure t
    :hook
    (prog-mode . yafolding-mode))

  (leaf *git
    :config
    (leaf magit
      :ensure t
      :require t
      :setq
      (vc-handled-backends . '())
      :setq-default
      (magit-auto-revert-mode . nil)
      :bind
      ("C-x g" . magit-status))

    (leaf git-gutter
      :ensure t
      :blackout t
      :config
      (global-git-gutter-mode t)
      (leaf git-gutter-fringe
	:ensure t
	:config
	(define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
	(define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
	(define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))))

  (leaf projectile
    :ensure t
    :setq
    (projectile-mode-line . '(:eval (format "PJ[%s]" (projectile-project-name))))
    :config
    (projectile-mode t))

  (leaf neotree
    :ensure t
    :after projectile
    :commands
    (neotree-show neotree-hide neotree-dir neotree-find)
    :custom
    (neo-theme 'nerd2)
    :setq-default
    (neo-keymap-style . 'concise)
    :setq
    (neo-smart-open . t)
    (neo-create-file-auto-open . t)
    (neo-theme (if (display-graphic-p) 'icons 'arrow))
    :bind*
    ("<f9>" . neotree-projectile-toggle)
    ("<f8>" . neotree-toggle)
    :bind
    (:neotree-mode-map
     ; ("RET" . neotree-enter-hide)
     ("a" . neotree-hidden-file-toggle)
     ("<left>" . neotree-select-up-node)
     ("<right>" . neotree-change-root))
    :init
    (defun neotree-text-scale ()
      "Text scale for neotree"
      (interactive)
      (text-scale-adjust 0)
      (text-scale-decrease 1)
      (message nil))
    (defun neotree-projectile-toggle ()
      (interactive)
      (let ((project-dir
             (ignore-errors
         ;;; Pick one: projectile or find-file-in-project
               (projectile-project-root)
               ))
            (file-name (buffer-file-name))
            (neo-smart-open t))
        (if (and (fboundp 'neo-global--window-exists-p)
                 (neo-global--window-exists-p))
            (neotree-hide)
          (progn
            (neotree-show)
            (if project-dir
                (neotree-dir project-dir))
            (if file-name
                (neotree-find file-name))))))
    :config
    (neotree-show))
  
  (leaf yasnippet
    :ensure t
    :require t
    :blackout t
    :setq
    (yas-snippet-dirs . '("~/.emacs.d/mysnippets"
                          "~/.emacs.d/yasnippet"))
    :custom
    (yas-alias-to-yas/prefix-p . nil)
    :bind
    (:yas-minor-mode-map
     ("C-x i e" . yas-expand)
     ("C-x i i" . yas-insert-snippet)
     ("C-x i n" . yas-new-snippet)
     ("C-x i v" . yas-visit-snippet-file)
     ("C-x i l" . yas-describe-tables))
    (:yas-keymap
     ("<tab>" . nil)
     ("C-<tab>" . nil))
    :config
    (yas-global-mode t)
    (leaf yasnippet-snippets
      :ensure t)
    (leaf ivy-yasnippet
      :ensure t
      :bind ("C-x y" . ivy-yasnippet)))

  (leaf company
    :ensure t
    :require t
    :blackout t
    :after yasnippet
    :defvar
    company-backends company-mode/enable-yas company-search-map
    :custom
    (company-transformers . '(company-sort-by-backend-importance))
    (company-idle-delay . 0.1)
    (company-echo-delay . 0.1)
    (company-selection-wrap-around . t)
    (completion-ignore-case . t)
    :bind*
    ("C-j" . company-complete)
    :bind
    (:company-active-map
     ("C-n" . company-select-next)
     ("C-p" . company-select-previous)
     ("C-s" . company-filter-candidates)
     ("C-f" . company-complete-selection)
     ("<tab>" . company-indent-or-complete-common))
    (:company-search-map
     ("C-n" . company-select-next)
     ("C-p" . company-select-previous))
    :init
    (defun company/backend-yasnippet (backend)
      (if (or (not company-mode/enable-yas)
              (and (listp backend)
                   (member 'company-yasnippet backend)))
          backend
        (append (if (consp backend)
                    backend
                  (list backend))
                '(:with company-yasnippet))))
    :setq
    (company-mode/enable-yas . t)
    :config
    (global-company-mode)
    (push 'company/backend-yasnipet company-backends)
    (push 'company-files company-backends)
    (leaf company-box
      :ensure t
      :require t
      :hook
      (company-mode . company-box-mode)))

  (leaf flycheck
    :ensure t
    :blackout t
    :custom
    (global-flycheck-mode . t))

  (leaf lsp-mode
    :ensure t
    :commands lsp
    :after company
    :defvar company-backends
    :custom
    (lsp-prefer-flymake . nil)
    (lsp-enable-snippet . t)
    (lsp-enable-indentation . nil)
    (lsp-docmuent-sync-method . 2) ;lsp-sync-incremental
    (lsp-inhibit-message . t)
    (create-lockfiles . nil)
    :init
    (setq lsp-keymap-prefix "C-l")
    :setq
    (lsp-prefer-capf . t)
    :hook
    ((c-mode c++-mode java-mode python-mode js-mode web-mode rust-mode) . lsp-prog-major-mode-enable)
    (lsp-mode . lsp-enable-which-key-integration)
    :config
    (leaf lsp-ui
      :ensure t
      :custom
      (lsp-ui-doc-enable . t)
      (lsp-ui-doc-header . t)
      (lsp-ui-doc-include-signature . t)
      (lsp-ui-doc-position . 'doc)
      (lsp-ui-doc-use-childframe . t)
      (lsp-ui-doc-max-width . 60)
      (lsp-ui-doc-max-height . 20)
      (lsp-ui-doc-use-webkit . t)
      (lsp-ui-flycheck-enable . t)
      (lsp-ui-sideline-enable . t)
      (lsp-ui-sideline-ignore-duplicate . t)
      (lsp-ui-sideline-show-symbol . t)ppp
      (lsp-ui-sideline-show-hover . t)
      (lsp-ui-sideline-show-diagnostics . t)
      (lsp-ui-sideline-show-code-actions . t)
      (lsp-ui-imenu-enable . nil)
      (lsp-ui-imenu-kind-position . 'top)
      (lsp-ui-peek-enable . t)
      (lsp-ui-peek-always-show . t)
      (lsp-ui-peek-peek-height . 30)
      (lsp-ui-peek-list-width . 30)
      (lsp-ui-peek-fontify . 'always)
      :bind
      ("C-l s" . lsp-ui-sideline-mode)
      ("C-l C-d" . lsp-ui-find-definition)
      ("C-l C-r" . lsp-ui-find-references)
      :hook
      (lsp-mode-hook . lsp-ui-mode))
    (leaf lsp-ivy
      :ensure t
      :after lsp-mode ivy-mode
      :commands lsp-ivy-workspace-symbol)))

(leaf *モード
  :config
  (leaf cc-mode
    :mode
    ("\\.c\\'" "\\.h\\'" . c-mode)
    ("\\.cpp\\'" "\\.cxx\\'" "\\.hpp\\'" "\\.hxx\\'" . c++-mode)
    :setq
    (c-default-style . "strustrup")
    (c-auto-newline . t)
    (electric-pair-mode . t)
    :config
    (define-auto-insert "\\.cpp$" "cpp-template.cpp")
    (leaf clang-format
      :config
      (defun set-hook-after-save-clang-format ()
        (add-hook 'after-save-hook 'clang-format-buffer t t)))
    (leaf ccls
      :ensure t
      :after lsp-mode
      :when
      (file-directory-p "/usr/local/bin/ccls")
      :custom
      (ccls-executable . "/usr/local/bin/ccls")
      (ccls-sem-highlight-method . 'font-lock)
      (ccls-use-default-rainbow-sem-highlight . t)
      :hook
      ((c-mode c++-mode objc-mode) . (lambda  () (require 'ccls) (lsp))))
    :hook
    (cc-mode . (lsp company-mode flycheck-mode hs-minor-mode))
    ((c-mode c++-mode) . (set-hook-after-save-clang-format)))

  (leaf rust-mode
    :ensure t
    :setq
    (rust-format-on-save . t)
    :config
    (add-to-list 'exec-path (expand-file-name "c:/Tools")) ; path to rust-analyzer
    (add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))
    (leaf cargo
      :ensure t
      :blackout t
      :config (cargo-minor-mode t)))

  (leaf go-mode
    :ensure t
    :mode
    ("\\.go\\'" . go-mode)
    :hook
    (go-mode . (lsp-go-install-save-hooks lsp company-mode flycheck-mode hs-minor-mode)))

  (leaf emacs-lisp-mode
    :setq
    (flycheck-disabled-checkers . '(emacs-lisp-checkdoc))
    :config
    (leaf flycheck-package
      :after flycheck
      :ensure t
      :require t
      :config
      (flycheck-package-setup))
    (leaf eldoc
      :ensure t
      :hook
      (emacs-lisp-mode . (ielm-mode)))
    (leaf elisp-slime-nav
      :ensure t
      :hook
      (emacs-lisp-mode . (elisp-slime-nav)))
    :hook
    (emacs-lisp-mode . (company-mode flycheck-mode hs-minor-mode)))

  (leaf vue-mode
    :ensure t
    :mode
    ("\\.vue\\'" "\\.js\\'")
    :config
    (leaf add-node-modules-path
      :ensure t)
    (flycheck-add-mode 'javascript-eslint 'vue-mode)
    (flycheck-add-mode 'javascript-eslint 'vue-html-mode)
    (flycheck-add-mode 'javascript-eslint 'css-mode)
    :hook
    (vue-mode . (add-node-module-path)))

  (leaf powershell
    :ensure t
    :mode
    ("\\.ps1\\'" "\\.psm1\\'" "\\.psd1\\'")
    :interpreter
    "c:/Program Files/PowerShell/7/pwsh.exe")

  (leaf java-mode
    :mode
    "\\.java\\'"
    :config
    (leaf lsp-java
      :ensure t
      :after lsp)
    :hook
    (java-mode . (lsp company-mode flycheck-mode)))

  (leaf fish-mode
    :ensure t
    :mode
    "\\.fish\\'")

  (leaf org
    :ensure t
    :require t
    :mode
    "\\.org\\'"
    :bind
    ("C-o" . nil)
    ("C-o c" . org-capture)
    ("C-o a" . org-agenda)
    ("C-o b" . org-iswitchb)
    ("C-o l" . org-store-link)
    :defun
    org-clock-into-stated
    :init
    (setq org-agenda-files '("~/Documents/org/todo/todo.org"
                             "~/Documents/org/todo/FBX.org"
                             "~/Documents/org/todo/ECHO.org"
                             "~/Documents/org/todo/recruit.org"
                             "~/Documents/org/todo/NCT.org"
                             "~/Documents/org/todo/OJT.org"))
    (setq org-agenda-directory '("~/Documents/org/todo"))
    :setq
    (org-directory . "~/Documents/org")
    (org-default-notes-file . "note.org")
    (org-todo-keywords . '((sequence "TODO(t)" "Doing(i)" "Waiting(w)" "|" "DONE(d)" "CANCEL(c)")))
    (org-clock-clocktable-default-properties . '(:maxlevel 4 :scope tree))
    (org-clock-in-switch-to-state 'org-clock-into-started)
    (org-log-done . 'time)
    (org-hide-leading-stars . t)
    (org-startup-indented . t)
    (org-startup-folded . 'content)
    (org-return-follows-link . t)
    (org-capture-templates . '(("n"
                                "note"
                                entry
                                (file+headline "~/Documents/org/note.org" "Note")
                                "* %U%?\n\n%a\n%F\n"
                                :empty-lines-after 1)
                               ("t"
                                "TODO"
                                entry
                                (file+headline "~/Documents/org/todo/todo.org" "InBox")
                                "** TODO %?\n%T \n")
                               ("f"
                                "FBX"
                                entry
                                (file+headline "~/Documents/org/todo/FBX.org" "Tasks")
                                "** TODO %?\n%T \n")
                               ("e"
                                "ECHO"
                                entry
                                (file+headline "~/Documents/org/todo/ECHO.org" "Tasks")
                                "** TODO %?\n%T \n")
                               ("R"
                                "Recruit"
                                entry
                                (file+headline "~/Documents/org/todo/recruit.org" "Tasks")
                                "** TODO %?\nT% \n")
                               ("N"
                                "NCT"
                                entry
                                (file+headline "~/Documents/org/todo/NCT.org" "Tasks")
                                "** TODO %?\n%T \n")
                               ("O"
                                "OJT"
                                entry
                                (file+headline "~/Documents/org/todo/OJT.org" "Tasks")
                                "** TODO %?\n%T \n")))
    (system-time-locale . "C")
    (org-agenda-start-with-log-mode . 1)
    (org-agenda-span . 1)
    :config
    (define-auto-insert "\\.org$" "org-template.org")
    (leaf ox-md)
    (leaf org-table-sticky-header
      :ensure t
      :hook
      (org-mode-hook . org-table-sticky-header-mode))
    (leaf org-re-reveal
      :ensure t))
  (prog1 'org-custom-functions
    (defun org-clock-into-started (state)
      (if (or (string= state "TODO")
              (string= state "Waiting"))
          "NEXT")))
      
  (leaf csv-mode
    :ensure t
    :mode
    "\\.csv\\'")

  (leaf markdown-mode
    :ensure t
    :mode
    "\\.markdown\\'"
    "\\.md\\'")

  (leaf yaml-mode
    :ensure t
    :mode
    "\\.yaml\\'")

  (leaf logview
    :ensure t
    :mode
    "\\.log\\'")

  (leaf dockerfile-mode
    :ensure t
    :mode
    "\\Dockerfile\\'"
    "\\dockerfile\\'")
  
  (leaf docker-compose-mode
    :ensure t
    :mode
    ("\\docker-compose.yaml'"))

  (leaf sql
    :ensure t
    :mode
    "\\.sql\\'"
    "\\.ddl\\'"
    :setq
    (sql-indent-offset . 4)
    (indent-tabs-mode . nil)
    :config
    (leaf sql-indent
      :ensure t
      :config
      (load-library "sql-indent"))
    (leaf sql-complete
      :ensure t
      :config
      (load-library "sql-complete"))
    (leaf sqltransform
      :ensure t
      :config
      (load-library "sqltrasform"))
    (sql-set-product "postgres"))

  (leaf plantuml-mode
    :ensure t
    :mode
    "\\.pu\\'"
    "\\.plantuml\\'"
    :setq
    (plantuml-default-exec-mode . 'jar)
    (plantuml-jar-path . "c:/Tools/plantuml/plantuml.jar")
    (plantuml-output-type . "png")
    :defun
    plauntuml-preview-frame
    :bind
    (:plantuml-mode-map
     ("C-c C-c" . plantuml-preview)))

  (leaf restclient
    :ensure t
    :mode
    "\\.http\\'"
    :setq
    (restclient-log-requeset . t)
    (restclient-same-buffer-response . t)
    :config
    (leaf company-restclient
      :ensure t
      :require t
      :after company)))

(leaf *Webブラウザ
  :config
  (leaf eww
    :ensure t
    :bind
    ("C-c w" . eww-search)
    ("C-c u" . browse-url-with-eww)
    (:eww-mode-map
     ("r" . eww-reload)
     ("w" . eww-copy-page-url)
     ("p" . scroll-down)
     ("n" . scroll-up))
    :defvar
    eww-disable-colorize
    :setq
    (eww-search-prefix . "http://www.google.co.jp/search?q=")
    (eww-disable-colorize . t)
    :preface
    (defun shr-colorize-region--disable (orig start end fg &optional bg &rest _)
      (unless eww-disable-colorize
        (funcall orig start end fg)))
    (leaf *文字色反映の切り替え
      :config
      (defun eww-disable-color ()
        (interactive)
        (setq-local eww-disable-colorize t)
        (eww-reload))
      (defun eww-enable-color ()
        (interactive)
        (setq-local eww-disable-colorize nil)
        (eww-reload)))
    (leaf *複数バッファで起動するときにバッファ名を変更する
      :config
      (defun eww-mode-hook--rename-buffer ()
        (rename-buffer "eww" t)))
    (leaf *検索結果をハイライトする
      :config
      (defun eww-search (term)
        (interactive "sSearch Terms: ")
        (setq eww-hl-search-word term)
        (eww-browse-url (concat (eww-search-prefix term)))))
    (leaf *カーソルがある位置のURL文字列をewwで開く
      :config
      (defun browse-url-with-eww ()
        (interactive)
        (let ((url-region (bounds-of-thing-at-point 'url)))
          (if url-region
              (eww-browse-url (buffer-substring-no-properties (car url-region)
                                                              (cdr url-region)))
            (setq browse-url-browser0function 'eww-browse-url)
            (org-open-at-point)))))
    (leaf *画像の表示/非表示切り替え
      :config
      (defun shr-put-image-alt (spec alt &optional flags)
        (insert alt))
      (defun eww-disable-images ()
        (interactive)
        (setq-local shr-put-image-function 'shr-put-image-alt)
        (eww-reload))
      (defun eww-enable-images ()
        (interactive)
        (setq-local shr-put-image-function 'shr-put-image)
        (eww-reload))
      (defun eww-mode-hook--disable-image ()
        (setq-local shr-put-image-function 'shr-put-image-alt)))

    :hook
    (eww-mode-hook . (eww-mode-hook--disable-image
                      eww-mode-hook--rename-buffer))
    :advice
    (:around shr-colorize-region shr-colorize-region--disable)
    (:around eww-colorize-region shr-colorize-region--disable)
    :config
    (leaf ace-link
      :ensure t
      :bind
      (:eww-mode-map
       ("f" . ace-link-eww))
      :config
      (ace-link-setup-default))))


(leaf *外部設定ファイルの読み込み
  :config
  (setq external-conf-directory "~/.emacs.d/conf")
  (leaf init-loader
    :ensure t
    :when
    (file-directory-p external-conf-directory)
    :defvar
    init-loader-show-log-after-init
    :setq
    (init-loader-show-log-after-init . 'error-only)
    :config
    (init-loader-load external-conf-directory))
  )

(leaf dashboard
  :ensure t
  :bind
  ("<f10>" . open-dashboard)
  (:dashboard-mode-map
   ("<f10>" . quit-dashboard))
  :hook
  (after-init . dashboard-setup-startup-hook)
  :setq
  (dashboard-center-content . t)
  (dashboard-set-heading-icons . t)
  (dashboard-set-file-icons . t)
  (dashboard-items . '((recents . 10)
                       (projects . 10)
                       (agenda . 10)))
  (dashboard-week-agenda . nil)
  :config
  (dashboard-setup-startup-hook)
  (defun open-dashboard ()
    (interactive)
    (delete-other-windows)
    (if (get-buffer dashboard-buffer-name)
        (kill-buffer dashboard-buffer-name))
    (dashboard-insert-startupify-lists)
    (switch-to-buffer dashboard-buffer-name)
    (goto-char (point-min))
    (dashboard-goto-recent-files))
  (defun quit-dashboard ()
    (interactive)
    (quit-window t)
    (when (and dashboard-recover-layout-p
               (bound-and-true-p winner-mode))
      (winner-undo)
      (setq dashboard-recover-layout-p nil)))
  (defun dashboard-goto-recent-files ()
    (interactive)
    (funcall (local-key-binding "r")))
    )

 (prog1 "起動高速化測定用 必要に応じて有効化"
;    (profiler-report)
    (profiler-stop))

;;; init.el ends here

