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
--level L (L,M,Q,H) デフォルトL
--textfile <ファイル名> に対応
  --textfile 指定時は --qrtxt より優先
    UTF-8 BOM を自動除去
    Windows (CRLF) と Linux (LF) の改行を統一

■コマンドライン例
c:\gpQR.exe
--qrtxt "なんでもかんでもQRコード化" 
-o c:\scanqr\test.png
--auto-size
--ftext "日常 A-10001"
--level L
--textfile <ファイル名>

■その他
gpQR.go       メインのソースコード

■変更履歴
Ver1.0.0.0　2026/06/28　Kawamura　初版