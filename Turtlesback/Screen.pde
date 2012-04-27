/**
 * The Screen class houses universal screen functionality.
 * It is abstract, so that subclasses must implement all
 * empty methods themselves.
 */
abstract class Screen {
  // screen title
  private String title;
  String getTitle() { return title; }

  // finish message
  private PImage endScreen;

  // how many frames have we been fading?
  private int fadeframe = 0;

  // should we fade out?
  private boolean fadeout = false;

  // has this screen finished?
  private boolean finished = false;

  /** pause/resume/home functionality **/
  boolean isPaused;
  boolean hasTintedScreen;

  // add these to the constants .pde file
  int screenTint = 128,
      pauseButtonX = 40,
      pauseButtonY = 40,
      backButtonX = 120,
      backButtonY = 40,
      pauseBackButtonRadius = 40;

  // overlay controls
  Button pauseButton, resumeButton, backButton;

  /**
   * set up the basics
   */
  Screen(String title) {
    this.title = title;

    PImage pauseButtonImage = loadImage("data/general/pause.png");
    pauseButton = new ButtonRound(25, 25, 10);
    pauseButton.setImage(pauseButtonImage,-20, -20);

    PImage resumeButtonImage = loadImage("data/general/play.png");
    resumeButton = new ButtonRound(width/2+80, height/2, 40);
    resumeButton.setImage(resumeButtonImage,-40,-40);

    PImage backButtonImage = loadImage("data/general/back.png");
    backButton = new ButtonRound(width/2-80, height/2, 40);
    backButton.setImage(backButtonImage,-40,-40);
  }

  /**
   * Perform master draw administration, then
   * call the subclass's drawScreen(), if possible.
   */
  final void draw() {
    // are we done? fade out the screen before transitioning
    if(fadeout) {
      int fcount = (frameCount-fadeframe);
      image(endScreen,0,0);
      float alphaValue = (fcount > 2*frameRate ? 255*(fcount-2*frameRate)/(3*frameRate) : 0);
      fill(0,alphaValue);
      rect(-1, -1, width+2, height+2);
      // this effects a four second fade-out
      if(fcount>5*frameRate) {
        finished = true;
        SoundPlayer.stop(this);
      }
    }

    // we are not done. Draw game screen
    else {
      // are we paused?
      if (isPaused){
        // we are, but we haven't made the overlay yet.
        if (!hasTintedScreen){
          SoundPlayer.pause(this);
          // draw screen once more so we don't have
          // a pause button underlay
          drawScreen();
          // draw a dark overlay
          pushStyle();
          pushMatrix();
          fill(0,screenTint);
          rect(0,0,width,height);
          hasTintedScreen = true;
          popMatrix();
          popStyle();
          // and show resume/home buttons on it
          resumeButton.draw();
          backButton.draw();
          fill(255);
          textAlign(CENTER);
          textFont(createFont("data/HammersmithOne.ttf",24));
          text(getHelpContent(), 0.5*width, 0.75*height);
          // pause everything
          noLoop();
          pauseScreen();
        }
      }

      // we are not paused, draw normally
      else {
        drawScreen();
        drawPause();
      }

      // draw the mute button
      Muter.draw();
    }
  }

  /**
   * This can be override by subclasses so
   * that the draw button is never shown.
   */
  void drawPause() {
    if (!isPaused){
      pauseButton.draw();
    }
  }

  // implemented in subclasses
  abstract void pauseScreen();

  // implemented in subclasses
  abstract void resumeScreen();

  // implemented in subclasses
  abstract void drawScreen();

  // internal pause function
  private void pause() {
    isPaused = true;
    SoundPlayer.pause(this);
  }

//==================

  /**
   * Screen has the ability to intercept mouse and key events.
   */
  final void tryMouseMoved(int x, int y) {
    if ((!isPaused && pauseButton.over(x,y)) || (isPaused && (resumeButton.over(x,y) || backButton.over(x,y))) || Muter.over(x,y)) {
      cursor(HAND);
    } else {
      cursor(ARROW);
    }
    mouseMoved(x,y);
  }

  // can be overriden in subclasses
  protected void mouseMoved(int x, int y) {}

