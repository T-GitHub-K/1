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

// デフォルト設定値
var (
	source     = "C:\\DATA"
	backup     = "C:\\BACKUP"
	days       = 365
	recursive  = true
	keepFolder = true
	dryRun     = false
	enableLog  = true
	logFile    = "backup_history.log"
)

const iniFileName = "config.ini"

func loadConfig(iniPath string) {
	file, err := os.Open(iniPath)
	if err != nil {
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	isFirstLine := true

	for scanner.Scan() {
		line := scanner.Text()
		if isFirstLine {
			line = strings.TrimPrefix(line, "\xef\xbb\xbf")
			isFirstLine = false
		}
		line = strings.TrimSpace(line)

		if line == "" || strings.HasPrefix(line, ";") || strings.HasPrefix(line, "#") {
			continue
		}
		if strings.HasPrefix(line, "[") || strings.HasSuffix(line, "]") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}

		key := strings.TrimSpace(parts[0])
		val := strings.TrimSpace(parts[1])
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

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "config.ini の読み込み中にエラーが発生しました: %v\n", err)
	}
}

func main() {
	exePath, err := os.Executable()
	if err != nil {
		return
	}
	exeDir := filepath.Dir(exePath)
	iniPath := filepath.Join(exeDir, iniFileName)

	// ★ 修正①: EXEの横に config.ini が無い場合（go run の時など）
	if _, err := os.Stat(iniPath); os.IsNotExist(err) {
		// カレントディレクトリ（今コマンドを開いているフォルダ）の config.ini を見に行く
		iniPath = iniFileName

		// かつ、go run の時は実行フォルダ(exeDir)自体もカレントディレクトリに補正する
		// これによりログファイルが作業フォルダ内に作成されるようになります
		exeDir, _ = os.Getwd()
	}

	loadConfig(iniPath)

	source = filepath.Clean(source)
	backup = filepath.Clean(backup)

	if !filepath.IsAbs(logFile) {
		logFile = filepath.Join(exeDir, logFile)
	}

	var output io.Writer = io.Discard

	if enableLog {
		f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if err != nil {
			return
		}
		defer func() {
			_ = f.Sync()
			f.Close()
		}()
		output = f
	}

	fmt.Fprintln(output, "==================================================")
	fmt.Fprintf(output, "[%s] バックアップ処理を開始します。\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Fprintln(output, "--------------------------------------------------")
	fmt.Fprintf(output, "ソースフォルダ: %s\n", source)
	fmt.Fprintf(output, "バックアップ先: %s\n", backup)
	fmt.Fprintf(output, "対象日数: %d 日以前\n", days)
	fmt.Fprintf(output, "ドライラン(テストモード): %v\n", dryRun)
	fmt.Fprintln(output, "----------------------------------")

	limit := time.Now().AddDate(0, 0, -days)

	_ = filepath.Walk(source, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Fprintf(output, "[WARNING] パスアクセスエラー (%s): %v\n", path, err)
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
					fmt.Fprintf(output, "ERROR: 移動失敗 (%s): %v\n", path, err)
				}
			}
		}
		return nil
	})

	fmt.Fprintln(output, "--------------------------------------------------")
	fmt.Fprintf(output, "[%s] バックアップ処理が完了しました。\n", time.Now().Format("2006-01-02 15:04:05"))
	// ★ 修正点: 警告の原因となっていた末尾の \n を削除し、次回の開始時との間に空行を作るため、別で改行を出力
	fmt.Fprintln(output, "==================================================")
	fmt.Fprintln(output)
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
