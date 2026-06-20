package main

import (
	"fmt"
	"image"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/gen2brain/go-fitz"
	"github.com/makiuchi-d/gozxing"
	"github.com/makiuchi-d/gozxing/qrcode"
	"gopkg.in/ini.v1"
)

const (
	DefaultFolder = `C:\SCAN`
	DefaultDelay  = 5.0
)

var (
	watchFolder string
	exitDelay   float64
	pidFile     string
	processed   = map[string]bool{}
)

func loadConfig() {
	watchFolder = DefaultFolder
	exitDelay = DefaultDelay

	exe, err := os.Executable()
	if err != nil {
		return
	}

	iniPath :=
		filepath.Join(
			filepath.Dir(exe),
			"scanQR.ini",
		)

	cfg, err := ini.Load(iniPath)
	if err != nil {
		return
	}

	watchFolder =
		cfg.Section("SCAN").
			Key("watch_folder").
			MustString(DefaultFolder)

	exitDelay =
		cfg.Section("SCAN").
			Key("exit_delay").
			MustFloat64(DefaultDelay)

	if len(os.Args) > 1 {
		watchFolder = os.Args[1]
	}
}

func stopExisting() {

	b, err := os.ReadFile(pidFile)
	if err != nil {
		return
	}

	pid, err :=
		strconv.Atoi(
			string(b),
		)

	if err != nil {
		return
	}

	p, err :=
		os.FindProcess(pid)

	if err == nil && p != nil {

		_ =
			p.Signal(
				syscall.SIGTERM,
			)

		time.Sleep(
			time.Second,
		)

	}
}

func parseQR(
	text string,
) map[string]string {

	r :=
		map[string]string{}

	for _, line := range strings.Split(
		text,
		"\n",
	) {

		x :=
			strings.SplitN(
				line,
				"=",
				2,
			)

		if len(x) == 2 {

			r[strings.ToLower(
				strings.TrimSpace(
					x[0],
				),
			)] =
				strings.TrimSpace(
					x[1],
				)

		}
	}

	return r
}

func moveFile(
	src,
	folder,
	name string,
) error {

	err :=
		os.MkdirAll(
			folder,
			0755,
		)

	if err != nil {
		return err
	}

	dst :=
		filepath.Join(
			folder,
			name,
		)

	err =
		os.Rename(
			src,
			dst,
		)

	if err == nil {

		fmt.Println(
			"保存:",
			dst,
		)

	}

	return err
}

func decodeQR(
	img image.Image,
) (
	string,
	error,
) {

	bmp, err :=
		gozxing.
			NewBinaryBitmapFromImage(
				img,
			)

	if err != nil {
		return "", err
	}

	reader :=
		qrcode.
			NewQRCodeReader()

	res, err :=
		reader.Decode(
			bmp,
			nil,
		)

	if err != nil {
		return "", err
	}

	return res.GetText(), nil
}

func readQR(
	pdf string,
) (
	string,
	error,
) {

	doc, err :=
		fitz.New(
			pdf,
		)

	if err != nil {
		return "", err
	}

	defer doc.Close()

	for i := 0; i < doc.NumPage(); i++ {

		img, err :=
			doc.Image(
				i,
			)

		if err != nil {
			continue
		}

		text, err :=
			decodeQR(
				img,
			)

		if err == nil {

			fmt.Println(
				"QR読取:",
				filepath.Base(pdf),
			)

			return text, nil
		}
	}

	return "", fmt.Errorf("QR not found")
}

func monitor() {

	var empty time.Time

	fmt.Println(
		"監視開始:",
		watchFolder,
	)

	for {

		files, _ :=
			filepath.Glob(
				filepath.Join(
					watchFolder,
					"*.pdf",
				),
			)

		if len(files) == 0 {

			if empty.IsZero() {
				empty = time.Now()
			}

			if time.
				Since(
					empty,
				).
				Seconds() >=
				exitDelay {

				return
			}

		} else {

			empty =
				time.Time{}
		}

		for _, f := range files {

			if processed[f] {
				continue
			}

			qr, err :=
				readQR(
					f,
				)

			if err != nil {
				continue
			}

			info :=
				parseQR(
					qr,
				)

			folder :=
				info["folder"]

			name :=
				info["filename"]

			if folder != "" &&
				name != "" {

				err :=
					moveFile(
						f,
						folder,
						name,
					)

				if err == nil {
					processed[f] = true
				}

			}

		}

		time.Sleep(
			500 *
				time.Millisecond,
		)

	}
}

func main() {

	loadConfig()

	_ =
		os.MkdirAll(
			watchFolder,
			0755,
		)

	pidFile =
		filepath.Join(
			watchFolder,
			"scanqr.pid",
		)

	stopExisting()

	_ =
		os.WriteFile(
			pidFile,
			[]byte(
				fmt.Sprint(
					os.Getpid(),
				),
			),
			0644,
		)

	defer os.Remove(pidFile)

	monitor()
}
