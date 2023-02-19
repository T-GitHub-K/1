package main

import (
	"fmt"
	"time"

	"github.com/faiface/beep/speaker"
)

const (
	dotDuration       = 200 * time.Millisecond
	dashDuration      = 3 * dotDuration
	symbolPause       = dotDuration
	letterPause       = 3 * dotDuration
	sampleRate        = 44100
	bufferSize        = 882
	volume            = 0.3
	shortBeepDuration = 100 * time.Millisecond
	longBeepDuration  = 300 * time.Millisecond
)

var morseCode = map[rune]string{
	'A':  ".-",
	'B':  "-...",
	'C':  "-.-.",
	'D':  "-..",
	'E':  ".",
	'F':  "..-.",
	'G':  "--.",
	'H':  "....",
	'I':  "..",
	'J':  ".---",
	'K':  "-.-",
	'L':  ".-..",
	'M':  "--",
	'N':  "-.",
	'O':  "---",
	'P':  ".--.",
	'Q':  "--.-",
	'R':  ".-.",
	'S':  "...",
	'T':  "-",
	'U':  "..-",
	'V':  "...-",
	'W':  ".--",
	'X':  "-..-",
	'Y':  "-.--",
	'Z':  "--..",
	'0':  "-----",
	'1':  ".----",
	'2':  "..---",
	'3':  "...--",
	'4':  "....-",
	'5':  ".....",
	'6':  "-....",
	'7':  "--...",
	'8':  "---..",
	'9':  "----.",
	'.':  ".-.-.-",
	',':  "--..--",
	'?':  "..--..",
	'\'': ".----.",
	'!':  "-.-.--",
	'/':  "-..-.",
	'(':  "-.--.",
	')':  "-.--.-",
	'&':  ".-...",
	':':  "---...",
	';':  "-.-.-.",
	'=':  "-...-",
	'+':  ".-.-.",
	'-':  "-....-",
	'_':  "..--.-",
	'"':  ".-..-.",
	'$':  "...-..-",
	'@':  ".--.-.",
}

func main() {
	message := "SOS"
	for _, c := range message {
		if code, ok := morseCode[c]; ok {
			for _, s := range code {
				switch s {
				case '.':
					dot()
				case '-':
					dash()
				}
				time.Sleep(symbolPause)
			}
			time.Sleep(letterPause)
		}
	}
}

func dot() {
	fmt.Print(".")
	beep(shortBeepDuration)
}

func dash() {
	fmt.Print("-")
	beep(longBeepDuration)
}

func beep(duration time.Duration) {
	err := speaker.Init(sampleRate, bufferSize)
	if err != nil {
		fmt.Println("Failed to initialize speaker:", err)
		return
	}
	defer speaker.Close()

	streamer := beep.Seq(beep.Take(duration, beep.Sine(sampleRate, volume)), beep.Callback(func() {
		// do nothing
	}))

	speaker.Play(streamer)
	<-streamer
}
