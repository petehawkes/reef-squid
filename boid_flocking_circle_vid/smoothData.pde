


int smoothMotion(int input) {

  for (int i=motion.length-1; i>0 ;i--) {
    motion[i] = motion[i-1];
  }
  motion[0] = input;

  int total = 0;
  for (int i=0; i<motion.length; i++) {
    total += motion[i];
  }

  return int(total/motion.length);
}


int smoothThreshold(int input) {

  for (int i=motionThreshold.length-1; i>0 ;i--) {
    motionThreshold[i] = motionThreshold[i-1];
  }
  motionThreshold[0] = input;

  int total = 0;
  for (int i=0; i<motionThreshold.length; i++) {
    total += motionThreshold[i];
  }

  return int(total/motionThreshold.length);
}