  /**
   * Screen has the ability to intercept mouse and key events.
   */
  final void tryMousePressed(int x, int y) {
    if (!isPaused && pauseButton.over(x,y)) {
      pause();
    }
    else if (isPaused && resumeButton.over(x,y)) {
      isPaused = false;
      SoundPlayer.resume(this, true); // resume as looping
      hasTintedScreen = false;
      loop();
      resumeScreen();
    }
    else if (isPaused && backButton.over(x,y)) {
      SoundPlayer.stop(this);
      changeScreen(mainMenu);
      loop();
      resumeScreen();
    }
    else if(Muter.over(x,y)) {
      Muter.mute();
      redraw();
    }
    else { mousePressed(x,y); }
  }

  // can be overriden in subclasses
  protected void mousePressed(int x, int y) {}

  /**
   * Screen has the ability to intercept mouse and key events.
   */
  final void tryMouseDragged(int x, int y) {
    mouseDragged(x,y);
  }

  // can be overriden in subclasses
  protected void mouseDragged(int x, int y) {}

  /**
   * Screen has the ability to intercept mouse and key events.
   */
  final void tryMouseReleased(int x, int y) {
    mouseReleased(x,y);
  }

  // can be overriden in subclasses
  protected void mouseReleased(int x, int y) {}

  /**
   * Screen has the ability to intercept mouse and key events.
   */
  final void tryMouseOut() {
    mouseOut();
  }

  // can be overriden in subclasses
  protected void mouseOut() {}

  /**
   * Screen has the ability to intercept mouse and key events.
   */
  final void tryKeyPressed(char key, int keyCode) {
    if(!isPaused) {
      keyPressed(key, keyCode);
    }
  }

  // can be overriden in subclasses
  protected void keyPressed(char key, int keyCode){}

  /**
   * Screen has the ability to intercept mouse and key events.
   */
  final void tryKeyReleased(char key, int keyCode) {
    if(!isPaused) {
      keyReleased(key, keyCode);
    }
  }

  // can be overriden in subclasses
  protected void keyReleased(char key, int keyCode) {}

//==================

  //This method is intended to be used to reset assets that can be changed on other screens to their correct positions and sizes
  abstract void reset();

  // implemented by subclasses to call SoundManager.load(this, "some file name");
  abstract void loadambient();

  /**
   * Play ambient music
   */
  final void playambient() { SoundPlayer.loop(this); }

  /**
   * Stop ambient music
   */
  final void stopambient() { SoundPlayer.stop(this); }

  // implemented by subclasses
  abstract String getHelpContent();

  // implemented by subclasses
  abstract float getHelpTranslateFactor();

  // implemented by subclasses
  abstract void goPreviousScreen();

  // implemented by subclasses
  abstract boolean hasPreviousScreen();

  /**
   * Soft finish: mark that we're done, and enter
   * the fade-out period. At the end of this period
   * the draw() method effects finished=true
   */
  void setFinished(boolean v, PImage endImage) {
    fadeout = true;
    fadeframe = frameCount;
    endScreen = endImage;
  }

  /**
   * Incidates whether a screen has finished
   * and can be swapped out.
   */
  boolean isFinished() {
    return finished;
  }

  /**
   * Reset the Screen administrative values,
   * then calls the subclass's reset method.
   */
  void resetScreen() {
    pause();
    hasTintedScreen = false;
    fadeout = false;
    finished = false;
    reset();
  }
}

/**
 * We only want a single mute button for the entire program
 */
static class Muter {

  private static PImage muteButtonImage_mute;
  private static PImage muteButtonImage_unmute;
  static ButtonRound muteButton;
  private static int px=0, py=0;

  static void init(PApplet sketch, ButtonRound button) {
    muteButtonImage_mute = sketch.loadImage("data/general/mute.png");
    muteButtonImage_unmute = sketch.loadImage("data/general/nomute.png");
    px = -muteButtonImage_mute.width/2;
    py = -muteButtonImage_mute.height/2;
    muteButton = button;
    muteButton.setImage(muteButtonImage_mute,px,py);
  }

  static void mute() {
    SoundPlayer.mute();
    if(SoundPlayer.muted) { muteButton.setImage(muteButtonImage_unmute,px,py); }
    else { muteButton.setImage(muteButtonImage_mute,px,py); }}

  static boolean over(int x, int y) { return muteButton.over(x,y); }

  static void draw() { muteButton.draw(); }
}
