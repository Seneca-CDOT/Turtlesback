class ScreenCredits extends Screen {

  String[] credits;
  int vheight;
  int step = 0;
  PFont creditfont = createFont("data/HammersmithOne.ttf",20);

  ScreenCredits() {
    super("credits");
    credits = loadStrings("data/credits.txt");
    int len = credits.length;
    vheight = len * 20; // FIXME: hardcoded lineheight for now. This is bad.
    textFont(creditfont);
  }

  void drawScreen() {
    step++;
    if(step==1) { SoundPlayer.resume(this, true); }
    pushStyle();
    pushMatrix();
    background(0);
    textAlign(CENTER);
    fill(127);
    text("click anywhere, or press a key, to return to the main menu",width/2,20);
    fill(255);
    translate(0, -step % (vheight + 1.1*height));
    for(int e = 0, last=credits.length; e<last; e++) {
      text(credits[e], width/2, 1.1*height + e*20);
    }
    popMatrix();
    popStyle();
  }

  void pauseScreen() {
  }

  void resumeScreen() {
    textFont(creditfont);
  }

  // reset this screen. We override isPaused
  // so that we immediately start "playing"
  // the credit screen.
  void reset() {
    isPaused = false;
    step = 0;
  }

  String getHelpContent(){
    return "";
  }

  float getHelpTranslateFactor(){
    return 0.0;
  }

  void keyPressed(char key, int keyCode) {
    goPreviousScreen();
  }

  void mousePressed(int mx, int my) {
    goPreviousScreen();
  }

  void goPreviousScreen() {
    changeScreen(mainMenu);
  }

  boolean hasPreviousScreen(){
    return true;
  }

  void loadambient() {
    SoundPlayer.load(this, "data/audio/Descent.mp3");
    SoundPlayer.resume(this, true);
  }

  void drawHelpText() {}
}
