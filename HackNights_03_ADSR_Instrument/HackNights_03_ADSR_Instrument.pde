import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

class ToneInstrument implements Instrument {
  Oscil sineOsc;
  ADSR  adsr;

  ToneInstrument(float frequency, float amplitude) {
    sineOsc = new Oscil(frequency, amplitude, Waves.TRIANGLE);
    adsr = new ADSR(0.8, 0.01, 0.01, 0.8, 0.1);
    sineOsc.patch(adsr);
  }

  void noteOn(float dur) {
    adsr.patch(out);
    adsr.noteOn();
  }

  void noteOff() {
    adsr.unpatchAfterRelease(out); 
    adsr.noteOff();
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
  out.playNote(0, 0.2, new ToneInstrument(min(800, map(key, 'a', 'z', 100, 800)), 0.8));
}