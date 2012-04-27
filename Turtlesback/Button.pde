class Button implements Clickable {
  int x, y;
  //This button has a radius, but it's actually a square clickable area. Don't let this confuse you.
  float radius;
  
  boolean hasImage;
  boolean hasImagePressed;
  PImage buttonImage;
  PImage pressedImage;
  int imgXOffset, imgYOffset;
  int imgPressedXOffset, imgPressedYOffset;
  
  boolean hasText;
  String textToDisplay;
  PFont mainFont;
  int fontSize; 
  private color textColor;
  int textXOffset;
  int textYOffset;
  boolean isCentered;
  boolean isRightAligned;
  boolean isOver;
  float debugWidth,debugHeight;
  
  
  //As a possible future goal we could change button to have a collection of display elements (images/text) that implement an interface that specifies that they
  //can draw. Then you'd just go through the array of display elements and draw them all on the button and have the actual clickable area seperate from all of those
  //things.
  
  Button(int x, int y, float r) {
    this.x = x;
    this.y = y;
    this.radius = r;
    hasImage= false;
    hasImagePressed = false;
    hasText = false;
    isOver = false;
    debugWidth = r;
    debugHeight = r;
  }
  
  boolean over(int x, int y){
    // x and y are screen coordinates
    isOver = (abs(this.x-x) <= this.radius && abs(this.y-y) <= this.radius);
    return isOver;
  }
  
  void setOver(boolean toggle){
    this.isOver = toggle;
  }
  
  void setImage(PImage img, int imgXOffset, int imgYOffset){
    hasImage = true;
    hasImagePressed = false;
    buttonImage = img;
    //this.buttonImage.resize((int)radius*2,0);
    this.imgXOffset = imgXOffset;
    this.imgYOffset = imgYOffset;
    this.imgPressedXOffset = imgXOffset;
    this.imgPressedYOffset = imgYOffset;
  }
  
  void setImage(PImage img, PImage imgPressed, int imgXOffset, int imgYOffset){
    hasImage = true;
    hasImagePressed = true;
    buttonImage = img;
    pressedImage = imgPressed;
    //this.buttonImage.resize((int)radius*2,0); //this was for low res compatibility
    this.imgXOffset = imgXOffset;
    this.imgYOffset = imgYOffset;
    this.imgPressedXOffset = imgXOffset;
    this.imgPressedYOffset = imgYOffset;
  }
  
  void setImage(PImage img, PImage imgPressed, int imgXOffset, int imgYOffset, int imgPressedXOffset, int imgPressedYOffset){
    hasImage = true;
    hasImagePressed = true;
    buttonImage = img;
    pressedImage = imgPressed;
    //this.buttonImage.resize((int)radius*2,0); //this was for low res compatibility
    this.imgXOffset = imgXOffset;
    this.imgYOffset = imgYOffset;
    this.imgPressedXOffset = imgPressedXOffset;
    this.imgPressedYOffset = imgPressedYOffset;
  }
  
  void clearImages(){
    hasImage = false;
    hasImagePressed = false;
    buttonImage = null;
    pressedImage = null;
  }
  
  void setText(String textToDisplay, String fontName, int fontSize, color textColor, int textXOffset, int textYOffset){
    this.hasText = true;
    this.fontSize = fontSize <= 0 ? 1 : fontSize;
    this.mainFont = createFont(fontName, this.fontSize);
    this.textToDisplay = textToDisplay;
    this.textColor = textColor;
    this.textXOffset = textXOffset;
    this.textYOffset = textYOffset;
    isCentered = false;
    isRightAligned = false;
  }
  
  void setTextToDisplay(String textToDisplay){
    this.textToDisplay = textToDisplay;
  }
  
  void setLeftAlignedText(){
    isCentered = false;
    isRightAligned = false;
  }
  
  void setCenterAlignedText(){
    isCentered = true;
    isRightAligned = false;
  }
  
  void setRightAlignedText(){
    isCentered = false;
    isRightAligned = true;
  }
  
  void draw(){
    draw(0,0);
  }
  
  void draw(int xOffset,int yOffset){
    if(isOver && hasImagePressed && pressedImage != null){
      image(this.pressedImage, this.x + imgPressedXOffset + xOffset, this.y + imgPressedYOffset + yOffset);
    } else if (hasImage){
      image(this.buttonImage, this.x + imgXOffset + xOffset, this.y + imgYOffset + yOffset);
    }
    if (hasText){
      pushStyle();
      
      textFont(mainFont, fontSize); 
      fill(textColor);
      float textWidthOffset = 0;
      if (isCentered){
        textWidthOffset = textWidth(textToDisplay)/-2;
      }else if (isRightAligned){
        textWidthOffset = textWidth(textToDisplay) * -1;
      }
     
      text(textToDisplay, x+textXOffset+textWidthOffset + xOffset, y+textYOffset + yOffset);
      popStyle();
    }
    if(isDebugging){
      pushStyle();
      stroke(#ff0000);
      noFill();
      rect(this.x-(this.debugWidth/2), this.y-(this.debugHeight/2), this.debugWidth, this.debugHeight);
      popStyle();
    } 
  }
  
  int getX(){
    return x;
  }
  
  int getY(){
    return y;
  }
  
  void setX(int x){
    this.x = x;
  }
  
  void setY(int y){
    this.y = y;
  }
  
  void setTextXOffset(int x){
    textXOffset = x;
  }
  void setTextYOffset(int y){
    textYOffset = y;
  }
}
