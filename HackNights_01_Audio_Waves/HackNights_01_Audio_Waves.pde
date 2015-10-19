import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;
Oscil       wave0, wave1, wave2;

void setup() {
  size(700, 400);
  minim = new Minim(this);

  // set up an output channel
  out = minim.getLineOut(Minim.MONO, width);

  // init an oscillator and patch it to output
  wave0 = new Oscil(440, 0.3f, Waves.SINE);
  wave0.patch(out);

  wave1 = new Oscil(660, 0.3f, Waves.SINE);
  wave1.patch(out);

  wave2 = new Oscil(880, 0.3f, Waves.SINE);
  wave2.patch(out);
}

void draw() {
  background(0);
  strokeWeight(2);
  stroke(255);

  for (int i=0; i<out.bufferSize()-1; i++) {
    line(i, (height/2)-out.left.get(i)*(height/2), i+1, (height/2)-out.left.get(i+1)*(height/2));
  }
}

void keyPressed() {
  wave0.setFrequency(random(400, 1000));
  wave1.setFrequency(random(400, 1000));
  wave2.setFrequency(random(400, 1000));
}