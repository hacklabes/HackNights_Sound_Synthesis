import processing.video.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;
Oscil       wave0, wave1, wave2;

Movie movie;


void setup() {
  size(720, 850);
  background(0);
  // Load and play the video in a loop
  movie = new Movie(this, sketchPath("../videos/out114.mp4"));


  movie.loop();
  movie.read();

  movie.jump(random(movie.duration()));

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

  noStroke();
}

void keyPressed() {  
  if (key == ' ') {
    movie.jump(random(movie.duration()));
  }
}


void draw() {
  if (movie.available() == true) {
    background(0);
    movie.read(); 

    movie.loadPixels();


    long r=0;
    long g=0;
    long b=0; // averages 
    for (int j = 0; j < movie.height; j ++) {
      for (int i = 0; i < movie.width; i ++) {
        color pixelColor = movie.pixels[j * movie.width + i];

        r += red(pixelColor);
        g += green(pixelColor);
        b += blue(pixelColor);
      }
    }
    r = r / movie.pixels.length; //the average for red
    g = g / movie.pixels.length; //the average for green
    b = b / movie.pixels.length; //the average for blue
    
    //each channell is a different frequency
    //mapped R,G,B between 0-255 and 100 10000 Hz
    wave0.setFrequency(map(r,0,255,100,10000));
    wave1.setFrequency(map(g,0,255,100,10000));
    wave2.setFrequency(map(b,0,255,100,10000));

    color averageColor = color(r, g, b); //final color composed

    pushMatrix();
    translate(0, 0);
    scale(((float)width/height) * ((float)movie.width/movie.height));
    image(movie, 0, 0);
    popMatrix();

    pushMatrix();
    translate(0, height/2);
    scale(((float)width/height) * ((float)movie.width/movie.height));
    fill(averageColor); //fill the rectangle
    rect(0, 0, movie.width, movie.height);
    popMatrix();
  }
}