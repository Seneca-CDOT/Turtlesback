/***
 * Sprite Factory Class
 * This class is a helper that handles the sprite and various functions that
 * one would want to perform with it. Its features include automated movement
 * and handlers for roations, scaling, and flipping.
 *
 * This class extends the basic sprite class to provide the additional functionality.
 ***/
class SpriteFactory extends Sprite {

  //Variable declarations
  int xanchor, yanchor;
  float xOffset, yOffset;

  private boolean autoMovement, loopMovement, rotateSprite, flipSpriteVertical, flipSpriteHorizontal, scaleSprite, pause;

  float movementSpeed;
  private boolean _movementOver;

  private float destinationX, destinationY;
  private float originalX, originalY;

  private float imageScaleX, imageScaleY;
  private float imageRotate;

  private int frameNum = -1;

  /*--- Constructors ---*/
  /***
   * Constructor for single frame sprite.
   * Requires:
   * PImage  - Sprite Image
   * String  - Anchor for relative draw position on the X axis
   * String  - Anchor for relative draw position on the Y axis
   * Int     - Position on the X axis
   * Int     - Position on the Y axis
   ***/
  SpriteFactory(PImage sprite, String _xanchor, String _yanchor, float posX , float posY, boolean visible){
    super(sprite, posX, posY, visible);
    setCommon(_xanchor, _yanchor, posX, posY);
  }

  /***
   * Constructor for single frame sprite.
   * Requires:
   * PApplet - Pointer to the sketch
   * String  - Location of the sprite
   * String  - Anchor for relative draw position on the X axis
   * String  - Anchor for relative draw position on the Y axis
   * Int     - Position on the X axis
   * Int     - Position on the Y axis
   ***/
  SpriteFactory(String spritesheet, String _xanchor, String _yanchor, float posX , float posY, boolean visible){
    super(SpriteMapHandler.cutTiledSpritesheet(spritesheet, 1, 1, true), 1, posX, posY, visible);
//    super(new PImage[]{sketch.loadImage(spritesheet)}, 1, posX, posY, visible);
    setCommon(_xanchor, _yanchor, posX, posY);
  }

  /***
   * Constructor for multi frame sprite.
   * Requires:
   * PApplet - Pointer to the sketch
   * String  - Location of the spritesheet
   * Int     - Number of sprites in the X on the spritesheet
   * Int     - Number of sprites in the Y on the spritesheet
   * Boolean - Read sprites left-to-right then top-to-bottom (true) or top to bottom then left-to-right (false)
   * String  - Anchor for relative draw position on the X axis
   * String  - Anchor for relative draw position on the Y axis
   * Int     - Position on the X axis
   * Int     - Position on the Y axis
   ***/
  SpriteFactory(String spritesheet, int widthCount, int heightCount, boolean leftToRightFirst, String _xanchor, String _yanchor, float posX , float posY, boolean visible){
    super(SpriteMapHandler.cutTiledSpritesheet( spritesheet,widthCount,heightCount,true), widthCount * heightCount, posX, posY, visible);
    setCommon(_xanchor, _yanchor, posX, posY);
  }

