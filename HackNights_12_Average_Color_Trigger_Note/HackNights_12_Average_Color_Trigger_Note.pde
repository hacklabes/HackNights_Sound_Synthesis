import processing.video.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;

Movie movie;

Midi2Hz midi;

long lastR = 0;
long lastG = 0;
long lastB = 0; // track of the last Colors

final int[] notes= { 
      19, 21, 24, 26, 28, 31, 33, 36, 
      19, 21, 24, 26, 28, 31, 33, 36, 
      0, 2, 4, 7, 9, 12, 14, 16, 
      0, 2, 4, 7, 9, 12, 14, 16, 
      0, 2, 4, 7, 9, 12, 14, 16, 
      0, 2, 4, 7, 9, 12, 14, 16
    };

void setup() {
  size(720, 850);
  background(0);
  // Load and play the video in a loop
  movie = new Movie(this, sketchPath("../videos/out153.mp4"));
    
  movie.loop();
  movie.read();
  movie.volume(0.1);
  movie.jump(random(movie.duration()));

  minim = new Minim(this);
  // set up an output channel
  out = minim.getLineOut(Minim.MONO, width);

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
    
    
    //if the color change then trigger the sound
    //the 10 is the amount of change of 
    int threshold = 5;
    
    
    //using MIDI notes from 0 to 127 https://newt.phys.unsw.edu.au/jw/notes.html
    // if the last R, G, B is different by the thereshold then trigger the note
    // r%127 takes the color value from 0-255(color interval) and transforms it to 0-127 (MIDI interval)
    if( abs(lastR - r) > threshold){
      
        out.playNote(0, 0.3, new ToneInstrument(Frequency.ofMidiNote(36+notes[(int)r%notes.length]).asHz(), 0.5));
        
    }
    if( abs(lastG - g) > threshold){
      
        out.playNote(0, 0.3, new ToneInstrument(Frequency.ofMidiNote(36+notes[(int)r%notes.length]).asHz(), 0.5));
        
    }
    if( abs(lastB - b) > threshold){
      
        out.playNote(0, 0.3, new ToneInstrument(Frequency.ofMidiNote(36+notes[(int)r%notes.length]).asHz(), 0.5));
        
    }
    
    //keep Track our last color
    lastR = r;
    lastG = g;
    lastB = b;
    
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


class ToneInstrument implements Instrument {
  Oscil sineOsc;

  ToneInstrument(float frequency, float amplitude) {
    sineOsc = new Oscil(frequency, amplitude, Waves.SINE);
  }

  void noteOn(float dur) {
    sineOsc.patch(out);
  }

  void noteOff() { 
    sineOsc.unpatch(out);
  }
}