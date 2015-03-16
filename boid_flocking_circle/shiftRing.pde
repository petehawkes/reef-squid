void shiftRing() {

  //
  // shift nodes on the outer ring
  newRing[0] = activeRing[nodeCount-1];
  //
  for (int i=0; i<nodeCount-1; i++) {
    newRing[i+1] = activeRing[i];  
  }

  //
  // shift nodes on the shortcut
  newShort[0] = false;
  //
  for (int i=0; i<shortCount-1; i++) {
    newShort[i+1] = activeShort[i];  
  }

  // 
  // start new shortcut
  if (activeRing[0]) {
    newShort[0] = true;
  }

  //
  // check shortcut end
  if (activeRing[interNode-1] && activeShort[shortCount-1]) {
    newRing[interNode] = false;
  }

  if (!activeRing[interNode-1] && activeShort[shortCount-1]) {
    newRing[interNode] = true;
  }

  //
  // push new to active
  for (int i=0; i<shortCount; i++) {
    activeShort[i] = newShort[i];  
  } 
  for (int i=0; i<nodeCount; i++) {
    activeRing[i] = newRing[i];  
  } 

  //
  // update atEase states in each flock
  for (int k=0; k<nodeCount; k++) {
    if (activeRing[k]) {
      Flock f = (Flock) flocks.get(k);  
      for (int i = 0 ; i < f.boids.size(); i++) {
        Boid b = (Boid) f.boids.get(i);
        b.timeStamp = millis();
        b.atEase = false;
      }
    } 
    else {
      Flock f = (Flock) flocks.get(k);  
      for (int i = 0 ; i < f.boids.size(); i++) {
        Boid b = (Boid) f.boids.get(i);
        if (millis() - b.timeStamp > easeHold) {
          b.atEase = true;
        }
      }
    } 
  } 
  
  //
  // update atEase states in each flock
  for (int k=0; k<shortCount; k++) {
    if (activeShort[k]) {
      Flock f = (Flock) flocks.get(k+nodeCount);  
      for (int i = 0 ; i < f.boids.size(); i++) {
        Boid b = (Boid) f.boids.get(i);
        b.timeStamp = millis();
        b.atEase = false;
      }
    } 
    else {
      Flock f = (Flock) flocks.get(k+nodeCount);  
      for (int i = 0 ; i < f.boids.size(); i++) {
        Boid b = (Boid) f.boids.get(i);
        if (millis() - b.timeStamp > easeHold) {
          b.atEase = true;
        }
      }
    } 
  } 



}