  /***
   * Constructor for deep copy.
   * Requires:
   * Sprite  - Pointer to the base sprite
   * Int     - xanchor indicator
   * Int     - yanchor indicator
   * Float   - result of xanchor
   * Float   - result of yanchor
   * Boolean - Does sprite have a move setup (true|false)
   * Boolean - Does sprite have a move looped (true|false)
   * Boolean - Is sprite rotated (true|false)
   * Boolean - Is sprite flipped vertically (true|false)
   * Boolean - Is sprite flipped horizontally (true|false)
   * Boolean - Is sprite scaled (true|false)
   * Float   - Speed of movement
   * Boolean - Has movement been completed (true|false)
   * Float   - X destination for movement
   * Float   - Y destination for movement
   * Float   - Starting X position for movement
   * Float   - Starting Y position for movement
   * Float   - Image X scale factor
   * Float   - Image Y scale factor
   * Float   - Image rotation
   * Int     - current frame #
   ***/
  private SpriteFactory(Sprite s, int _xanchor, int _yanchor, float _xOffset, float _yOffset, boolean _autoMovement, boolean _loopMovement, boolean _rotateSprite, boolean _flipSpriteVertical, boolean _flipSpriteHorizontal, boolean _scaleSprite, float _movementSpeed,
                boolean __movementOver, float _destinationX, float _destinationY, float _originalX, float _originalY, float _imageScaleX, float _imageScaleY, float _imageRotate, int _frameNum){
    super(s.frames,s.numFrames,s.positionX,s.positionY, s.visible);
    xanchor = _xanchor;
    yanchor = _yanchor;
    xOffset = _xOffset;
    yOffset = _yOffset;
    autoMovement = _autoMovement;
    loopMovement = _loopMovement;
    rotateSprite = _rotateSprite;
    flipSpriteVertical = _flipSpriteVertical;
    flipSpriteHorizontal = _flipSpriteHorizontal;
    scaleSprite = _scaleSprite;
    movementSpeed = _movementSpeed;
    _movementOver = __movementOver;
    destinationX = _destinationX;
    destinationY = _destinationY;
    originalX = _originalX;
    originalY = _originalY;
    imageScaleX = _imageScaleX;
    imageScaleY = _imageScaleY;
    imageRotate = _imageRotate;
  }

  /*--- Constructor Helpers ---*/
  /***
   * Sets common values between all of the constructors
   * Requires:
   * String  - Anchor for relative draw position on the X axis
   * String  - Anchor for relative draw position on the Y axis
   * Int     - Position on the X axis
   * Int     - Position on the Y axis
   ***/
  private void setCommon(String _xanchor, String _yanchor, float posX , float posY){
    setPosition(posX, posY);
    imageScaleX = 1;
    imageScaleY = 1;
    setAnchors(_xanchor, _yanchor);
    pause = false;
  }

  /***
   * Takes the anchor in string form and turns it into an int value
   * Requires:
   * String  - Anchor for relative draw position on the X axis
   * String  - Anchor for relative draw position on the Y axis
   ***/
  private void setAnchors(String _xanchor, String _yanchor){
    if(_xanchor == "center"){
      xanchor = 1;
    }else if(_xanchor == "right"){
      xanchor = 2;
    }else{ //"left"
      xanchor = 0;
    }

    if(_yanchor == "middle"){
      yanchor = 1;
    }else if(_yanchor == "bottom"){
      yanchor = 2;
    }else{// "top"
      yanchor = 0;
    }
    calculateAnchors();
  }

  // this value lets us control the animation offset for the sprite set
  int frameOffset = 0;
  float frameSpeed = 1;
  int markFrame = 0;

  /***
   * Sets an offset for the frame #
   * Requires:
   * Int     - Offset
   ***/
  void setFrameOffset(int offset) {
    frameOffset = offset;
  }

  /***
   * set the frame playback speed. 1 = normal,
   * 0.5 is half speed, 2 = twice as fast,
   * etc.
   ***/
  void setFrameSpeed(float speed) {
    if(abs(speed-frameSpeed)>0.1) {
      frameSpeed = speed;
      markFrame = frameCount;
    }
  }

  /***
   * Returns the current frame
   ***/
  int getCurrentFrame() {
    if(frameNum != -1) {
      return frameNum;
    }
    float bin = ((frameCount-markFrame)*frameSpeed + frameOffset) % numFrames;
    return int(bin);
  }

  /***
   * Returns the current scale values as a 2 value float array
   ***/
  float[] getScale() {
    return new float[] {imageScaleX, imageScaleY};
  }

  /***
   * Allows for the setting of exact relative positions for drawing instead of using strings
   * Requires:
   * Float   - Offset for X
   * Float   - Offset for Y
   ***/
  void setExactAnchors(float x, float y){
    xOffset = -x;
    yOffset = -y;
  }

