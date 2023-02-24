// package main plays two audio file
package main

import (
	"log"
	"os"
	"time"

	"github.com/faiface/beep"
	"github.com/faiface/beep/mp3"
	"github.com/faiface/beep/speaker"
)

func main() {
	f, err := os.Open("test.mp3")
	if err != nil {
		log.Fatal(err)
	}
	st, format, err := mp3.Decode(f)
	if err != nil {
		log.Fatal(err)
	}
	defer st.Close()

	speaker.Init(format.SampleRate, format.SampleRate.N(time.Second/10))

	done := make(chan bool)
	speaker.Play(beep.Seq(st, beep.Callback(func() {
		done <- true
	})))
	<-done
}
