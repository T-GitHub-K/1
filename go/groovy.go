package main

import (
	"fmt"
	"math"
	"time"

	"github.com/faiface/beep/speaker"
)

const dotDuration = 200 * time.Millisecond
const dashDuration = 3 * dotDuration
const symbolPauseDuration = dotDuration
const letterPauseDuration = 3 * dotDuration

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
				time.Sleep(symbolPauseDuration)
			}
			time.Sleep(letterPauseDuration)
		}
	}
}

func dot() {
	fmt.Print(".")
	beep(dotDuration)
}

func dash() {
	fmt.Print("-")
	beep(dashDuration)
}

func beep(d time.Duration) {
	err := speaker.Init(sampleRate, bufferSize)
	if err != nil {
		fmt.Println("Failed to initialize speaker:", err)
		return
	}
	defer speaker.Close()

	synth := beep.Synth{
		SynthFunc: func(buf [][2]float64) (int, bool) {
			for i := range buf {
				t := float64(time.Now().UnixNano()) / 1e9
				if t < float64(d)/1e9 {
					buf[i][0] = 0.5 * (1 - math.Cos(2*math.Pi*440*t))
					buf[i][1] = buf[i][0]
				} else {
					return i, false
				}
			}
			return len(buf), true
		},
	}

	done := make(chan bool)
	speaker.Play(beep.Seq(synth, beep.Callback(func() {
		done <- true
	})))
	<-done
}
