;;;;;;;;;;;;
;;; 全般 ;;;
;;;;;;;;;;;;

;; 実行権限の自動付与
;; ファイルが #! から始まる場合、+X を付けて保存する
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;;; ヘルプを綺麗に表示する
; packageでインストール
(require 'pos-tip)
(defun my-describe-function (function)
   "Display the full documentation of FUNCTION (a symbol) in tooltip."
   (interactive (list (function-called-at-point)))
   (if (null function)
       (pos-tip-show
        "** You didn't specify a function! **" '("red"))
     (pos-tip-show
      (with-temp-buffer
        (let ((standard-output (current-buffer))
              (help-xref-following t))
          (prin1 function)
          (princ " is ")
          (describe-function-1 function)
          (buffer-string)))
      nil nil nil 0)))
 (define-key emacs-lisp-mode-map (kbd "C-;") 'my-describe-function)





;;;;;;;;;;;;;;;
;;; flymake ;;;
;;;;;;;;;;;;;;;

;; flymakeのハイライトをunderlineに変更
;; ハイライトだとCUIで文字が見えないので、、
(unless window-system
  (custom-set-faces
 '(flymake-errline ((((class color)) (:underline "red"))))
 '(flymake-warnline ((((class color)) (:underline "yellow"))))))





;;;;;;;;;;;;;;;;;;
;;; emacs-lisp ;;;
;;;;;;;;;;;;;;;;;;

;; emacs-lisp-modeのフック
(defun elisp-mode-hooks ()
  "lisp-mode-hooks"
  (when (require 'eldoc nil t)
    (setq eldoc-idle-delay 0.2)
    (setq eldoc-echo-area-use-multiline-p t)
    (turn-on-eldoc-mode)))
(add-hook 'emacs-lisp-mode-hook 'elisp-mode-hooks)

;;; 式の評価結果を注釈するための設定
; packageでインストール
(require 'lispxmp)
;; emacs-lisp-modeでC-c C-dを押すと注釈される
(define-key emacs-lisp-mode-map (kbd "C-c C-d") 'lispxmp)
(add-to-list 'ac-modes 'emacs-lisp-mode)

;;; 括弧の対応を保持して編集する設定
; http://www.daregada.sakuraweb.com/paredit_tutorial_ja.html (日本語チュートリアル)
; packageでインストール
(require 'paredit)
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
(add-hook 'lisp-mode-hook 'enable-paredit-mode)
(add-hook 'ielm-mode-hook 'enable-paredit-mode)
(add-hook 'slime-repl-mode-hook 'enable-paredit-mode)
(add-hook 'inferior-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'scheme-mode-hook 'enable-paredit-mode)
(add-hook 'inferior-scheme-mode-hook 'enable-paredit-mode)
(global-set-key (kbd "C-c f") 'paredit-forward-slurp-sexp) ; 右のS式を飲み込む
(global-set-key (kbd "C-c b") 'paredit-forward-barf-sexp) ; S式を右に吐き出す
(global-set-key (kbd "C-c u") 'paredit-splice-sexp-killing-backward) ; カーソル前の要素と外側の()を消す
; カーソルの要素だけを残すのは"M-r"
; カーソル直後のS式の選択は"C-M-SPC"

;;; eldocの設定
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)
(add-hook 'scheme-mode-hook 'turn-on-eldoc-mode)
(setq eldoc-idle-delay 0.2)
(setq eldoc-minor-mode-string "")





;;;;;;;;;;;;;;;;;;;;;;
;;; scheme(gauche) ;;;
;;;;;;;;;;;;;;;;;;;;;;

;; C-c C-lでバッファを評価
;; 行末C-c C-e でS式を評価
;; M-x run-scheme REPLを起動
(setq quack-default-program "gosh")
(require 'quack)
(require 'scheme-complete)
;;(autoload 'scheme-smart-complete "scheme-complete" nil t)
;; auto-completeを使っているので不要
;; (eval-after-load 'scheme
;;   '(define-key scheme-mode-map "\e\t" 'scheme-smart-complete))
(add-hook 'scheme-mode-hook
  (lambda ()
    (make-local-variable 'eldoc-documentation-function)
    (setq eldoc-documentation-function 'scheme-get-current-symbol-info)
    (eldoc-mode)))
(setq lisp-indent-function 'scheme-smart-indent-function)
