import processing.sound.*;
import java.util.ArrayList;
import com.onformative.leap.*;
import com.leapmotion.leap.Finger;
import java.util.Queue;
import java.util.LinkedList;
import java.util.Iterator;
import java.util.Deque;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint2D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle2D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftBall2D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftBody2D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftGrid2D;
import com.thomasdiewald.pixelflow.java.utils.DwStrokeStyle;

import processing.core.*;

int viewport_w = 1920;
int viewport_h = 1080;
int viewport_x = 0;
int viewport_y = 0;

int gui_w = 200;
int gui_x = 20;
int gui_y = 20;


// physics parameters
DwPhysics.Param param_physics = new DwPhysics.Param();

// physics simulation
DwPhysics<DwParticle2D> physics;

// list, that wills store the cloths
ArrayList<DwSoftBody2D> softbodies;
Queue<DwSoftBody2D> test;

// 0 ... default: particles, spring
// 1 ... tension
int DISPLAY_MODE = 1;

// entities to display
boolean DISPLAY_PARTICLES      = true;
boolean DISPLAY_SPRINGS_STRUCT = true;
boolean DISPLAY_SPRINGS_SHEAR  = true;
boolean DISPLAY_SPRINGS_BEND   = true;


// first thing to do, inside draw()
boolean NEED_REBUILD = true;

int nodex_x, nodes_y, nodes_r;
float nodes_start_x, nodes_start_y;

DwSpringConstraint.Param param_spring_cloth;
DwSpringConstraint.Param param_spring_softbody;
DwSpringConstraint.Param param_spring_chain;
DwSpringConstraint.Param param_spring_circle;
  
LeapMotionP5 leap;
particleSystem ps;
particleSystem[] psArr;

Deque<particleSystem> psQueue;
boolean once;
int cnt, progress, shape, color_offset, psLimit;
float x,y,z;
color[] colors;
float angle, size;
PImage bg;
DwParticle.Param param_particle = new DwParticle.Param();

//public void settings(){
//  size(3000,1280, P2D);
//  smooth(8);
//}
  
void setup() {
  fullScreen(P2D);
  //size(2560,1080);
  smooth();
  colorMode(HSB, 360, 100, 100, 100);
  
  // [set variables]
  ps = new particleSystem();
  psQueue = new LinkedList<particleSystem>();
  leap = new LeapMotionP5(this);
  once = false;
  cnt = progress = color_offset = 0;
  colors = new color[5];
  z = 10000;
  size = 100;
  psLimit = 25;
  psArr = new particleSystem[psLimit];
  fill(50,50,50); 
  surface.setLocation(viewport_x, viewport_y);
  textSize(26);
  
  bg = loadImage("bg.png");
  
  // main library context
  DwPixelFlow context = new DwPixelFlow(this);
  context.print();
  context.printGL();
  
  physics = new DwPhysics<DwParticle2D>(param_physics);
  
  // global physics parameters
  param_physics.GRAVITY = new float[]{ 0, 0f };
  param_physics.bounds  = new float[]{ 0, 0, width, height };
  param_physics.iterations_collisions = 8;
  param_physics.iterations_springs    = 8;
  
  frameRate(60);
  initBodies(); //initialize PixelFlow objects
  
  //initialize BG particles
  for(int i=0; i<particleNum; i++) {
    //particles.add(new BG_Particle(domeRadius * cos(0) + width/2, domeRadius * sin(0) + height/2, random(0.5, 2), random(0.05, 0.1), i));
    particles.add(new BG_Particle(domeRadius * cos(0) + width/2, domeRadius * sin(0) + height/2, random(3, 6), random(0.1, 0.2), i));
  }
  for (BG_Particle p : particles) {
    falling = false;
    p.stopped = false;
    p.pos.x = random(width);
    p.pos.y = random(height);
  }
  
  //BGM
  bgm = new SoundFile(this, "Other Side Of The Universe SOUND Effect.mp3");
  bgm.play();
  bgm.stop();
  bgm.loop();
  
  //Sound Effect
  soundEffect = new SoundFile(this, "BASS BOOMBASS DROP COD SNIPER SHOT SOUND EFFECT_2.mp3");
}

