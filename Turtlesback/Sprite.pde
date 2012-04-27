/***
 * This is a basic sprite class that employes the sprite sheet handler class to create the sprites.
 * Holds the frames, position, size information
 ***/

class Sprite {  
  //Variable Declarations
  float sizeX, sizeY;
  float positionX, positionY;
  
  PImage[] frames;  
  int numFrames; 
  
  boolean visible;
  
  /***
   * Constructor for multi frame sprite
   * Required:
   * PImage[] - Array of PImages (frames)
   * Int      - Number of frames
   * Float    - X Position
   * Float    - Y Position
   * Boolean  - Visiblity (true|false) 
   ***/
  Sprite(PImage[] _frames, int _framesCount, float _posX, float _posY, boolean _visible){ 
    
    setSprites(_frames, _framesCount);
    
    positionX = _posX;
    positionY = _posY;

    visible = _visible;
  }
  
  /***
   * Constructor for single frame sprite
   * Required:
   * PImage  - Single frame
   * Float   - X Position
   * Float   - Y Position
   * Boolean - Visiblity (true|false) 
   ***/
  Sprite(PImage frame, float _posX, float _posY, boolean _visible){ 
    
    setSprites(new PImage[]{frame}, 1);
    
    positionX = _posX;
    positionY = _posY;

    visible = _visible;
  }
  
  /***
   * Returns a deep copy of the sprite
   ***/
  Sprite clone() {
    return new Sprite(frames,numFrames, positionX, positionY, visible);
  }
  
  /***
   * Allows the changing of the set of sprites to those created from another sprite sheet
   * Required:
   * PImage[] - Array of frames
   * Int      - The number of frames (not really neccissary, could just call length on the array...)
   ***/
  void setSprites(PImage[] _frames, int _framesCount){
    frames = _frames;
    sizeX = _frames[0].width;
    sizeY = _frames[0].height;
    numFrames = _framesCount;
  }

  /**
   * duplicate frames in reverse
   */
  void forcePingPong() {
    int len = frames.length;
    PImage[] nframes = new PImage[len*2];
    for(int i=0; i<len; i++) {
      nframes[i] = frames[i];
      nframes[(2*len-1)-i] = frames[i]; }
    setSprites(nframes,nframes.length);
  }

  /***
   * Draws the sprite to the PApplet
   ***/
  void draw(){
    if(visible){
          image(frames[frameCount%numFrames], positionX, positionY);
    }
    
    if(gDebug.getStatus()){
      fill(#000000);
      ellipse((int)positionX,(int)positionY, 5, 5);
    }
  }  
  
  /***
   * Returns the current frame number
   ***/
  int getFrame(){
    return frameCount%numFrames;
  }
  
  /***
   * Returns the current frame
   ***/
  PImage getImage(){
    return frames[frameCount%numFrames];
  }
  
  /***
   * Returns the number of frames
   ***/
  int size() {
    return frames.length;
  }
}