  /***
   * Determines the correct offset for the current set of frames based of the strings originally
   * passed in.
   ***/
  private void calculateAnchors(){
    switch(xanchor){
      case 0:
        xOffset = 0;
        break;
      case 1:
        xOffset = -frames[0].width / 2;
        break;
      case 2:
        xOffset = -frames[0].width;
        break;
    }

    switch(yanchor){
      case 0:
        yOffset = 0;
        break;
      case 1:
        yOffset = -frames[0].height / 2;
        break;
      case 2:
        yOffset = -frames[0].height;
        break;
    }
  }

  /*--- Movement ---*/
  /***
   * Turns on or off movement automation
   * Required:
   * Boolean - On / off (true|false)
   ***/
  void automateMovement(boolean value){
    autoMovement = value;
  }

  /***
   * Set the movement speed
   * Required:
   * Float   - Speed
   ***/
  void setSpeed(float speed){
    movementSpeed = speed;
  }

  /***
   * Turn on/off movement looping
   * Required:
   * Boolean - on / off (true|false)
   ***/
  void loopMovement(){
    loopMovement = true;
  }

  /***
   * Set the destination for the movement
   * Required:
   * Float   - X destination
   * Float   - Y destination
   ***/
  void setDestination (float dX, float dY){
    destinationX = dX;
    destinationY = dY;
    _movementOver = false;
  }

  /***
   * Set all of the movement in 1 method
   * Required:
   * Float   - Speed
   * Float   - X destination
   * Float   - y destination
   * Boolean - Loop movement (true|false)
   ***/
  void setMovement(float speed, float dX, float dY, boolean doLoop){
    autoMovement = true;
    loopMovement = doLoop;
    movementSpeed = speed;
    destinationX = dX;
    destinationY = dY;
    _movementOver = false;
  }

  /***
   * Restart the movement frome the position the sprite was created at
   ***/
  void restartMove(){
    _movementOver = false;
    positionX = originalX;
    positionY = originalY;
  }

  /***
   * Moves the sprite to a certain place and will continue movement from there
   * Required:
   * Int    - X position
   * Int    - Y position
   ***/
  void moveTo(int posX, int posY){
    positionX = posX;
    positionY = posY;
  }

  /***
   * Using the given information, it moves the sprite to its correct place on the PApplet sketch
   ***/
  private void calculateMovement(){
    //TODO: Add Different kinds of movement?
    if (autoMovement && !movementOver() && !pause){
      float distX = (float)(destinationX - positionX);
      float distY = (float)(destinationY - positionY);
      float radiance = atan2(distY, distX);
      positionX += cos(radiance) * movementSpeed;
      positionY += sin(radiance) * movementSpeed;
      if (sqrt( (distX * distX) + (distY * distY) ) < movementSpeed){
        positionX = destinationX;
        positionY = destinationY;
        _movementOver = true;
      }
    }

    PImage frame = frames[getFrame()];
    translate(
              ((flipSpriteHorizontal? -frame.width  : 0) * imageScaleX + (flipSpriteHorizontal? -1 : 1) * ((positionX + xOffset * imageScaleX) + (rotateSprite ? frame.width/2 : 0))) / imageScaleX,
              ((flipSpriteVertical? -frame.height  : 0) * imageScaleY + (flipSpriteVertical? -1 : 1) * ((positionY + yOffset * imageScaleY) + (rotateSprite ? frame.height/2 : 0))) / imageScaleY
             );
  }

