import java.util.Iterator;
/* --------Inputs-------- */
// Clic - Resets positions
// R - Repell
// A - Attract
// T - Tremble
// W - Wave
// E - Inner circle motion
// C - Circular motion 
// L - Outer circle motion
// F - Fall
// I - Invert (Inverts flow and effects)
// S - Stops spiral effect

//AMDO: what language is this??
ArrayList<BG_Particle> particles = new ArrayList<BG_Particle>();
int particleNum = 100;
 
float magnetRadius = 100;
float rippleRadius = 0;
float equatorRadius = 400;
float domeRadius = 960;

float noiseOndulation = 200;
float noiseVariation = 1000;
float noiseInterval = 250;
float noiseResistance = 1000;

int maxTrembleTime = 20;
int particleSpiral = 0;
int particleColorHue = 260;
float rippling_x;
float rippling_y;

Boolean ripple = false;
Boolean vortex = false;
Boolean inverted = false;
Boolean falling = false;
Boolean rotating = false;
Boolean innerCircle = false;
Boolean outerCircle = false;
Boolean initializing = false;

ArrayList<PVector> emitters = new ArrayList<PVector>();

//AM: I think each sketch calls this once on init..
//void setup() {
//  //size(800, 800);
//  fullScreen();
  
//  for(int i=0; i<particleNum; i++) {
//    //particles.add(new BG_Particle(domeRadius * cos(0) + width/2, domeRadius * sin(0) + height/2, random(0.5, 2), random(0.05, 0.1), i));
//    particles.add(new BG_Particle(domeRadius * cos(0) + width/2, domeRadius * sin(0) + height/2, random(3, 6), random(0.1, 0.2), i));
//  }
//  colorMode(HSB, 360, 100, 100);
  
//  for (BG_Particle p : particles) {
//    falling = false;
//    p.stopped = false;
//    p.pos.x = random(width);
//    p.pos.y = random(height);
//  }
//}

////AM: called many times per second...
//void draw() {
  
//  /* --------Single particle-------- */
//  //background(0);
//  /* --------Tracing-------- */
//  fill(0);
//  rect(0,0,width,height);
  
//  for(PVector e : emitters) {
//    particles.add(new BG_Particle(e.x, e.y, random(2, 5), random(0.1, 0.5), frameCount));
//  }
  
//  Iterator<BG_Particle> iter = particles.iterator();
//  while (iter.hasNext()) {
//      BG_Particle p = iter.next();
//      if(p.attracting || p.repelling) p.magnet(width/2, height/2, domeRadius, 10000);
//      if(p.flowing) p.flow();
//      if(p.trembling) p.tremble();
//      if(falling) p.fall();
      
//      if(initializing && particleSpiral > particleNum - 10) {
//        initializing = false;
//        p.flowing = true;
//      } 
      
//      if(millis()%((p.index*5)+1)==0 && !p.start) {
//        p.start = true;
//      }
      
//      if(outerCircle) {
//        p.flowing = false;
//        p.repelling = true;
//        p.magnet(width/2, height/2, equatorRadius, 100);
//        p.circleRotation(equatorRadius);  
//      } else {
//        p.flowing = true;
//      }
  
//      if(rotating) {
//        p.flowing = false;
//        p.circleRotation(p.distanceFromCenter);
//      } else {
//        p.flowing = true;
//      }
      
//      if(ripple) {
//        p.ripple();
//      } else {
//        p.rippling = false;
//        p.ripplingSize = 0;
//      }
      
//      if(innerCircle) {
//        p.flowing = false;
//        p.circleRotation(equatorRadius);
//      }
      
//      if(initializing) {
//        //p.emit();
//        p.run();
//        initializing = false;
//      }
      
//      if (dist(p.pos.x,p.pos.y,width/2,height/2) < 10) {
//        iter.remove();
//      }
//      p.run();
//  } 
 
//  if(ripple) {
//    rippleRadius += 5;
//    if(rippleRadius > domeRadius) ripple = false;
//  }
//}

