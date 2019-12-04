SoundFile bgm;
SoundFile soundEffect;

void playSoundEffect() {
  //// Map mouseX from 0.25 to 4.0 for playback rate. 1 equals original playback 
  //// speed 2 is an octave up 0.5 is an octave down.
  //soundfile.rate(map(mouseX, 0, width, 0.25, 4.0)); 
  
  //// Map mouseY from 0.2 to 1.0 for amplitude  
  //soundfile.amp(map(mouseY, 0, width, 0.2, 1.0)); 
 
  //// Map mouseY from -1.0 to 1.0 for left to right 
  //soundfile.pan(map(mouseY, 0, width, -1.0, 1.0));
  soundEffect.play();
  soundEffect.amp(0.6);
  soundEffect.rate(map(y,0,height,0.5,1.5));
  soundEffect.pan(map(x,0,width,-1.0,1.0));
}
