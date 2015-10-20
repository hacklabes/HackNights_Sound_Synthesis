import processing.video.*;

Movie movie;

void setup() {
  size(720, 850);
  background(0);
  // Load and play the video in a loop
  //movie = new Movie(this, "out48.mp4");
  //movie = new Movie(this, "out71.mp4");
  //movie = new Movie(this, "out114.mp4");
  //movie = new Movie(this, "out148.mp4");
  movie = new Movie(this, sketchPath("../out71.mp4"));

  movie.loop();
  movie.read();

  movie.jump(random(movie.duration()));

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
    
    
    color averageColor = color(r,g,b); //final color composed

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