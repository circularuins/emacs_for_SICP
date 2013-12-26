;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; anything関連の設定 ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

; packageでインストール
;; 基本設定
(require 'anything)
;(require 'anything-startup)
; 動作チューニング
(setq
 ; 候補を表示するまでの時間。初期値は0.5
 anything-idle-delay 0.3
 ; タイプして再描写するまでの時間。初期値は0.1
 anything-input-idle-delay 0.2
 ; 候補の最大表示数。初期値は50
 anything-candidate-number-limit 100
 ; 候補が多い時に体感速度を速くする
 anything-quick-update t)
(require 'anything-config)
; root権限でアクションを実行するときのコマンド
; デフォルトは"su"
(setq anything-su-or-sudo "sudo")
; M-xでanything起動
(define-key global-map (kbd "M-x")
  (lambda ()
    (interactive)
    (anything-other-buffer
     '(anything-c-source-extended-command-history anything-c-source-emacs-commands)
     "*anything emacs commands*")))
; 履歴にデフォルト表示させるコマンド
(setq extended-command-history
     '( "anything-for-files" "eval-region" "eval-buffer"))
(require 'anything-match-plugin nil t)
(require 'anything-complete)
; Lispシンボルの補完候補の再検索時間
(anything-lisp-complete-symbol-set-timer 150)
(require 'anything-show-completion nil t)
(require 'anything-auto-install nil t)

;; describe-bindingsをAnythingに置き換える
(when (require 'descbinds-anything nil t)
  (descbinds-anything-install))

;; M-yにanything-show-kill-ringを割り当てる
(define-key global-map (kbd "M-y") 'anything-show-kill-ring)
