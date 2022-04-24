(prog1 "起動時デバッグ・調査"
  (setq debug-on-error t)
  (require 'profiler)
  (profiler-start 'cpu))

(prog1 "起動高速化"
  (prog1 "Magic File Nameを一時的に無効化"
    (defconst my:saved-file-name-handler-alist file-name-handler-alist)
    (setq file-name-handler-alist nil)
    (add-hook 'emacs-startup-hook
              (lambda ()
                (setq file-name-handler-alist my:saved-file-name-handler-alist))))
  (prog1 "起動時のGCを無効化"
    (defconst my:default-gc-cons-threshold gc-cons-threshold)
    (setq gc-cons-threshold most-positive-fixnum)
    (add-hook 'emacs-startup-hook
              (lambda ()
                (setq gc-cons-threshold my:default-gc-cons-threshold)))))


(prog1 "GUI設定"
  (push '(menu-bar-lines . 0) default-frame-alist)
  (push '(tool-bar-lines . 0) default-frame-alist)
  (push '(fullscreen . maximized) default-frame-alist)
  (setq inhibit-splash-screen t
        frame-inhibit-implied-resize t
        ring-bell-function 'ignore
        use-dialog-box nil)
  (set-face-attribute 'default nil :font "Cica-12"))



(provide 'early-init)

;;; early-init.el ends here
