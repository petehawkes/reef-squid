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
  if (activeRing[17] && activeShort[shortCount-1]) {
      newRing[18] = false;
  }
  
  if (!activeRing[17] && activeShort[shortCount-1]) {
      newRing[18] = true;
  }
  
  //
  // push new to active
  for (int i=0; i<shortCount; i++) {
     activeShort[i] = newShort[i];  
  } 
  for (int i=0; i<nodeCount; i++) {
     activeRing[i] = newRing[i];  
  } 
  
}