void draw() {
  //background(0, 0, 0);
  
  image(bg, 0, 0);
  
  Iterator<BG_Particle> iter = particles.iterator();
  while (iter.hasNext()) {
      BG_Particle p = iter.next();
      if(p.attracting || p.repelling) p.magnet(width/2, height/2, domeRadius, 10000);
      if(p.flowing) p.flow();
      if(p.trembling) p.tremble();
      if(falling) p.fall();
      
      if(initializing && particleSpiral > particleNum - 10) {
        initializing = false;
        p.flowing = true;
      } 
      
      if(millis()%((p.index*5)+1)==0 && !p.start) {
        p.start = true;
      }
      
      if(outerCircle) {
        p.flowing = false;
        p.repelling = true;
        p.magnet(width/2, height/2, equatorRadius, 100);
        p.circleRotation(equatorRadius);  
      } else {
        p.flowing = true;
      }
  
      if(rotating) {
        p.flowing = false;
        p.circleRotation(p.distanceFromCenter);
      } else {
        p.flowing = true;
      }
      
      if(ripple) {
        p.ripple();
      } else {
        p.rippling = false;
        p.ripplingSize = 0;
      }
      
      if(innerCircle) {
        p.flowing = false;
        p.circleRotation(equatorRadius);
      }
      
      if(initializing) {
        //p.emit();
        p.run();
        initializing = false;
      }
      
      if (dist(p.pos.x,p.pos.y,width/2,height/2) < 10) {
        iter.remove();
      }
      p.run();
  } 
  particleColorHue = (particleColorHue+1) % 359; 
  if(ripple) {
    rippleRadius += 5;
    if(rippleRadius > sqrt(width*width+height*height)) ripple = false;
  }
  drawGradient();  
  updateMouseInteractions();    
  
  // update physics simulation
  physics.update(1);
  
  getFingerPos(); // get the location x,y,z of finger 
  
  if(z < 50 && !once && progress == 8) {
    createBG_Particle();
    createParticleSystem();
    spawnParticle();
    playSoundEffect();
    if(cnt >= psLimit) psQueue.poll();
    cnt++;//limit 15
    once = true;
    //System.out.println(physics.getParticlesCount());
  }
  
  if(z > 500 && once) {
    unMovable();
  }
  if(z > 1000) {
    once = false;
    progress = 0;
  }
  if(progress == 0 && z < 900) colors[0] = getHSB();
  else if(progress == 1 && z < 800) { color c = getHSB(); colors[1] = color(hue(colors[0]), saturation(c), brightness(c)); }
  else if(progress == 2 && z < 700) angle = getAngle();
  else if(progress == 3 && z < 600) { color c = getHSB(); colors[2] = color(hue(colors[0]), saturation(c), brightness(c)); }
  else if(progress == 4 && z < 500) { color c = getHSB(); colors[3] = color(hue(colors[0]), saturation(c), brightness(c)); }
  else if(progress == 5 && z < 400) shape = getShape(); 
  else if(progress == 6 && z < 300) { color c = getHSB(); colors[4] = color(hue(colors[0]), saturation(c), brightness(c)); }
  else if(progress == 7 && z < 200) size = getSize();
  
  
  for(particleSystem ps : psQueue) {
    ps.draw();    
  }
  color_offset = color_offset + 1 > 359 ? 0 : color_offset + 1;
  
  // 1) particles rendering
  //if(DISPLAY_PARTICLES && cnt < 15){
  //  for(DwSoftBody2D body : softbodies){
  //    body.displayParticles(this.g);
  //    body.shade_springs_by_tension = (DISPLAY_MODE == 1);
  //    body.displaySprings(this.g, new DwStrokeStyle(color(255,  90,  30), 0.3f), DwSpringConstraint.TYPE.BEND);
  //    body.displaySprings(this.g, new DwStrokeStyle(color( 70, 140, 255), 0.6f), DwSpringConstraint.TYPE.SHEAR);
  //    body.displaySprings(this.g, new DwStrokeStyle(color(  0,   0,   0), 1.0f), DwSpringConstraint.TYPE.STRUCT);
  //  }
  //  for(DwSoftBody2D body : test){
  //    body.displayParticles(this.g);
  //    body.shade_springs_by_tension = (DISPLAY_MODE == 1);
  //    body.displaySprings(this.g, new DwStrokeStyle(color(255,  90,  30), 0.3f), DwSpringConstraint.TYPE.BEND);
  //    body.displaySprings(this.g, new DwStrokeStyle(color( 70, 140, 255), 0.6f), DwSpringConstraint.TYPE.SHEAR);
  //    body.displaySprings(this.g, new DwStrokeStyle(color(  0,   0,   0), 1.0f), DwSpringConstraint.TYPE.STRUCT);
  //  }
  //}
  //else {
  //  for(int i=softbodies.size()-15; i<softbodies.size(); i++) {
  //    softbodies.get(i).displayParticles(this.g);
  //    softbodies.get(i).shade_springs_by_tension = (DISPLAY_MODE == 1);
  //    softbodies.get(i).displaySprings(this.g, new DwStrokeStyle(color(255,  90,  30), 0.3f), DwSpringConstraint.TYPE.BEND);
  //    softbodies.get(i).displaySprings(this.g, new DwStrokeStyle(color( 70, 140, 255), 0.6f), DwSpringConstraint.TYPE.SHEAR);
  //    softbodies.get(i).displaySprings(this.g, new DwStrokeStyle(color(  0,   0,   0), 1.0f), DwSpringConstraint.TYPE.STRUCT);
  //  }
  //}
  
  // interaction stuff
  if(DELETE_SPRINGS) {
    fill(255,64);
    stroke(0);
    strokeWeight(1);
    ellipse(x, y, DELETE_RADIUS*2, DELETE_RADIUS*2);
  }
}

