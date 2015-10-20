import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

class ToneInstrument implements Instrument {
  Oscil sineOsc, lfo;
  ADSR  adsr;

  ToneInstrument(float frequency, float amplitude) {
    sineOsc = new Oscil(frequency, amplitude, Waves.TRIANGLE);
    lfo = new Oscil(1, 1, Waves.PHASOR);
    adsr = new ADSR(0.8, 0.01, 0.01, 0.8, 0.5);

    lfo.setFrequency(4);
    lfo.patch(sineOsc.amplitude);

    //lfo.offset.setLastValue(frequency);
    //lfo.setFrequency(10);
    //lfo.setAmplitude(10);
    //lfo.patch(sineOsc.frequency);

    sineOsc.patch(adsr);
  }

  void noteOn(float dur) {
    adsr.noteOn();
    adsr.patch(out);
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
  out.playNote(0, 0.1, new ToneInstrument(min(800, map(key, 'a', 'z', 100, 800)), 0.8));
}