  /***
   * Using the given information, it moves the sprite to its correct place on a PGraphic
   * Required:
   * PGraphics - Graphic to draw to
   ***/
  private void calculateMovement(PGraphics g){
    //TODO: Add Different kinds of movement?
    if (autoMovement && !movementOver() && !pause){
      float distX = (float)(destinationX - positionX);
      float distY = (float)(destinationY - positionY);
      float radiance = atan2(distY, distX);
      positionX += cos(radiance) * movementSpeed;
      positionY += sin(radiance) * movementSpeed;
      if (sqrt( (distX * distX) + (distY * distY) ) < movementSpeed){
        positionX = destinationX;
        positionY = destinationY;
        _movementOver = true;
      }
    }

    PImage frame = frames[getFrame()];
    g.translate(
              ((flipSpriteHorizontal? -frame.width  : 0) * imageScaleX + (flipSpriteHorizontal? -1 : 1) * ((positionX + xOffset * imageScaleX) + (rotateSprite ? frame.width/2 : 0))) / imageScaleX,
              ((flipSpriteVertical? -frame.height  : 0) * imageScaleY + (flipSpriteVertical? -1 : 1) * ((positionY + yOffset * imageScaleY) + (rotateSprite ? frame.height/2 : 0))) / imageScaleY
             );
  }

  /***
   * Returns true if the sprite has reached its destination
   ***/
  boolean movementOver(){
    return _movementOver;
  }

  /*--- Rotate ---*/
  /***
   * Using the information given, it calculates the movement information for the PApplet sketch
   ***/
  private void calculateRotation(){
    PImage frame = frames[getFrame()];
    if(rotateSprite){
      rotate((flipSpriteHorizontal? -1 : 1) * (flipSpriteVertical? -1 : 1) * imageRotate);
      translate(-frame.width/2, -frame.height/2);
    }
  };

  /***
   * Using the information given, it calculates the movement information for a PGraphic
   * Required:
   * PGraphics - Graphic to draw to
   ***/
  private void calculateRotation(PGraphics g){
    PImage frame = frames[getFrame()];
    if(rotateSprite){
      g.rotate((flipSpriteHorizontal? -1 : 1) * (flipSpriteVertical? -1 : 1) * imageRotate);
      g.translate(-frame.width/2, -frame.height/2);
    }
  };

  /***
   * Set the rotation value for the sprite
   * Required:
   * Float     - Rotation in radians
   ***/
  void setRotation(float value){
    imageRotate = value;
    imageRotate = constrain(imageRotate, 0, TWO_PI);
    if (imageRotate != 0)
      rotateSprite = true;
    else
      rotateSprite = false;
  }


  /*--- Flip ---*/
  /***
   * Calculates horizontal flip movement information for sprite on the PApplet sketch
   ***/
  private void calculateFlipHorizontal(){
    if(flipSpriteHorizontal){
      scale(-1.0, 1.0);
    }
  }

  /***
   * Calculates horizontal flip movement information for sprite for a PGraphic
   * Required:
   * PGraphics - Graphic to draw to
   ***/
  private void calculateFlipHorizontal(PGraphics g){
    if(flipSpriteHorizontal){
      g.scale(-1.0, 1.0);
    }
  }

  /***
   * Sets whether or not to flip the sprite horizontally
   * Required:
   * Boolean - On / Off (true|false)
   ***/
  void setFlipHorizontal(boolean value){
    flipSpriteHorizontal = value;
  }


  /***
   * Calculates vertical flip movement information for sprite on the PApplet sketch
   ***/
  private void calculateFlipVertical(){
    if(flipSpriteVertical){
      scale(1.0, -1.0);
    }
  }

  /***
   * Calculates vertical flip movement information for sprite for a PGraphic
   * Required:
   * PGraphics - Graphic to draw to
   ***/
  private void calculateFlipVertical(PGraphics g){
    if(flipSpriteVertical){
      g.scale(1.0, -1.0);
    }
  }

  /***
   * Sets whether or not to flip the sprite vertically
   * Required:
   * Boolean - On / Off (true|false)
   ***/
  void setFlipVertical(boolean value){
    flipSpriteVertical = value;
  }

  /*--- Scale ---*/
  /***
   * Using the information given, calculates the scaling for the PApplet sketch
   ***/
  private void calculateScale(){
    if(scaleSprite){
      scale(imageScaleX,imageScaleY);
    }
  }

  /***
   * Using the information given, calculates the scaling for a PGraphic
   * Required:
   * PGraphics - Graphic to draw to
   ***/
  private void calculateScale(PGraphics g){
    if(scaleSprite){
      g.scale(imageScaleX,imageScaleY);
    }
  }