public void initBodies(){ 
    physics.reset();
    
    softbodies = new ArrayList<DwSoftBody2D>();
    test = new LinkedList<DwSoftBody2D>();
  
    // spring parameters: different spring behavior for different bodies
    param_spring_cloth    = new DwSpringConstraint.Param();
    param_spring_softbody = new DwSpringConstraint.Param();
    param_spring_chain    = new DwSpringConstraint.Param();
    param_spring_circle   = new DwSpringConstraint.Param();
    
    // particle parameters
    param_particle.DAMP_BOUNDS     = 0.40f;
    param_particle.DAMP_COLLISION  = 0.9990f;
    param_particle.DAMP_VELOCITY   = 0.991f; 
    
    // spring parameters
    param_spring_cloth   .damp_dec = 0.999999f;
    param_spring_cloth   .damp_inc = 0.000599f;
    
    param_spring_softbody.damp_dec = 0.999999f;
    param_spring_softbody.damp_inc = 0.999999f;
    
    param_spring_chain   .damp_dec = 0.699999f;
    param_spring_chain   .damp_inc = 0.00099999f;
    
    param_spring_circle  .damp_dec = 0.999999f;
    param_spring_circle  .damp_inc = 0.999999f;
}

void getFingerPos() {
  for (Finger finger : leap.getFingerList()) {
    PVector fingerPos = leap.getTip(finger);
    ellipse(fingerPos.x, fingerPos.y, 10, 10);
    //println("z : ", fingerPos.z);
    if (fingerPos.z < z) {
      x = fingerPos.x;
      y = fingerPos.y;
      z = fingerPos.z;
    }
    else
      z = fingerPos.z;
  }  
}

color getHSB() {
  progress++;
  float h = x*10 % 360;
  float s = y*10 % 100;
  float b = (x+y)*10 % 100 + 15;
  return color(h,s,b);
}

float getAngle() {
  progress++;
  return x*y*10 % 5 + 1;
}

int getShape() {
  progress++;
  return (int)((x+y)*10 % 91);
}

float getSize() {
  progress++;
  return (x+y)*10 % 50 + 50;
}

void drawGradient() {
  noStroke();
  for(int i=100;i>0;i-=1){
    float opacity = 200/((i+0.1)*(i+0.1)) + random(0.1);
    fill(0, 0, 50, opacity);
    ellipse(width/2,height/2,i,i);
  }
}

void createParticleSystem() {
  particleSystem tmp = new particleSystem();
  tmp.launch();
  tmp.idx = cnt%psLimit;
  psQueue.offer(tmp);  
}
/*////////////////////////////////////////////////////////////////////////////////////////////////////
                          Particle Class
/////////////////////////////////////////////////////////////////////////////////////////////////////*/
class particle {
  float t,x,v,a;
  float pAngle;
  int pShape;
  float startTime;
  boolean start = false;
  color c;
  particle(float st, color col) {
    this.t = 0;
    this.x = 0;
    this.v = map(size,50f,100f,3f,6f);
    this.a = map(size,50f,100f,0.04f,0.08f);
    this.startTime = st;
    this.c = col;
    this.pAngle = angle;
    this.pShape = shape < 35 ? shape%2 : shape;
  }
  void draw(float X, float Y) {             
    if (!start && startTime < t) {
      start = true;
      t = v/2/a;
    }
    if (start) { // (v/2a)
      if (t > v/a)
        t = 0;
      for(int i = 0; i < 12; i++) {
        pushMatrix();
        noStroke();
        translate(X, Y);                      // set the center point
        rotate(radians(t*pAngle)+PI/6.0*i);   // set the angle of each particles
        x = (v-a*t)*t;                        // set the distance of particles from center == x
        fill(color(hue(c)+color_offset  > 359 ? hue(c)+color_offset-360 : hue(c)+color_offset,
          saturation(c),brightness(c)),map(x,0,v*v/4/a,30,100)); // set the color of particles 
        //rect(x, 0, x*0.2, x*0.2);
        if(pShape >= 35) {                    // set the shape of particles
          textSize(x*0.3+0.1);
          text(char(pShape), x, 0);           // char 35~90
        }
        else if(pShape == 0)
          rect(x, 0, x*0.2, x*0.2);
        else
          ellipse(x, 0, x*0.2, x*0.2);   
        popMatrix();
      }  
    }
    t += 0.3;   
  }
}

