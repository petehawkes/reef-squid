// The Boid class

class Boid {

  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float maxspeedMod;  // mod for max speed
  float currentMaxspeed;
  boolean atEase = true;
  PVector homeVector;
  float timeStamp; // time stamp for each boid
  color myColor;
  float colorTrans = 30;

  Boid(PVector l, float ms, float mf, PVector home) {
    acc = new PVector(0,0);
    vel = new PVector(random(-1,1),random(-1,1));
    loc = l.get();
    maxspeedMod = 1;
    maxspeed = ms;
    maxforce = mf;
    homeVector = home;
    myColor = squidColors[int(random(6))];
  }

  void run(ArrayList boids) {

    flock(boids);
    update();
    // borders();

    render();
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector home = findHome(boids);  // Home
    // Arbitrarily weight these forces
    if (atEase) {
      sep.mult(1.0);
      ali.mult(0.1);
      coh.mult(1.0);
      home.mult(0.0);
      r += (minBoidSize-r)*.3;
      colorTrans += (minBoidTrans-colorTrans) *.1;
    } 
    else {
      sep.mult(0.1);
      ali.mult(0.01);
      coh.mult(2.0);
      home.mult(20.0); 
      r += (maxBoidSize-r)*.3;
      colorTrans += (maxBoidTrans-colorTrans) *.1;
    }
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
    acc.add(home);
  }

  // Method to update location
  void update() {

    // Update velocity
    vel.add(acc);
    // Limit speed
    if (atEase) {
      if (maxspeedMod < 40) {
        maxspeedMod+=1; 
      }
    } 
    else {
      maxspeedMod = 1;
      if ( loc.dist(homeVector) < 10) {
        maxspeedMod=boidSpeedReducer; 
      }; 
    }

    vel.limit(maxspeed/maxspeedMod);
    loc.add(vel);
    // Reset accelertion to 0 each cycle
    acc.mult(0);

  }

  void seek(PVector target) {
    acc.add(steer(target,false));
  }

  void arrive(PVector target) {
    acc.add(steer(target,true));
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  PVector steer(PVector target, boolean slowdown) {
    PVector steer;  // The steering vector
    PVector desired = target.sub(target,loc);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0)) desired.mult(maxspeed*(d/100.0)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired,vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } 
    else {
      steer = new PVector(0,0);
    }
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading2D() + PI/2;
    fill(myColor,colorTrans-30);
    stroke(myColor, colorTrans);
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
    ellipse(0, 0, r, r);
    stroke(255, 200);
    popMatrix();
  }

  // Wraparound
  //  void borders() {
  //    if (loc.x < -r) loc.x = width+r;
  //    if (loc.y < -r) loc.y = height+r;
  //    if (loc.x > width+r) loc.x = -r;
  //    if (loc.y > height+r) loc.y = -r;
  //  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList boids) {
    float desiredseparation = 5.0;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = PVector.dist(loc,other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(loc,other.loc);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList boids) {
    float neighbordist = 25.0;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = PVector.dist(loc,other.loc);
      if ((d > 0) && (d < neighbordist)) {
        steer.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList boids) {
    float neighbordist = 25.0;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.loc); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      return steer(sum,false);  // Steer towards the location
    }
    return sum;
  }

  // Home
  // Calculate steering vector towards home
  PVector findHome (ArrayList boids) {
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(homeVector);
      if (d > 0) {
        sum.add(homeVector.get()); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      return steer(sum,false);  // Steer towards the location
    }
    return sum;
  }

}



