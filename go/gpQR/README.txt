■動作
パラメータで指定した内容をQRコード化してpng形式の画像データを生成します。

■実行環境
gpQR.EXE

■パラメータ
--qrtxt 必須
-o / --output 出力先指定 出力ファイル名（省略時 gpQR.png）
--size-mm QRサイズ指定（mm）(省略時 40mm)
--auto-size 文字量から自動サイズ決定
--ftext QR下部文字（日本語対応）
日本語フォント自動選択（Windows優先）
QR誤り訂正 L
300dpi保存
余白付き

■コマンドライン例
c:\gpQR.exe
--qrtxt "なんでもかんでもQRコード化" 
-o c:\scanqr\test.png
--auto-size
--ftext "日常 A-10001"

■その他
gpQR.go       メインのソースコード

■変更履歴
Ver1.0.0.0　2026/06/28　Kawamura　初版