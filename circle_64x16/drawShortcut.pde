

void drawShortCut() {
  
  pushMatrix();
  
  float shortDist = 19.3;
  
  translate(183, 9.5);
  rotate(2.45);
  
  for (int i=0; i<shortCount; i++) {
     
      if (activeShort[i]) {
          drawCircle(nodeSize*1.1, color(255), i*shortDist, 0);
          drawCircle(nodeSize, onColor, i*shortDist, 0); 
      } else {
          drawCircle(nodeSize, offColor, i*shortDist, 0); 
      }
     
  }
  
  popMatrix();
 
}