class particleSystem {
  ArrayList<particle> pList = new ArrayList<particle>();
  float X;
  float Y;
  boolean launch;
  int idx;
  particleSystem() {
    this.launch = false;  
  }
  void launch() {
    X = x;
    Y = y;
    idx = 0;
    pList.clear();
    pList.add(new particle(0, colors[0]));
    pList.add(new particle(4, colors[1]));
    pList.add(new particle(8, colors[2]));
    pList.add(new particle(12, colors[3]));
    pList.add(new particle(16, colors[4]));
    launch = true;
  }
  void draw() {
    if(launch) {
      X = (physics.getParticles()[idx*29].x() + physics.getParticles()[idx*29+14].x()) / 2;
      Y = (physics.getParticles()[idx*29].y() + physics.getParticles()[idx*29+14].y()) / 2;
      for(particle p : pList) {
       p.draw(X, Y);
      }        
    }
    else {
     // ?
    }
  }
}

/*/////////////////////////////////////////////////////////////////////////////
                          User Interaction
///////////////////////////////////////////////////////////////////////////////*/
 
  DwParticle particle_mouse = null;
  
  public DwParticle findNearestParticle(float mx, float my){
    return findNearestParticle(mx, my, Float.MAX_VALUE);
  }
  
  public DwParticle findNearestParticle(float mx, float my, float search_radius){
    float dd_min_sq = search_radius * search_radius;
    DwParticle2D[] particles = physics.getParticles();
    DwParticle particle = null;
    for(int i = 0; i < particles.length; i++){
      float dx = mx - particles[i].cx;
      float dy = my - particles[i].cy;
      float dd_sq =  dx*dx + dy*dy;
      if( dd_sq < dd_min_sq){
        dd_min_sq = dd_sq;
        particle = particles[i];
      }
    }
    return particle;
  }
  
  public ArrayList<DwParticle> findParticlesWithinRadius(float mx, float my, float search_radius){
    float dd_min_sq = search_radius * search_radius;
    DwParticle2D[] particles = physics.getParticles();
    ArrayList<DwParticle> list = new ArrayList<DwParticle>();
    for(int i = 0; i < particles.length; i++){
      float dx = mx - particles[i].cx;
      float dy = my - particles[i].cy;
      float dd_sq =  dx*dx + dy*dy;
      if(dd_sq < dd_min_sq){
        list.add(particles[i]);
      }
    }
    return list;
  }
  
  
  public void updateMouseInteractions(){
    // deleting springs/constraints between particles
    if(DELETE_SPRINGS){
      ArrayList<DwParticle> list = findParticlesWithinRadius(x, y, DELETE_RADIUS);
      for(DwParticle tmp : list){
        tmp.enableAllSprings(false);
        tmp.collision_group = physics.getNewCollisionGroupId();
        tmp.rad_collision = tmp.rad;
      }
    } else {
      if(particle_mouse != null){
        float[] mouse = {x, y};
        particle_mouse.moveTo(mouse, 0.2f);
      }
    }
  }
  
  
  boolean DELETE_SPRINGS = false;
  float   DELETE_RADIUS  = 20;

  public void spawnParticle(){
    {
      nodes_r = 15;
      nodes_start_y = height-250; 
      DwSoftBall2D body = new DwSoftBall2D();
      body.CREATE_BEND_SPRINGS  = false;
      body.CREATE_SHEAR_SPRINGS = false;
      body.bend_spring_mode = 1;
      body.bend_spring_dist = 5;
      body.setParam(param_particle);
      body.setParam(param_spring_circle);
      body.create(physics, x, y, size, nodes_r, cnt);
      body.setParticleColor(color(0,160));
      body.createShapeParticles(this);
      softbodies.add(body);
    }
    if(!DELETE_SPRINGS){
      particle_mouse = findNearestParticle(x, y, 100);
      if(particle_mouse != null) particle_mouse.enable(false, false, false);
    }
  }
  
  public void unMovable(){
    if(particle_mouse != null && !DELETE_SPRINGS){
      particle_mouse.enable(true, true,  true );
      particle_mouse = null;
    }
    //if(mouseButton == RIGHT ) DELETE_SPRINGS = false;
  }
