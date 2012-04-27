/**
 * FIXME: This class needs major cleanup
 */
class ButtonRectangular extends Button{
  float height, width;
  boolean locked;
  PImage lockImage;

  ButtonRectangular(int x, int y, float width, float height){
    this(x,y,width,height,false);
  }
  
  ButtonRectangular(int x, int y,  float width, float height, boolean locked) {
    super(x,y,width);
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.locked = locked;
    if(locked) { lockImage = loadImage(LOCKED_BUTTON_IMAGE); }
    hasImage= false;
    hasText = false;
    this.debugWidth = width;
    this.debugHeight = height;
  }
  
  boolean over(int x, int y){
    if(locked) return false;
    // x and y are screen coordinates 
    isOver = abs(this.x-x) <= (this.width/2) && abs(this.y-y) <= (this.height/2);
    return isOver;
  }
  
  void setLocked(boolean l) {
    locked = l;
  }

  // override  
  void draw(int x, int y){
    super.draw(x, y);
    // FIXME: why are x and y completely ignored?
    if(locked) { 
      image(lockImage, this.x-0.65*width, this.y-0.45*height/2); }
  }
}
