package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/skip2/go-qrcode"
	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"
	"golang.org/x/text/encoding/japanese"
)

// Shift_JISかUTF-8かを簡易判定し、UTF-8の文字列として返す
func convertToUTF8(b []byte) (string, error) {
	if isUTF8(b) {
		return string(b), nil
	}

	decoder := japanese.ShiftJIS.NewDecoder()
	utf8Bytes, err := decoder.Bytes(b)
	if err != nil {
		return "", fmt.Errorf("文字コードの変換に失敗しました（対応：UTF-8 / Shift_JIS）: %w", err)
	}
	return string(utf8Bytes), nil
}

// 簡易的なUTF-8チェック
func isUTF8(b []byte) bool {
	i := 0
	for i < len(b) {
		if b[i] < 0x80 {
			i++
			continue
		} else if b[i] >= 0xc2 && b[i] <= 0xdf {
			if i+1 >= len(b) || b[i+1] < 0x80 || b[i+1] > 0xbf {
				return false
			}
			i += 2
			continue
		} else if b[i] >= 0xe0 && b[i] <= 0xef {
			if i+2 >= len(b) || b[i+1] < 0x80 || b[i+1] > 0xbf || b[i+2] < 0x80 || b[i+2] > 0xbf {
				return false
			}
			i += 3
			continue
		} else if b[i] >= 0xf0 && b[i] <= 0xf4 {
			if i+3 >= len(b) || b[i+1] < 0x80 || b[i+1] > 0xbf || b[i+2] < 0x80 || b[i+2] > 0xbf || b[i+3] < 0x80 || b[i+3] > 0xbf {
				return false
			}
			i += 4
			continue
		}
		return false
	}
	return true
}

func calcAutoSizeMM(text string) float64 {
	length := len([]byte(text))

	switch {
	case length < 100:
		return 30
	case length < 180:
		return 35
	case length < 260:
		return 40
	case length < 350:
		return 45
	default:
		return 50
	}
}

func loadFont(size float64, dpi float64) (font.Face, error) {
	candidates := []string{
		`C:\Windows\Fonts\meiryo.ttc`,
		`C:\Windows\Fonts\msgothic.ttc`,
		`C:\Windows\Fonts\YuGothM.ttc`,
		`C:\Windows\Fonts\YuGothR.ttc`,
	}

	for _, p := range candidates {
		if _, err := os.Stat(p); err == nil {
			b, err := os.ReadFile(p)
			if err != nil {
				continue
			}

			ft, err := opentype.ParseCollection(b)
			if err != nil {
				continue
			}

			f, err := ft.Font(0)
			if err != nil {
				continue
			}

			return opentype.NewFace(
				f,
				&opentype.FaceOptions{
					Size: size,
					DPI:  dpi,
				},
			)
		}
	}

	return nil, fmt.Errorf("font not found")
}

// 引数に qrcode.RecoveryLevel を追加
func createQR(text, output string, sizeMM float64, footer string, dpi int, margin int, level qrcode.RecoveryLevel) error {
	pixel := int(sizeMM / 25.4 * float64(dpi))

	// 🛠 動的に受け取った誤り訂正レベル（level）でQRコードを生成
	qr, err := qrcode.New(text, level)
	if err != nil {
		if strings.Contains(err.Error(), "too long") || strings.Contains(err.Error(), "cannot encode") {
			return fmt.Errorf("QRコードの容量オーバーです。文字数を減らすか、誤り訂正レベル(L/M/Q/H)を下げてください。(詳細: %w)", err)
		}
		return err
	}

	qr.DisableBorder = true
	qrImg := qr.Image(pixel)

	// フッター文字がない場合
	if footer == "" {
		paddedWidth := pixel + (margin * 2)
		paddedHeight := pixel + (margin * 2)

		canvas := image.NewRGBA(image.Rect(0, 0, paddedWidth, paddedHeight))
		draw.Draw(canvas, canvas.Bounds(), &image.Uniform{color.White}, image.Point{}, draw.Src)
		draw.Draw(canvas, image.Rect(margin, margin, margin+pixel, margin+pixel), qrImg, image.Point{}, draw.Src)

		f, err := os.Create(output)
		if err != nil {
			return err
		}
		defer f.Close()

		return png.Encode(f, canvas)
	}

	// フッターがある場合
	fontSize := float64(pixel / 14)
	if fontSize < 14 {
		fontSize = 14
	}

	face, err := loadFont(fontSize, float64(dpi))
	if err != nil {
		return err
	}

	metrics := face.Metrics()
	textHeight := (metrics.Ascent + metrics.Descent).Round()

	paddedWidth := pixel + (margin * 2)
	paddedHeight := pixel + (margin * 2) + textHeight + 20

	canvas := image.NewRGBA(image.Rect(0, 0, paddedWidth, paddedHeight))
	draw.Draw(canvas, canvas.Bounds(), &image.Uniform{color.White}, image.Point{}, draw.Src)

	draw.Draw(
		canvas,
		image.Rect(margin, margin, margin+pixel, margin+pixel),
		qrImg,
		image.Point{},
		draw.Src,
	)

	d := &font.Drawer{
		Dst:  canvas,
		Src:  image.NewUniform(color.Black),
		Face: face,
	}

	width := d.MeasureString(footer).Round()

	x := (paddedWidth - width) / 2
	y := margin + pixel + 20 + metrics.Ascent.Round()

	d.Dot = fixed.P(x, y)
	d.DrawString(footer)

	file, err := os.Create(output)
	if err != nil {
		return err
	}
	defer file.Close()

	return png.Encode(file, canvas)
}

