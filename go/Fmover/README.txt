■動作
coonfig.iniで指定した内容でファイルを移動します。
Logファイルも出力

■実行環境
Fmover.EXE

■パラメータ
; バックアップ元のフォルダパス（バックスラッシュ \ は重ねずにそのまま記述できます）
source = C:\DATA
; バックアップ先のフォルダパス
backup = C:\BACKUP
; 何日以上前のファイルを移動対象にするか（日数）
days = 365
; サブフォルダ（子フォルダ）も再帰的に探すかどうか（true: 探す / false: 探さない）
recursive = true
; 移動先でも元のフォルダ構造を維持するか（true: 維持する / false: フォルダ構造を無視してbackup直下に移動）
keepFolder = true
; テストモード（true: 画面やログに移動対象を表示するだけで、実際の移動処理は行わない / false: 通常実行）
dryRun = false
; ログファイルへの出力機能（true: ログファイルに保存する / false: 画面表示のみ）
enableLog = true
; 出力するログファイルの名称（またはフルパス）
logFile = backup_history.log

■デフォルト
source     = "C:\\DATA"
backup     = "C:\\BACKUP"
days       = 365
recursive  = true
keepFolder = true
dryRun     = false
enableLog  = true
logFile    = "backup_history.log"

■変更履歴
Ver1.0.0.0　2026/07/07　Kawamura　初版
Ver1.0.0.1　2026/07/13　Kawamura　Log出力、Go Run 環境整備
