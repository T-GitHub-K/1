package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

// デフォルト設定値（INIファイルがない、または項目がない場合に適用）
var (
	source     = "C:\\DATA"
	backup     = "C:\\BACKUP"
	days       = 30
	recursive  = true
	keepFolder = true
	dryRun     = true
	enableLog  = true
	logFile    = "backup_history.log"
)

const iniFileName = "config.ini"

// INIファイルを読み込んで設定を上書きする関数
func loadConfig() {
	file, err := os.Open(iniFileName)
	if err != nil {
		// ファイルがない場合はデフォルト値のまま進行
		fmt.Printf("設定ファイル (%s) が見つからないため、デフォルト値で実行します。\n", iniFileName)
		return
	}
	defer file.Close()

	fmt.Printf("設定ファイル (%s) を読み込みました。\n", iniFileName)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		// 空行やコメント行（;, #）はスキップ
		if line == "" || strings.HasPrefix(line, ";") || strings.HasPrefix(line, "#") || strings.HasPrefix(line, "[") {
			continue
		}

		// key=value の分割
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}

		key := strings.TrimSpace(parts[0])
		val := strings.TrimSpace(parts[1])

		// 各設定項目のマッピング（文字列のクォーテーションを除去）
		val = strings.Trim(val, `"'`)

		switch key {
		case "source":
			source = val
		case "backup":
			backup = val
		case "days":
			if i, err := strconv.Atoi(val); err == nil {
				days = i
			}
		case "recursive":
			if b, err := strconv.ParseBool(val); err == nil {
				recursive = b
			}
		case "keepFolder":
			if b, err := strconv.ParseBool(val); err == nil {
				keepFolder = b
			}
		case "dryRun":
			if b, err := strconv.ParseBool(val); err == nil {
				dryRun = b
			}
		case "enableLog":
			if b, err := strconv.ParseBool(val); err == nil {
				enableLog = b
			}
		case "logFile":
			logFile = val
		}
	}
	// ★ ここに追加：スキャン中のエラーをチェック
	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "設定ファイルの読み込み中にエラーが発生しました: %v\n", err)
	}
}

func main() {
	// 設定の読み込み
	loadConfig()

	// 出力先（標準出力 or 標準出力+ファイル）を制御するWriter
	var output io.Writer = os.Stdout

	if enableLog {
		f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if err != nil {
			fmt.Fprintf(os.Stderr, "ログファイルの開く処理に失敗しました: %v\n", err)
			return
		}
		defer f.Close()
		output = io.MultiWriter(os.Stdout, f)
	}

	limit := time.Now().AddDate(0, 0, -days)

	fmt.Fprintf(output, "[%s] バックアップ処理を開始します。制限日付: %s\n", time.Now().Format("2006-01-02 15:04:05"), limit.Format("2006-01-02"))

	filepath.Walk(source, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		if info.IsDir() {
			if path != source && !recursive {
				return filepath.SkipDir
			}
			return nil
		}
		if info.ModTime().Before(limit) {
			rel, _ := filepath.Rel(source, path)
			dst := filepath.Join(backup, rel)
			if !keepFolder {
				dst = filepath.Join(backup, filepath.Base(path))
			}

			fmt.Fprintln(output, "MOVE", path, "->", dst)

			if dryRun {
				return nil
			}
			os.MkdirAll(filepath.Dir(dst), 0755)
			if err := os.Rename(path, dst); err != nil {
				if err := copyFile(path, dst); err == nil {
					_ = os.Remove(path)
				} else {
					fmt.Fprintf(output, "ERROR: ファイルの移動に失敗しました (%s): %v\n", path, err)
				}
			}
		}
		return nil
	})

	fmt.Fprintf(output, "[%s] バックアップ処理が完了しました。\n", time.Now().Format("2006-01-02 15:04:05"))
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, in)
	return err
}