func main() {
	qrtxt := flag.String("qrtxt", "", "text for QR")
	textfile := flag.String("textfile", "", "text file path for QR")
	output := flag.String("o", "gpQR.png", "output path or directory")
	sizeMM := flag.Float64("size-mm", 0, "size in mm")
	auto := flag.Bool("auto-size", false, "auto size based on text length")
	ftext := flag.String("ftext", "", "footer text")
	dpi := flag.Int("dpi", 300, "DPI (e.g., 300, 600)")
	margin := flag.Int("margin", 40, "margin size in pixels")

	// 🛠 誤り訂正レベル指定オプションの追加（デフォルトは元のソース基準で L ）
	levelStr := flag.String("level", "M", "QR recovery level (L/M/Q/H)")

	flag.Parse()

	// 🛠 誤り訂正レベルのパースロジックを復元
	var level qrcode.RecoveryLevel
	switch strings.ToUpper(*levelStr) {
	case "L":
		level = qrcode.Low
	case "M":
		level = qrcode.Medium
	case "Q":
		level = qrcode.High // go-qrcodeではHigh (約25%復元)
	case "H":
		level = qrcode.Highest // go-qrcodeではHighest (約30%復元)
	default:
		fmt.Println("--level は L/M/Q/H を指定してください")
		os.Exit(1)
	}

	var text string

	if *textfile != "" {
		b, err := os.ReadFile(*textfile)
		if err != nil {
			fmt.Printf("ファイルの読み込みに失敗しました: %v\n", err)
			os.Exit(1)
		}
		text, err = convertToUTF8(b)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	} else if *qrtxt != "" {
		text = *qrtxt
	} else {
		fmt.Println("--qrtxt または --textfile は必須です")
		os.Exit(1)
	}

	out := filepath.Clean(*output)
	if info, err := os.Stat(out); err == nil && info.IsDir() {
		filename := fmt.Sprintf("qr_%s.png", time.Now().Format("20060102_150405"))
		out = filepath.Join(out, filename)
	} else if os.IsNotExist(err) && (strings.HasSuffix(out, string(filepath.Separator)) || !strings.Contains(filepath.Base(out), ".")) {
		if err := os.MkdirAll(out, 0755); err == nil {
			filename := fmt.Sprintf("qr_%s.png", time.Now().Format("20060102_150405"))
			out = filepath.Join(out, filename)
		}
	}

	size := 40.0
	if *sizeMM > 0 {
		size = *sizeMM
	} else if *auto {
		size = calcAutoSizeMM(text)
	}

	// 🛠 引数の最後に level を追加して実行
	if err := createQR(text, out, size, *ftext, *dpi, *margin, level); err != nil {
		fmt.Printf("\n【エラー】QRコードの生成に失敗しました:\n%v\n", err)
		os.Exit(1)
	}

	fmt.Println()
	fmt.Println("保存完了 :", out)
	fmt.Printf("QRサイズ : %.1f mm (%d dpi)\n", size, *dpi)
	fmt.Printf("訂正レベル: %s\n", strings.ToUpper(*levelStr))
	if *margin > 0 {
		fmt.Printf("余白幅   : %d px\n", *margin)
	}
	if *ftext != "" {
		fmt.Println("下部文字 :", *ftext)
	}
}
