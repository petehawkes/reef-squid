//
//
// Boid & Flocking by Daniel Shiffman
// http://www.shiffman.net/
// http://processing.org/learning/topics/flocking.html
// code pulled April 17, 2010
//
// mods by Pete Hawkes
// http://www.petehawkes.com
import processing.opengl.*;

//
//  VARS TO EDIT

int easeHold = 350;        // how long flocks stay active
int shiftDelay = 100;      // speed of node shift
int boidCount = 40;        // boids per flock
float boidSpeed = 50.0;    // max speed of boids
float boidForce = 0.05;    // max force of boids
boolean boidLines = false;  //connect boids with lines
int boidLineTrans = 30;    
int minBoidSize = 4;        
int maxBoidSize = 6;        
int minBoidTrans = 100;   
int maxBoidTrans = 200;
int boidSpeedReducer = 20;  // reduces speed of boid when it pulls in. smaller = more erradic


//
// dimenisons
int w = 1024;         
int h = 768;          


//
//

ArrayList flocks = new ArrayList(); // An arraylist for ring flocks
int[] squidColors = new int[6];

int radius = 300;
int nodeCount = 32;
int shortCount = 7;
int interNode = 9;
float radInc = TWO_PI/nodeCount;
float timeStamp = 0;


boolean[] activeRing = new boolean[nodeCount];
boolean[] newRing = new boolean[nodeCount];
boolean[] activeShort = new boolean[shortCount];
boolean[] newShort = new boolean[shortCount];



void setup() {
  background(0);
  size(w, h, OPENGL);
  ellipseMode(CENTER);
  smooth();
  
  activeRing[30] = true;   // first ring active

  translate(w/2, h/2-10);
  
  //
  // define squid colors
  squidColors[0] = color(106, 78, 56);
  squidColors[1] = color(139, 176, 166);
  squidColors[2] = color(156, 166, 139);
  squidColors[3] = color(82, 125, 112);
  squidColors[4] = color(126, 68, 55);
  squidColors[5] = color(93, 155, 130);


  //
  // draw ring squids
  for (int i=0; i<nodeCount; i++) {
    float rad = radInc*i;
    float x = cos(rad)*radius;
    float y = sin(rad)*radius;
    flocks.add(new Flock(x, y));
  } 

  //
  // draw shortcut
  for (int i=0; i<shortCount; i++) {
    // custom shifting to manually place the diagonal shortcut
    flocks.add(new Flock(250-(i*44), 40+(i*36)));
  }
  for (int k = 0; k < flocks.size(); k++) {
    Flock f = (Flock) flocks.get(k);  
    for (int i = 0; i < boidCount; i++) {
      f.addBoid(new Boid(new PVector(f.x,f.y), boidSpeed, boidForce, new PVector(f.x, f.y)));
    }
  }

}


void draw() {
  
  fill(0, 255);
  noStroke();
  rect(0, 0, w, h);
  translate(w/2, h/2-10);
  scale(.8);

  for (int k = 0; k < flocks.size(); k++) {
    
    //
    // run flocking
    Flock f = (Flock) flocks.get(k);  
    f.run();

    //
    // connect boids with lines
    if (boidLines) {
      noFill();
      stroke(255, boidLineTrans);
      beginShape();
      for (int i = 0 ; i < f.boids.size(); i++) {
          Boid b = (Boid) f.boids.get(i);
          vertex(b.loc.x, b.loc.y);
      }
      endShape();
    }
    
  }

  //
  // shift ring on a delay
  if (millis()-timeStamp > shiftDelay) {
    timeStamp = millis();
    shiftRing();
  }
  
}








