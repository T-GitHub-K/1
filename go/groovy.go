package main

import (
	"fmt"
	"os"
	"time"
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
	speaker, err := os.Open("/dev/audio")
	if err != nil {
		fmt.Println("Failed to open speaker:", err)
		return
	}
	defer speaker.Close()
	for t := 0; t < int(d)/10; t++ {
		speaker.Write([]byte{1, 1, 1, 1, 1, 1, 1, 1})
		time.Sleep(10 * time.Millisecond)
		speaker.Write([]byte{0, 0, 0, 0, 0, 0, 0, 0})
		time.Sleep(10 * time.Millisecond)
	}
}
