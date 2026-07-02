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

			return opentype.NewFace(
				f,
				&opentype.FaceOptions{
					Size: size,
					DPI:  300,
				},
			)
		}
	}

	return nil, fmt.Errorf("font not found")
}

func createQR(text, output string, sizeMM float64, footer string) error {

	const dpi = 300

	pixel := int(sizeMM / 25.4 * dpi)

	qr, err := qrcode.New(
		text,
		qrcode.Medium,
	)
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

	canvas := image.NewRGBA(
		image.Rect(
			0,
			0,
			pixel,
			pixel+textHeight+20,
		),
	)

	draw.Draw(
		canvas,
		canvas.Bounds(),
		&image.Uniform{color.White},
		image.Point{},
		draw.Src,
	)

	draw.Draw(
		canvas,
		image.Rect(
			0,
			0,
			pixel,
			pixel,
		),
		img,
		image.Point{},
		draw.Src,
	)

	d := &font.Drawer{
		Dst:  canvas,
		Src:  image.NewUniform(color.Black),
		Face: face,
	}

	width := d.MeasureString(
		footer,
	).Round()

	x := (pixel - width) / 2

	y := pixel + textHeight

	d.Dot = fixed.P(
		x,
		y,
	)

	d.DrawString(
		footer,
	)

	file, err := os.Create(output)
	if err != nil {
		return err
	}

	defer file.Close()

	return png.Encode(
		file,
		canvas,
	)
}

func main() {

	filename := flag.String(
		"filename",
		"",
		"filename",
	)

	output := flag.String(
		"o",
		"qr.png",
		"output",
	)

	sizeMM := flag.Float64(
		"size-mm",
		0,
		"size",
	)

	auto := flag.Bool(
		"auto-size",
		false,
		"auto",
	)

	ftext := flag.String(
		"ftext",
		"",
		"footer",
	)

	flag.Parse()

	if *filename == "" {

		fmt.Println(
			"--filename は必須です",
		)

		os.Exit(1)
	}

	text := fmt.Sprintf(
		"filename=%s",
		*filename,
	)

	size := 40.0

	if *sizeMM > 0 {

		size = *sizeMM

	} else if *auto {

		size = calcAutoSizeMM(text)
	}

	if err := createQR(
		text,
		filepath.Clean(*output),
		size,
		*ftext,
	); err != nil {

		panic(err)
	}

	fmt.Println()
	fmt.Println("保存完了 :", *output)
	fmt.Printf("QRサイズ : %.1f mm\n", size)

	if *ftext != "" {

		fmt.Println(
			"下部文字 :",
			*ftext,
		)
	}
}