//AMDO: where is event registered?
void mousePressed() {
  for (BG_Particle p : particles) {
    falling = false;
    p.stopped = false;
    p.pos.x = random(width);
    p.pos.y = random(height);
  }
}

void keyPressed() {
  if(key == 'R' || key == 'r') {
    for(BG_Particle p : particles) {
      p.attracting = false;
      p.repelling = !p.repelling;
      if(!p.repelling) p.flowing = true;
    }
  }
  
  if(key == 'a' || key == 'A') {
    for(BG_Particle p : particles) {
      p.repelling = false;
      p.attracting = !p.attracting;
      if(!p.attracting) p.flowing = true;
    }
  }
  
  if(key == 't' || key == 'T') {
    for(BG_Particle p : particles) {
      p.trembling = true;
    }
  }  
  
  if(key == 'i' || key == 'I') {
    inverted = !inverted;
  }
    
  if(key == 'f' || key == 'F') {
    falling = !falling;
    for(BG_Particle p : particles) {
      if(!falling) {
        p.stopped = false; 
        p.repelling = false;
      }
    }
  } 
  
  if(key == 'w' || key == 'W') {
    ripple = true;
    rippleRadius = 10;
  } 
  
  if(key == 'l' || key == 'L') {
    outerCircle = !outerCircle;
    if(!outerCircle) {
      for(BG_Particle p : particles) {
        p.repelling = false;
        p.flowing = true;
      }
    }
  } 
  
  if(key == 'C' || key == 'c') {
    rotating = !rotating;
    if(rotating) {
      for(BG_Particle p : particles) {
        p.distanceFromCenter = dist(width/2, height/2, p.pos.x, p.pos.y);
        p.angle = atan2(p.pos.y - height/2, p.pos.x - width/2);
        p.angleIncrement = random(0.005, 0.05);
      }
    }
  }
  
  if(key == 'e' || key == 'E') {
    innerCircle = !innerCircle;
    if(innerCircle) {
      for(BG_Particle p : particles) {
        p.angle = atan2(p.pos.y - height/2, p.pos.x - width/2);
      }
    }
  } 
  
  if(key == 's' || key == 'S') {
    initializing = false;
    for(BG_Particle p : particles) {
      p.flowing = true;
    }
  } 
  
  if(key == 'v' || key == 'V') {
    vortex = !vortex;
    if(vortex) {
        for(BG_Particle p : particles) {
        p.angle = random(0,628) * 0.1;
        p.vortexCenter = new PVector(mouseX, mouseY);
      }
    }
  }
  
  if(key == 'p' || key == 'P') {
    for(int i = 0; i< 500; i++) {
      BG_Particle p = new BG_Particle(100, 100, random(3, 6), random(0.1, 0.2), 10);
      p.applyForce(PVector.sub(new PVector(random(width), random(height)),p.pos));
      particles.add(p);
    }
  }
}
void createBG_Particle() {
   for(int i = 0; i< 100; i++) {
      BG_Particle p = new BG_Particle(x, y, random(3, 6), random(0.1, 0.2), 10);
      p.applyForce(PVector.sub(new PVector(random(width), random(height)),p.pos));
      particles.add(p);
    }
    ripple = true;
    rippleRadius = 10;
    rippling_x = x;
    rippling_y = y;
    //System.out.println("size : " + particles.size());
}

class BG_Particle {
  
  PVector pos;
  PVector vel;
  PVector acc;
  float size;
  float maxforce;   
  float maxspeed;
  float angle;
  float angleIncrement;
  
  Boolean flowing = true;
  Boolean repelling = false;
  Boolean attracting = true;
  Boolean stopped = false;
  Boolean rippling = false;
  Boolean trembling = false;
  Boolean spiralling = true;
  Boolean start = false;
  Boolean inVortex = false;
  
  float ripplingSize = 0;
  float distanceFromCenter = 0;
  float startDistance = domeRadius;
  int trembleTime = 0;
  int index;
  
  PVector previous = new PVector();
  PVector vortexCenter;
  float radius = random(50, 200);
  float dec = (200 - radius) * 0.000014;
  //float tilt = random(-60,60);
  float turnVelocity;
  

