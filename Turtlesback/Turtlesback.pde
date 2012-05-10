// Turtles game main file

Screen currentScreen;
ScreenMainMenu mainMenu;
gDebugger gDebug;
boolean isDebugging = false;

// initialize the sound playing class object wrapping Minim library
SoundPlayer soundPlayer;

BoundingBox[][] treeBranches;
BoundingBox[][] collectibleItems;

// list of movies that should be played
HashMap<String,Boolean> playmovie;

/**
 *
 */
void setup(){
  Localization.setLanguage(en_CA);
  size(RESOLUTIONX, RESOLUTIONY);
  background(#ffffff);
  frameRate(MAX_FRAMERATE);

  // set up debugger
  gDebug = new gDebugger();
  gDebug.setColor(color(255, 0, 0));
  gDebug.setOn(isDebugging);

  // spritemapper needs a reference to the sketch for loadImage
  SpriteMapHandler.init(this);
  // soundplayer needs a reference to the sketch for Minim
  SoundPlayer.init(this);
  // muter needs a reference to the sketch for loadImage
  Muter.init(this, new ButtonRound(25, height-25, 40));

  // set up initial view: main menu screen
  mainMenu = new ScreenMainMenu(false, true, true, true);
  changeScreen(mainMenu);

  setupMovies();
}

/**
 * chronicle which movies are to be played still
 */
void setupMovies() {
  playmovie = new HashMap<String,Boolean>();
  playmovie.put("main menu",false);
  playmovie.put("uprooted",true);
  playmovie.put("descent",true);
  playmovie.put("gifted",true);
  playmovie.put("grounded",true);
  playmovie.put("ending",true);
}

// does a particular movie require playing, still?
boolean shouldPlay(String title) {
  return playmovie.get(title);
}

// mark a movie as having been played
void markPlayed(String title) {
  playmovie.put(title,false);
}

// are there still any movies left to play?
boolean moviesPending() {
  for(String key: playmovie.keySet()) {
    if(key=="ending") continue;
    if(playmovie.get(key)==true) {
      return true;
    }
  }
  return false;
}

/**
 * draw, or swap, screens
 */
void draw() {
  if(currentScreen!=null && currentScreen.isFinished()) {
    if(javascript!=null && shouldPlay("ending") && currentScreen.getTitle() == "grounded") {
      noLoop();
      javascript.loadMovie("ending");
      markPlayed("ending");
    }
    if(currentScreen.getTitle() == "uprooted") { mainMenu.unlock(1); }
    if(currentScreen.getTitle() == "descent") { mainMenu.unlock(2); }
    if(currentScreen.getTitle() == "gifted") { mainMenu.unlock(3); }
    loadMainMenu();
  }
  else {
    currentScreen.draw();
    gDebug.draw();
  }
}

// called to go back to the main menu after a movie's done.
void loadMainMenu() {
  changeScreen(mainMenu);
}

/**
 * First step in the two-step screen swap procedure
 */
void changeScreen(Screen scr){
  // stop previous screen
  if(currentScreen!=null) {
    currentScreen.stopambient();
    SoundPlayer.disown(currentScreen);
  }

  // swap screens
  currentScreen = scr;
  if(javascript!=null) {
    // play pre-game video
    noLoop();
    String title = currentScreen.getTitle();
    if(shouldPlay(title)) {
      javascript.loadMovie(title);
      markPlayed(title);
    } else {
      runScreen();
    }
  }

  // if there is no javascript, immediate run
  if(javascript==null) {
    runScreen();
  }
}

/**
 * Second step in the two-step screen swap procedure
 */
void runScreen() {
  loop();
  currentScreen.resetScreen();
  currentScreen.loadambient();
  currentScreen.playambient();
}

void mouseMoved(){
  currentScreen.tryMouseMoved(mouseX,mouseY);
}

void mousePressed(){
  currentScreen.tryMousePressed(mouseX,mouseY);
}

void mouseOut(){
  currentScreen.mouseOut();
}

void mouseReleased() {
  currentScreen.tryMouseReleased(mouseX,mouseY);
}

void mouseDragged(){
  currentScreen.tryMouseDragged(mouseX,mouseY);
}

void keyReleased(){
  currentScreen.tryKeyReleased(key, keyCode);
}

void keyPressed(){
/*
  if(key == 'e'){
    Localization.setLanguage(en_CA);
    currentScreen.resetScreen();
  } else if (key == 'f'){
    Localization.setLanguage(fr_CA);
    currentScreen.resetScreen();
  } else if (key == 'd' || key == 'D'){
    isDebugging = !isDebugging;
    gDebug.setOn(isDebugging);
  }
*/
  currentScreen.tryKeyPressed(key, keyCode);
}
