package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"time"

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

	if err == nil {

		iniFile :=
			filepath.Join(
				filepath.Dir(exe),
				"scanQR.ini",
			)

		if _, err := os.Stat(iniFile); err == nil {

			cfg, err := ini.Load(iniFile)

			if err == nil {

				watchFolder =
					cfg.Section("SCAN").
						Key("watch_folder").
						MustString(DefaultFolder)

				exitDelay =
					cfg.Section("SCAN").
						Key("exit_delay").
						MustFloat64(DefaultDelay)

			}

		}

	}

	if len(os.Args) > 1 {
		watchFolder = os.Args[1]
	}

}

func stopExisting() {

	if _, err := os.Stat(pidFile); err != nil {
		return
	}

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
		os.FindProcess(
			pid,
		)

	if err == nil && p != nil {

		_ =
			p.Signal(
				syscall.SIGTERM,
			)

		time.Sleep(
			2 * time.Second,
		)

	}

}

func parseQR(
	text string,
) map[string]string {

	result :=
		map[string]string{}

	for _, line := range strings.Split(
		text,
		"\n",
	) {

		if strings.Contains(
			line,
			"=",
		) {

			x :=
				strings.SplitN(
					line,
					"=",
					2,
				)

			result[strings.ToLower(
				strings.TrimSpace(
					x[0],
				),
			)] =
				strings.TrimSpace(
					x[1],
				)

		}

	}

	return result

}

func moveFile(
	src,
	folder,
	filename string,
) {

	_ =
		os.MkdirAll(
			folder,
			0755,
		)

	dst :=
		filepath.Join(
			folder,
			filename,
		)

	base :=
		dst

	ext :=
		filepath.Ext(
			dst,
		)

	n := 1

	for {

		if _, err := os.Stat(dst); err != nil {
			break
		}

		dst =
			fmt.Sprintf(
				"%s_%d%s",
				strings.TrimSuffix(
					base,
					ext,
				),
				n,
				ext,
			)

		n++

	}

	err :=
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

}

func readQR(
	pdf string,
) (
	string,
	error,
) {

	return "", nil

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

				empty =
					time.Now()

			}

			if time.
				Since(
					empty,
				).
				Seconds() >=
				exitDelay {

				os.Exit(
					0,
				)

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

			if info["folder"] != "" &&
				info["filename"] != "" {

				moveFile(
					f,
					info["folder"],
					info["filename"],
				)

				processed[f] =
					true

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

	monitor()

}
