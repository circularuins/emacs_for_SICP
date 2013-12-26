;;;;;;;;;;;;;;;;;;;;
;;; カーソル関連 ;;;
;;;;;;;;;;;;;;;;;;;;

;;; #削除系コマンド ;;;

;; C-hで直前の文字を消去
;(global-set-key (kbd "C-h") 'delete-backward-char)
(keyboard-translate ?\C-h ?\C-?)

;; C-x C-hでhelp
(global-set-key (kbd "C-x C-h") 'help)

;; C-k(kill-line)で行末の改行までkill
(setq kill-whole-line 1)

;; カーソル位置から行頭まで削除する
(defun backward-kill-line (arg)
  "Kill chars backward until encountering the end of a line."
  (interactive "p")
  (kill-line 0))
;; C-M-kに設定
(global-set-key (kbd "C-M-k") 'backward-kill-line)

;; 範囲指定していないとき、C-wで前の単語を削除
(defadvice kill-region (around kill-word-or-kill-region activate)
  (if (and (interactive-p) transient-mark-mode (not mark-active))
      (backward-kill-word 1)
    ad-do-it))
;; minibuffer用
(define-key minibuffer-local-completion-map "\C-w" 'backward-kill-word)

;; カーソル位置の単語を削除
(defun kill-word-at-point ()
  (interactive)
  (let ((char (char-to-string (char-after (point)))))
    (cond
     ((string= " " char) (delete-horizontal-space))
     ((string-match "[\t\n -@\[-`{-~]" char) (kill-word 1))
     (t (forward-char) (backward-word) (kill-word 1)))))
(global-set-key "\M-d" 'kill-word-at-point)

;;; #移動系コマンド ;;;

;; ウィンドウ内のカーソル移動
(global-set-key (kbd "C-M-h") (lambda () (interactive) (move-to-window-line 0))) ; 画面上に移動
(global-set-key (kbd "C-M-m") (lambda () (interactive) (move-to-window-line nil))) ; 画面中に移動
(global-set-key (kbd "C-M-l") (lambda () (interactive) (move-to-window-line -1))) ; 画面下に移動

;; 最後の変更箇所にジャンプする
; M-x install-elisp-from-emacswiki goto-chg.el
(require 'goto-chg)
(define-key global-map (kbd "<f8>") 'goto-last-change)
(define-key global-map (kbd "S-<f8>") 'goto-last-change-reverse)

;; カーソル位置を戻す
(require 'point-undo)
; M-x install-elisp-from-emacswiki point-undo.el
(define-key global-map (kbd "<f7>") 'point-undo)
(define-key global-map (kbd "S-<f7>") 'point-redo)

;;; #表示 ;;;

;; 相対的なカーソル位置を保ったまま画面スクロール
(setq scroll-preserve-screen-position t)





;;;;;;;;;;;;;;;;;;;;
;;; 編集系の設定 ;;;
;;;;;;;;;;;;;;;;;;;;

;;; 矩形編集 ;;;

;; cua-mode
;; C-RETで開始、C-gで終了
;; #連番入力の手順
;; 矩形選択後、M-oでスペース1文字挿入
;; M-n 後、初期値、加算値、フォーマットの順に入力
(cua-mode t)
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効に
; ターミナルでデフォルトの"C-RET"が使えないので変更する
(define-key global-map (kbd "C-x C-x") 'cua-set-rectangle-mark)





;;;;;;;;;;;;;;;;;;;;
;;; ファイル操作 ;;;
;;;;;;;;;;;;;;;;;;;;

;; バックアップファイルを作らない
(setq make-backup-files nil)

;; オートセーブファイルを作らない
(setq auto-save-default nil)

;; 最近開いたファイルを保存する数を増やす
(setq recentf-max-saved-items 10000)

;; 最近使ったファイルを開く
; M-x install-elisp-from-emacswiki recentf-ext.el
(setq recentf-exclude '("/TAGS$" "/var/tmp/" "Map_Sym.txt")) ; リストからの除外対象
(require 'recentf-ext)
(define-key global-map (kbd "C-x C-m") 'recentf-open-files)

;; diredを便利にする
(require 'dired-x)

;; diredから"r"でファイル名をインライン編集する
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;; wdiredで、ファイルのパーミションを編集可能にする
;; "C-x d"でwdired、"C-x C-q"で編集モード
(setq wdired-allow-to-change-permissions t)

;; ファイル名が重複していたらディレクトリ名を追加する。
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; 現在カーソル位置のファイル・URLを開く
(ffap-bindings)

;;; direx ;;;
;; C-u C-x C-j で、通常のdiredを実行
(defun my/dired-jump ()
  (interactive)
  (cond (current-prefix-arg
         (dired-jump))
        ((not (one-window-p))
         (or (ignore-errors
               (direx-project:jump-to-project-root) t)
             (direx:jump-to-directory)))
        (t
         (or (ignore-errors
               (direx-project:jump-to-project-root-other-window) t)
             (direx:jump-to-directory-other-window)))))

(global-set-key (kbd "C-x C-j") 'my/dired-jump)

;; widthは環境に合わせて調整してください。
(push '(direx:direx-mode :position left :width 40 :dedicated t)
      popwin:special-display-config)





;;;;;;;;;;;;;;;;
;;; 履歴操作 ;;;
;;;;;;;;;;;;;;;;

;;; #undo,redo ;;;

;; undoの分岐を視覚化(C-x u)
;; "p","n"で履歴を移動、"f","b"でブランチの切り替え、"q"で終了
; packageでインストール
(require 'undo-tree)
(global-undo-tree-mode t)
(global-set-key (kbd "M-/") 'undo-tree-redo)

;;; #履歴の保存 ;;;

;; 履歴を次回emacs起動畤にも保存する
(savehist-mode 1)

;; 履歴数を大きくする
(setq history-length t)

;; kill-ringやミニバッファで過去に開いたファイルなどの履歴を保存する
; install-elisp-from-emacswiki session.el
(when (require 'session nil t)
  (setq session-initialize '(de-saveplace session keys menus places)
        session-globals-include '((kill-ring 50)
                                  (session-file-alist 500 t)
                                  (file-name-history 10000)))
  (add-hook 'after-init-hook 'session-initialize)
  (setq session-undo-check -1)) ; 前回閉じたときの位置にカーソルを復帰





;;;;;;;;;;;;;;;;
;;; メモ管理 ;;;
;;;;;;;;;;;;;;;;

;; 試行錯誤用ファイル
; M-x install-elisp-from-emacswiki open-junk-file.el
(require 'open-junk-file)
(setq open-junk-file-format "~/junk/%Y-%m-%d-%H%M%S.")
(global-set-key (kbd "C-x C-z") 'open-junk-file)
