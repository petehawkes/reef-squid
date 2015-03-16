void startThreat() {

  targetZoom = threatZoom; 
  targetShiftDelay = threatShift;
  threat = true;
  threatTimeStamp = millis();
  // boidLines = true;

}



void stopThreat () {

  targetZoom = noThreatZoom; 
  targetShiftDelay = noThreatShift;
  threat = false; 
  //boidLines = false;


  // resetNodes():


}



void resetNodes() {

  for (int i=0; i<nodeCount; i++) {
    activeRing[i] = false;
  } 
  for (int i=0; i<shortCount; i++) {
    activeShort[i] = false;
  }
  activeRing[1] = true; 

}


