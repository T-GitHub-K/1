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

	"github.com/skip2/go-qrcode"
	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"
)

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

func loadFont(size float64) (font.Face, error) {
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
			return opentype.NewFace(f, &opentype.FaceOptions{Size: size, DPI: 300})
		}
	}
	return nil, fmt.Errorf("font not found")
}

func createQR(text, output string, sizeMM float64, footer string, level qrcode.RecoveryLevel) error {
	const dpi = 300
	pixel := int(sizeMM / 25.4 * dpi)
	qr, err := qrcode.New(text, level)
	if err != nil {
		return err
	}
	img := qr.Image(pixel)
	if footer == "" {
		f, err := os.Create(output)
		if err != nil {
			return err
		}
		defer f.Close()
		return png.Encode(f, img)
	}
	fontSize := float64(pixel / 14)
	if fontSize < 14 {
		fontSize = 14
	}
	face, err := loadFont(fontSize)
	if err != nil {
		return err
	}
	metrics := face.Metrics()
	textHeight := (metrics.Ascent + metrics.Descent).Round()
	canvas := image.NewRGBA(image.Rect(0, 0, pixel, pixel+textHeight+20))
	draw.Draw(canvas, canvas.Bounds(), &image.Uniform{color.White}, image.Point{}, draw.Src)
	draw.Draw(canvas, image.Rect(0, 0, pixel, pixel), img, image.Point{}, draw.Src)
	d := &font.Drawer{Dst: canvas, Src: image.NewUniform(color.Black), Face: face}
	width := d.MeasureString(footer).Round()
	d.Dot = fixed.P((pixel-width)/2, pixel+textHeight)
	d.DrawString(footer)
	f, err := os.Create(output)
	if err != nil {
		return err
	}
	defer f.Close()
	return png.Encode(f, canvas)
}

func main() {
	qrtxt := flag.String("qrtxt", "", "text for QR")
	output := flag.String("o", "gpQR.png", "output")
	sizeMM := flag.Float64("size-mm", 0, "size")
	auto := flag.Bool("auto-size", false, "auto")
	ftext := flag.String("ftext", "", "footer")
	levelStr := flag.String("level", "L", "Error correction level: L,M,Q,H")
	flag.Parse()

	if *qrtxt == "" {
		fmt.Println("--qrtxt は必須です")
		os.Exit(1)
	}

	var level qrcode.RecoveryLevel
	switch strings.ToUpper(*levelStr) {
	case "L":
		level = qrcode.Low
	case "M":
		level = qrcode.Medium
	case "Q":
		level = qrcode.Highest
	case "H":
		level = qrcode.High
	default:
		fmt.Println("--level は L/M/Q/H を指定してください")
		os.Exit(1)
	}

	out := filepath.Clean(*output)
	if info, err := os.Stat(out); err == nil && info.IsDir() {
		out = filepath.Join(out, "qr.png")
	}
	size := 40.0
	if *sizeMM > 0 {
		size = *sizeMM
	} else if *auto {
		size = calcAutoSizeMM(*qrtxt)
	}
	if err := createQR(*qrtxt, out, size, *ftext, level); err != nil {
		panic(err)
	}
	fmt.Println()
	fmt.Println("保存完了 :", out)
	fmt.Printf("QRサイズ : %.1f mm\n", size)
	fmt.Println("誤り訂正 :", strings.ToUpper(*levelStr))
	if *ftext != "" {
		fmt.Println("下部文字 :", *ftext)
	}
}