  BG_Particle (float _x, float _y, float _maxspeed, float _maxforce, int _index) {
    pos = new PVector(_x, _y);
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    size = 5;
    angle = 0;
    angleIncrement = random(0.005, 0.05);
    maxforce = _maxforce;
    maxspeed = _maxspeed;
    index = _index;
  }
  
   /**
   * Calculates the noise angle in a given position
   * @param      _x      Current position on the x axis
   * @param      _y      Current position on the y axis
   * @return     Float   Noise angle
   */
  float getNoiseAngle(float _x, float _y) {
    return map(noise(_x/noiseOndulation + noiseVariation, _y/noiseOndulation + noiseVariation, frameCount/noiseInterval + noiseVariation), 0, 1, 0, TWO_PI*2);
  }
  
   /**
   * Sets acceleration to follow the noise flow
   */  
  void flow() {
    float noiseAngle = getNoiseAngle(pos.x, pos.y) + random(PI);
    //float noiseAngle = random(TWO_PI);
    PVector desired = new PVector(cos(noiseAngle)*noiseResistance, sin(noiseAngle)*noiseResistance);
    desired.mult(maxspeed*0.1);
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxforce); 
    applyForce(steer);  
  }
 

   /**
   * Rotates the particle from a given radius
   * @param      _radius    Distance from the center to rotate from
   */
  void circleRotation(float _radius) {
    angle += angleIncrement;
    if(angle >= TWO_PI) angle = 0;
    PVector target = new PVector(width/2 + (_radius * cos(angle)), height/2 + (_radius * sin(angle)));
    PVector desired = PVector.sub(target, pos);
    follow(desired);
  }

   /**
   * Sets a random velocity in three intervals to simulate a trembling effect
   */
  void tremble() {
    flowing = false;
    PVector variation = new PVector(random(-1,1), random(-1,1));
    vel.add(variation);
    if(trembleTime > maxTrembleTime/3) vel.add(variation);
    if(trembleTime > 2*(maxTrembleTime/3)) vel.add(variation);  
    
    trembleTime++;
    if(trembleTime > maxTrembleTime) { 
      trembleTime = 0;
      trembling = false;
      flowing = true;
    }
  }
  
  void vortex(float turn) {
    PVector current = new PVector(radius * cos(angle), /*tilt + 20 **/ cos(angle + 3.5), radius * sin(angle));
    if (turn != 0) turnVelocity = turn * (201-radius);
    angle -= dec + turnVelocity;
    turnVelocity *= 0.95;
    
    if (previous.x == 0) {
      previous.set(current);
    }

    isoLine(current,previous,angle);
    previous.set(current);
  }
  
  void isoLine(PVector begin, PVector end, float angle) {
    PVector newBegin = new PVector((begin.x - begin.z), ((begin.x + begin.z)/2 - begin.y));
    PVector newEnd = new PVector((end.x - end.z), ((end.x + end.z)/2 - end.y));
    borders();
    stroke(255);
    pushMatrix();
    translate(vortexCenter.x, vortexCenter.y);
    strokeWeight(2);
    line (newBegin.x, newBegin.y, newEnd.x, newEnd.y);
    //ellipse(newBegin.x, newBegin.y, 2, 2);
    popMatrix();
  }

   /**
   * Maps the particle size according to the distance between its position and the ripple radius
   */
  void ripple() {
    float distance = abs(dist(pos.x, pos.y, rippling_x, rippling_y) - rippleRadius);
    
    if (distance < 50) { 
      rippling = true;
      ripplingSize = map(distance, 50, 0, 0, 7);
      repelling = true;
      //magnet(rippling_x, rippling_y, rippleRadius + 25, 10);
    } else {
      rippling = false;
      repelling = false;
    }   
  }

   /**
   * Sets the particle acceleration to follow a desired direction
   * @param      _desired    Vector to follow
   */
  void follow(PVector _desired) {
    _desired.normalize();
    _desired.mult(maxspeed);
    PVector steer = PVector.sub(_desired, vel);
    steer.limit(maxforce); 
    applyForce(steer);  
  }

   /**
   * Spiral effect from the borders to the top of the dome 
   */  
  void spiral() {    
    if(start && spiralling) {
      angle += 0.03;
      startDistance -= 0.3;
      if(angle >= TWO_PI) angle = 0;
      pos.x = startDistance * cos(angle) + width/2;
      pos.y = startDistance * sin(angle) + height/2;
      
      if(spiralling && startDistance < 10) {
        spiralling = false;
        particleSpiral++;
      }
    }
  }

   /**
   * BG_Particle falls to the closest border of the dome to end the sequence
   */
  void fall() {
    flowing = false;
    repelling = true;
    attracting = false;
    inverted = false;
    
    magnet(width/2, height/2, domeRadius, 1500);
  }
  
   /**
   * Repels or attracts the particles within a distance
   * @param      _x           X coordinate of the magnet center
   * @param      _y           Y coordinate of the magnet center
   * @param      _radius      Distance affected by the magnet effect
   * @param      _strength    Strength of the magnet force
   */
  void magnet(float _x, float _y, float _radius, float _strength) {
    float magnetRadius = _radius;
    PVector target = new PVector(_x, _y);
    PVector force = PVector.sub(target, pos);
    float distance = force.mag();

    if(distance < magnetRadius) {
      flowing = true;
      //distance = constrain(distance, 5.0, 25.0);
      force.normalize();
      float strength = 0.00;
      if(repelling) strength = (500 + _strength) / (distance * distance * -1);
      if(attracting) strength = (50 + _strength) / (distance * distance);
      force.mult(strength);        
      applyForce(force);
    } else {
      flowing = true;
    }
  }

   /**
   * Adds a vector to the current acceleration
   * @param      _force    Vector to add 
   */
  void applyForce(PVector _force) {
    acc.add(_force);
  }

   /**
   * Updates the acceleration, velocity and position vectors
   */
  void update() {
    if(!stopped) {
      if(inverted) acc.mult(-1);
      vel.add(acc);
      vel.limit(maxspeed);
      pos.add(vel);
      acc.mult(0);  
    }
  }

   /**
   * Displays the particle on the canvas
   */
  void display() {
    pushStyle();
    /* --------Color fill-------- */   
    //fill(map(pos.x, 0, width, particleColorHue, h_end), 100, 100, 30);
    fill(((int)map(pos.x, 0, width, particleColorHue, particleColorHue+110))%359, 100, 100, 20);
    
    /* --------White fill-------- */
    //fill(#ffffff);
     
    noStroke();
    ellipse(pos.x, pos.y, size+ripplingSize, size+ripplingSize);    
    popStyle();
  }

   /**
   * Recursive function that sets a random position to the particle within the dome area
   */
  void position() {
    pos.x = width/2 - ((domeRadius - 15) * cos(random(TWO_PI)));
    pos.y = height/2 - ((domeRadius - 15) * sin(random(TWO_PI)));
    
    float distance = dist(pos.x, pos.y, width/2, height/2);
    if (distance > domeRadius) position();
  }

   /**
   * Checks whether the particle is going out of bound and sets its position to the opposte side of the dome
   */
  //void borders() {
  //  float distance = dist(pos.x, pos.y, width/2, height/2);    
  //  if (distance > domeRadius) {
  //    if(falling) {
  //      stopped = true;
  //    } else {
  //      /* --------Warp particles to a random location-------- */
  //      //position();
        
  //      /* --------Warp particles to opposite side-------- */
  //      float theta = atan2(pos.y - height/2, pos.x - width/2);
  //      pos.x = (width/2 + (domeRadius * cos(theta + PI)));
  //      pos.y = (height/2 + (domeRadius * sin(theta + PI)));       
  //    }
  //  }
  //}
  void borders() {
    if(pos.x > width) pos.x = 0;
    else if(pos.x < 0) pos.x = width;
    if(pos.y > height) pos.y = 0;
    else if(pos.y < 0) pos.y = height;
  }
  
  /**
  * Calls the functions that run every frame
  */  
  void run() {
    update();
    borders();
    display();
  }
}
