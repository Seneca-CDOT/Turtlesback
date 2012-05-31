class ScreenMainMenu extends Screen {

  PFont _mainMenuFont;
  int _mainMenuFontSize;

  ButtonRectangular[] buttons = new ButtonRectangular[5];
  Screen[] screens = new Screen[5];
  Screen newScreen;
  int screenid = -1;
  boolean swapout = false;
  PImage backdrop;
  String loadtext;

  ScreenMainMenu(boolean game1locked, boolean game2locked, boolean game3locked, boolean game4locked){
    super("main menu");

    backdrop = loadImage("data/turtlesback_bg_titlescreen01.png");
    buttons[0] = new ButtonRectangular(175,411, 165,75, game1locked);
    buttons[1] = new ButtonRectangular(803,411, 165,75, game2locked);
    buttons[2] = new ButtonRectangular(175,538, 165,75, game3locked);
    buttons[3] = new ButtonRectangular(803,538, 165,75, game4locked);
    buttons[4] = new ButtonRectangular(455,80, 370,97);

    _mainMenuFontSize = STANDARD_FONT_SIZE;
    _mainMenuFont = createFont(STANDARD_FONT_NAME,_mainMenuFontSize);
    textFont(_mainMenuFont);
  }
  
  void unlock(int id) {
    buttons[id].setLocked(false);
  }

  void keyReleased(char pressedKey){
  }

  void drawPause() {
    // override superclass to not show pause button
  }

  void drawScreen(){
    
    // prepare for building a screen and switching to that.
    if(screenid != -1 && !swapout) {
      pushStyle();
      noStroke();
      fill(0,120,255);
      rect(-1,-1,width+2,height+2);
      fill(255);
      textAlign(CENTER);
      textSize(48);
      loadtext = "loading";
      if (javascript!=null && javascript.getLanguage()=="french") {
        loadtext = "chargement";
      }      
      text(loadtext+"...",width/2,height/2);
      swapout = true;
      loop();
      popStyle();
    }
    
    // we need to do this in "the next frame", because
    // otherwise the SpriteMapHandler work will hold up
    // the draw operation until it's done and the sketch
    // just sits there, seemingly doing nothing.
    else if(swapout) {
      switch(screenid) {
        case 0 : newScreen = new ScreenUprooted(); break;
        case 1 : newScreen = new ScreenDescent(); break;
        case 2 : newScreen = new ScreenGifted(); break;
        case 3 : newScreen = new ScreenGrounded(); break;
        default : newScreen = new ScreenCredits();
      }
      changeScreen(newScreen);
      newScreen = null;
      screenid = -1;
      swapout = false;
    }
    
    // Normal main menu functionality means that we sit there
    // simply waiting for user input.
    else { 
      //Draw Background
      drawBackground();
      //Draw Actors
      drawActors();
      //Draw foreground
      drawForeground();
      noLoop(); 
    }
  }

  // unused
  void pauseScreen() {}

  // unused
  void resumeScreen() {}

  void keyPressed(char k){
  }

  private void drawBackground(){
    image(backdrop,0,0);
  }

  private void drawActors(){
    for(ButtonRectangular button: buttons) {
      button.draw();
    }
  }

  private void drawForeground(){
  }

  void mouseMoved(int x, int y){
    super.mouseMoved(x,y);
    boolean over = false;
    for(ButtonRectangular button: buttons) {
      if(button.over(x,y)) {
        over = true;
        break; }}
    cursor(over? HAND : ARROW);
  }

  void mousePressed(int x, int y){
  }

  void mouseReleased(int x, int y){
    for(int b=0, last = buttons.length; b<last; b++) {
      ButtonRectangular button = buttons[b];
      if(button.over(x,y)) {
        screenid = b;
      }
    }
    redraw();
  }

  void mouseDragged(int x, int y){
  }

  void mouseOut(){
  }

  // reset this screen. We override isPaused
  // so that we immediately start "playing"
  // the main menu screen.
  void reset(){ isPaused = false; }

  void loadambient(){
    // no ambient music at the moment
  }

  String getHelpContent(){
    return "";
  }

  float getHelpTranslateFactor(){
    return 0.0;
  }

  void goPreviousScreen(){
  }

  boolean hasPreviousScreen(){
    return false;
  }
}
