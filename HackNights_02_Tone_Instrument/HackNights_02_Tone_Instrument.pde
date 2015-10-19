import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

class ToneInstrument implements Instrument {
  Oscil sineOsc;

  ToneInstrument(float frequency, float amplitude) {
    sineOsc = new Oscil(frequency, amplitude, Waves.TRIANGLE);
  }

  void noteOn(float dur) {
    sineOsc.patch(out);
  }

  void noteOff() { 
    sineOsc.unpatch(out);
  }
}

void setup() {
  size(512, 200);
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, width);
}

// draw is run many times
void draw() {
  background(0);
  stroke(255);
  for (int i=0; i<out.bufferSize()-1; i++) {
    line(i, (height/2)+out.left.get(i)*(height/2), i+1, (height/2)+out.left.get(i+1)*(height/2));
  }
}

void keyPressed() {
  out.playNote(0, 0.2, new ToneInstrument(800, 0.8));
}