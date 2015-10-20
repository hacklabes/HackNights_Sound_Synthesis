import processing.video.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioOutput out;

Movie movie;

int videoW; //width
int videoH; //height

final static int gridX = 10; // Grid X
final static int gridY = 10; // Grid Y

color lastColor[][]; 

void setup() {
  size(720, 850);
  background(0);
  // Load and play the video in a loop

  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );

  
  movie = new Movie(this, sketchPath("../videos/RB01.mp4"));


  movie.loop();
  movie.read();

  movie.jump(random(movie.duration()));

  noStroke();  

  videoW = movie.width;
  videoH = movie.height;

  lastColor = new color[gridX][gridY];
 
  for (int x = 0; x < gridX; x++) {
    for (int y = 0; y < gridY; y++) {
      lastColor[x][y] = color(0,0,0);
    }
  }
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
    movie.volume(0.1);
    //scale to make the video and grid fits on your window size
    float scaleFact = ((float)width/height) * ((float)movie.width/movie.height);

    calcSAT(movie.get(), 0, height/2, scaleFact); // calculate 
    pushMatrix();
    translate(0, 0);
    scale(scaleFact);
    image(movie, 0, 0);
    drawGrid(0, 0);
    popMatrix();
  }
}




void drawGrid(float x, float y) {
  int sWeight = 2;
  int w = videoW;
  int h = videoH;
  strokeWeight(sWeight);
  stroke(255);
  pushMatrix();
  translate(x, y);

  beginShape(LINES);

  float horizontalStep =  (h-sWeight) / gridY;
  float verticalStep =  (w-sWeight)/ gridX;

  //draw vertical lines
  for (int i = 0; i <= gridX; i ++) {
    vertex(i * verticalStep, 0);
    vertex(i * verticalStep, h-sWeight);
  } 
  //draw horizontal lines
  for (int i = 0; i <= gridY; i ++) {
    vertex(0, i * horizontalStep);
    vertex(w - sWeight, i * horizontalStep);
  }
  endShape(CLOSE);

  popMatrix();
}


//Calculate the Summed Area Table
//efficient algorithm to calculate the averages of the colors in a rectangular subset grid
//we want a precise average color for a given grid of our image
//https://en.wikipedia.org/wiki/Summed_area_table
void calcSAT(PImage img, float pxrect, float pyrect, float scale) {
  int w = img.width;
  int h = img.height;

  final int w1 = w+1;
  final int h1 = h+1;

  int SAT_R[] = new int[w1*h1];
  int SAT_G[] = new int[w1*h1];
  int SAT_B[] = new int[w1*h1];

  //based on http://www.openprocessing.org/sketch/101126
  int ps = 0, pd = w1+1;
  for (int y = 1; y <= h; y++) {
    for (int x = 1; x <= w; x++) {   
      SAT_R[pd] = ((img.pixels[ps]>>16)&0xFF) + SAT_R[pd-w1]+SAT_R[pd-1] - SAT_R[pd-w1-1];
      SAT_G[pd] = ((img.pixels[ps]>> 8)&0xFF) + SAT_G[pd-w1]+SAT_G[pd-1] - SAT_G[pd-w1-1];
      SAT_B[pd] = ((img.pixels[ps]    )&0xFF) + SAT_B[pd-w1]+SAT_B[pd-1] - SAT_B[pd-w1-1];
      ps++;
      pd++;
    }
    pd++;
  }

  pushMatrix();
  translate(pxrect, pyrect);
  scale(scale);

  for (int i = 0; i < gridX; i ++) {
    for (int j = 0; j < gridY; j ++) {

      int psx = w/gridX;
      int psy = h/gridY;

      int px = i * psx;
      int py = j * psy;
      int yend = py + psy;
      int xend = px + psx;

      int area = psx*psy;

      int A = py  *(w+1)+px;
      int B = py  *(w+1)+xend;
      int C = yend*(w+1)+xend;
      int D = yend*(w+1)+px;

      int mr = Math.round(  (SAT_R[C] + SAT_R[A] - SAT_R[B] - SAT_R[D]) /((float)area));
      int mg = Math.round(  (SAT_G[C] + SAT_G[A] - SAT_G[B] - SAT_G[D]) /((float)area));
      int mb = Math.round(  (SAT_B[C] + SAT_B[A] - SAT_B[B] - SAT_B[D]) /((float)area));

      color averageColor = color(mr, mg, mb);
      
      int threshold = 6;
      
      if(abs(red(lastColor[i][j]) - mr) >  threshold){
        out.playNote(0, 0.1, new ToneInstrument(Frequency.ofMidiNote(mr%127).asHz(), 0.3));
      }
      if(abs(red(lastColor[i][j]) - mr) >  threshold){
        out.playNote(0, 0.1, new ToneInstrument(Frequency.ofMidiNote(mg%127).asHz(), 0.3));
      }
      if(abs(red(lastColor[i][j]) - mr) >  threshold){
        out.playNote(0, 0.1, new ToneInstrument(Frequency.ofMidiNote(mb%127).asHz(), 0.3));
      }
  
      lastColor[i][j] = averageColor;
      
      fill(averageColor);
      noStroke();
      rect(i*psx, j*psy, psx, psy);
    }
  }
  popMatrix();
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