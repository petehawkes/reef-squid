void motionDetect () { 
  if (video.available()) {
    // Save previous frame for motion detection!!
    prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); 
    pixelCompare.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); 
    // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.updatePixels();
    video.read();
  }

//  prevFrame.filter(GRAY);
//  video.filter(GRAY);
//  prevFrame.filter(DILATE);
//  video.filter(DILATE);

  video.loadPixels();
  prevFrame.loadPixels();
  pixelCompare.loadPixels();


  // Begin loop to walk through every pixel
  int motionCount = 0;

  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {

      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      color current = video.pixels[loc];      // Step 2, what is the current color
      color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous);
      float diff = dist(r1,g1,b1,r2,g2,b2);

      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) { 
        // If motion, display black
        pixelCompare.pixels[loc] = color(0);
        motionCount++;
      } 
      else {
        // If not, display white
        pixelCompare.pixels[loc] = color(255);
      }
    }
  }
  //lastAvgMotion = avgMotion;

  lastAvg5 = lastAvg4;
  lastAvg4 = lastAvg3;
  lastAvg3 = lastAvg2;
  lastAvg2 = lastAvg1;
  lastAvg1 = avgMotion;



  avgMotion = smoothMotion(motionCount);
  avgMotionChange = abs(avgMotion-lastAvg5);
  //println ("avg:"+abs(lastAvgMotion-avgMotion));

  if (motionReady) {
    //if(abs(lastAvgMotion-avgMotion)>threshold) {
    if(avgMotionChange>threshold) {
      startThreat(); 
    } 
    else {
      if (threat && millis() - threatTimeStamp > threatHoldTime) {
        stopThreat();
      }
    }
  } 
  else {
    startThreat();
    if (millis() > 3000) motionReady = true;
  }

  if (debug) {

    image(pixelCompare, width-320, 0, 320, 240 ); 
    image(video, 0, 0, 320, 240 ); 
    textFont(sans);
    fill(255);
    text(avgMotionChange, 10, 260);
   
  }
}