  /***
   * Set the exact scale values for the x and y axis
   * Required:
   * Float     - X axis scale value as a multiplier
   * Float     - Y axis scale value as a multiplier
   ***/
  void setExactScale(float x, float y)
  {
    imageScaleX = x;
    imageScaleY = y;
  }

  /***
   * Set equal scale values for the x and y axis at the same time
   * Required:
   * Float     - X and Yaxis scale value as a multiplier
   ***/
  void setScale(float value){
    imageScaleX = value;
    imageScaleY = value;

    if (imageScaleX != 1.0 || imageScaleY != 1.0)
      scaleSprite = true;
    else
      scaleSprite = false;
  }

  /*--- Inquiries ---*/
  /***
   * Returns width of scaled image
   ***/
  float getWidth(){
    return sizeX * imageScaleX;
  }
  float getHeight(){
    return sizeY*imageScaleY;
  }
  /***
   * returns true if the image is beeing flipped horizontally
   ***/
  boolean getHorizontalFlip(){
    return flipSpriteHorizontal;
  }


  /*--- General ---*/
  /***
   * Set the position of the image
   * Required:
   * Float     - X position
   * Float     - Y position
   ***/
  void setPosition(float posX, float posY){
    positionX = originalX = posX;
    positionY = originalY = posY;

  }

  /***
   * Returns a deep copy of the current sprite
   ***/
  SpriteFactory clone(){
    return new SpriteFactory ((Sprite)this, xanchor,  yanchor,  xOffset, yOffset,  autoMovement,  loopMovement,  rotateSprite,  flipSpriteVertical,  flipSpriteHorizontal,  scaleSprite, movementSpeed,
                 _movementOver,  destinationX,  destinationY,  originalX,  originalY,  imageScaleX,  imageScaleY,  imageRotate,  frameNum);
  }

  /***
   * Allows the changing of the set of sprites to those created from another sprite sheet
   * Required:
   * PImage[] - Array of frames
   * Int      - The number of frames (not really neccissary, could just call length on the array...)
   ***/
  void setSprites(PImage[] _frames, int _framesCount){
    super.setSprites(_frames, _framesCount);
    calculateAnchors();
  }

  /***
   * Sets the exact frame desired
   * Required:
   * Int      - The frame to show
   ***/
  void setFrame(int f){
    frameNum = f;
  }
  
  void nextFrame() {
    if(frameNum==-1) {
      frameNum = 0;
    } else {
      frameNum++;
    }
  }

  /***
   * Allows for the skipping of the movment calculation on the current draw cycle
   * Required:
   * Boolean - On / off (true|false)
   ***/
  void pauseMovement(boolean value){
    pause = value;
  }

  /***
   * Returns the current frame number
   ***/
  int getFrame(){
    return (frameNum != -1)? frameNum%numFrames : int((frameCount-markFrame+frameOffset)*frameSpeed)%numFrames;
  }

  /***
   * Draws the sprite to the current PApplet
   ***/
  void draw(){
    if(visible){
      pushMatrix();
        calculateFlipHorizontal();
        calculateFlipVertical();
        calculateScale();
        calculateMovement();
        calculateRotation();
        image(frames[getFrame()], 0, 0);
      popMatrix();

      if(gDebug.getStatus()){
        fill(#000000);
        ellipse((int)positionX,(int)positionY, 5, 5);
      }
    }
  }

  /***
   * Draws the sprite to the supplied PGraphics
   * Required:
   * PGraphics - The graphic to draw to.
   ***/
  void draw(PGraphics g){
    if(visible){
      g.pushMatrix();
        calculateFlipHorizontal(g);
        calculateFlipVertical(g);
        calculateScale(g);
        calculateMovement(g);
        calculateRotation(g);
        g.image(frames[getFrame()], 0, 0);
      g.popMatrix();

      if(gDebug.getStatus()){
        g.fill(#000000);
        g.ellipse((int)positionX,(int)positionY, 5, 5);
      }
    }
  }
}
