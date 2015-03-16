//
//
// Boid & Flocking by Daniel Shiffman
// http://www.shiffman.net/
// http://processing.org/learning/topics/flocking.html
// code pulled April 17, 2010
//
// mods by Pete Hawkes
// http://www.fightthecode.com




//
//  VARS TO EDIT

boolean debug = false;  // show debugging stuff
float threshold = 20;   // motion detect threshold
int easeHold = 0;        // how long flocks stay active

float noThreatShift = 50;  // speed of node shift
float threatShift = 500;    // speed of node shift under threat

int boidCount = 25;        // boids per flock
float boidSpeed = 50.0;    // max speed of boids
float boidForce = 0.05;    // max force of boids
boolean boidLines = false;  //connect boids with lines
int boidLineTrans = 150;    
int minBoidSize = 4;        
int maxBoidSize = 10;        
int minBoidTrans = 100;   
int maxBoidTrans = 200;
int boidSpeedReducer = 15;  // reduces speed of boid when it pulls in. smaller = more erradic
float threatZoom = 0.4;
float noThreatZoom = threatZoom+.2;
// zoom under threat
int threatHoldTime = 1000;  // how long does threat persist

int captureWidth = 1;
int captureHeight = 1;


//
// motion detect
import processing.video.*;
Capture video;
PFont sans;
PImage prevFrame;
PImage pixelCompare;
int avgMotion;
int avgMotionChange;
int lastAvg1;
int lastAvg2;
int lastAvg3;
int lastAvg4;
int lastAvg5;

int[] motionThreshold = new int[30];
int[] motion = new int[30];


//
// dimenisons
int w = 800;         
int h = 600; 
//int w = 800;
//int h = 600;
int offsetX = -w/2;
int offsetY = -h/2;

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
float threatTimeStamp = 0;
boolean threat = false;
float zoom = 1.0;
float targetZoom = noThreatZoom;
float shiftDelay = noThreatShift; 
float targetShiftDelay = noThreatShift;
float lineTrans;
boolean motionReady = false;


boolean[] activeRing = new boolean[nodeCount];
boolean[] newRing = new boolean[nodeCount];
boolean[] activeShort = new boolean[shortCount];
boolean[] newShort = new boolean[shortCount];



void setup() {
  background(0);
  size(w, h);
  ellipseMode(CENTER);
  smooth();

  //boidLines = true;
  noCursor();
  //cursor(CROSS);
  activeRing[1] = true;   // first ring active

  sans = loadFont("SansSerif-10.vlw");

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

  //
  // motion detect
  
//  String extcam = "USB Video Class Video";
//  video = new Capture (this,640,480,extcam,30); 
  
  video = new Capture(this, captureWidth, captureHeight, 30);
  prevFrame = createImage(video.width,video.height,RGB);
  pixelCompare = createImage(video.width,video.height,RGB);



}


void draw() {


  fill(0, 255);
  rect(0, 0, w, h);

  pushMatrix();
  translate(w/2, h/2-10);


  if (threat) {
    zoom += (targetZoom - zoom)*.2;
    lineTrans += (boidLineTrans-lineTrans)*.1;
  } 
  else {
    zoom += (targetZoom - zoom)*.01;
    lineTrans += (0-lineTrans)*.1;
  }
  scale(zoom);

  for (int k = 0; k < flocks.size(); k++) {

    //
    // run flocking
    Flock f = (Flock) flocks.get(k);  
    f.run();

    //
    // connect boids with lines
    if (boidLines) {
      noFill();
      stroke(255, lineTrans);
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

  if (targetShiftDelay > shiftDelay) shiftDelay+=2;
  if (targetShiftDelay < shiftDelay) shiftDelay--;

  //shiftDelay += (targetShiftDelay - shiftDelay) *.03;

  if (millis()-timeStamp > shiftDelay) {
    timeStamp = millis();
    shiftRing();
  }

  // println("shiftDelay:"+shiftDelay);

  fill(0, lineTrans+(255-lineTrans));
  noStroke();
  ellipse(0, 0, 100, 100);

  popMatrix();

  motionDetect();

}


//void mousePressed() {
//  startThreat();
//}
//
//void mouseReleased() {
//  stopThreat();
//}
//








