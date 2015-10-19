import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;
Oscil       wave;

void setup() {
  size(700, 400);
  minim = new Minim(this);

  // set up an output channel
  out = minim.getLineOut(Minim.MONO, width);

  // init an oscillator and patch it to output
  wave = new Oscil(440, 0.5f, Waves.SINE);
  wave.patch(out);
}

void draw() {
  background(0);
  strokeWeight(4);
  stroke(255);

  for (int i=0; i<out.bufferSize()-1; i++) {
    line(i, (height/2)-out.left.get(i)*(height/2), i+1, (height/2)-out.left.get(i+1)*(height/2));
  }
}

void mouseMoved() {
  float amp = map(mouseY, 0, height, 1, 0);
  wave.setAmplitude(amp);

  float freq = map(mouseX, 0, width, 200, 4000);
  wave.setFrequency(freq);
}