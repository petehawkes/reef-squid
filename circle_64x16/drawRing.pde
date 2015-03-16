void drawRing() {
 
 for (int i=0; i<nodeCount; i++) {
    
       float rad = radInc*i;
       float x = cos(rad)*radius;
       float y = sin(rad)*radius;
       
       if (activeRing[i]) {
           drawCircle(nodeSize*1.1, color(255), x, y);  
           drawCircle(nodeSize, onColor, x, y);
       } else {
           drawCircle(nodeSize, offColor, x, y);  
       }
             
  } 
  
}


