/**
 * Descent (run over birds) game.
 */
class ScreenDescent extends Screen {

  // game background
  TilingImage backdrop;

  // all sprites used in this game
  SpriteFactory skyWomanSprite, skyWomanRunning, skyWomanJumping,
                duck, eagle, goose, loon, raven, seagull, swan,
                turtle;

  // Amount of time to display a single skywoman animation frame in seconds.
  float timePerAnimationFrame;
  float timeLeftOnAnimationFrame;
  int currentAnimationFrame;

  // size of skywoman image in pixels
  int animationFrameHeight;
  int animationFrameWidth;

  // detemines the total amount of time the background
  // takes to move all the water into view (in millseconds);t
  private final int seconds = 1000;
  private final int minutes = 60000;
  float backgroundMoveTime;

  // determines how long the turle takes to swim from the
  // left of the screen to the right of the screen
  float turtleStart;
  float turtleDelay;
  float turtleTime;

  // maximum platform speed
  float minSpeed;
  float maxSpeed;
  float curSpeed;

  //number of platforms in array
  int numberOfPlatforms;

  // length of platforms. note: min length is length at
  // speed = minspeed, and max length is length at
  // speed = maxspeed. As such, minlength is actually
  // bigger than maxLength.
  float minPlatformLength;
  float maxPlatformLength;

  // These are parameters for the random platform generation
  // at minimum speed. These values increase as speed is
  // picked up
  float minSpaceBetweenPlatforms;
  float maxSpaceBetweenPlatforms;

  // minimum and maximum for platform end points on y axis
  float platformDY;
  float minPlatformY;
  float maxPlatformY;

  // distance skywoman appears from left edge of screen on x axis
  float distanceFromScreenEdge;

  // records how many frames were rendered since skywoman fell last
  int framesSinceReset;

  // is skywoman on a line?
  boolean onLine;

  // screen translations
  float yTranslationFactor;
  float yTranslate;
  float yTranslateStart;
  float xTranslate;

  // forces
  PVector playerPosition;
  PVector playerVelocity;
  PVector gravity;

  // downforce in units/second²
  float gravityAcceleration;

  // this is the scroll speed at which skywoman runs (horizontally)
  float xVelocity;

  // Sprite containers
  ArrayList<BoundingLine> boundingLines;
  ArrayList<SpriteFactory> cloudSprites;
  ArrayList<SpriteFactory> birds;

  // cloud movement
  int cloudtranslate;

  // scores are always good to have
  BoundingLine takeoff;
  int score;

  // administrative game start/stop values
  float lastDrawTime;
  float gameDuration;
  float gameStartTime, gamePauseTime;
  boolean preEndGame;
  boolean endGame;
  float endGameX;
  int endGameFrame;

  /**
   * Constructor
   */
  ScreenDescent() {
    super("descent");

    backdrop = new TilingImage("data/descent/descentBG.jpg", 0, 0, RESOLUTIONX, RESOLUTIONY);
    turtle = new SpriteFactory("data/descent/turtle/Far-Turtle-ltr-800x271.png", "center", "middle", 0, 0, true);

    cloudSprites = new ArrayList<SpriteFactory>();
    setupClouds();

    birds = new ArrayList<SpriteFactory>();
    setupBirds();

    skyWomanRunning = new SpriteFactory("data/descent/skywoman/Skywomanrun_Sprite-237x260.png", 10, 2, true, "center", "middle", 0, 0, true);
    skyWomanJumping = new SpriteFactory("data/descent/skywoman/SkyWomanJump_Sprite_new.png", 3, 1, true, "center", "middle", 0, 0, true);
    skyWomanJumping.setFrameSpeed(0.35);

    initialise();
  }

  /**
   * Initialise all values for this game
   */
  void initialise() {
    onLine = true;
    gameStartTime = millis();
    currentAnimationFrame = 0;
    timeLeftOnAnimationFrame = timePerAnimationFrame;
    gravity = new PVector(0, gravityAcceleration);
    boundingLines = new ArrayList<BoundingLine>();
    gameDuration = DESCENT_GAME_DURATION;
    lastDrawTime = millis();

    setupSkyWoman();

    // Amount of time to display a single skywoman animation frame in seconds.
    timePerAnimationFrame = 1.0/29.9;

    // size of skywoman image in pixels
    animationFrameHeight = 192;
    animationFrameWidth = 160;

    // detemines the total amount of time the background
    // takes to move all the water into view (in millseconds);
    backgroundMoveTime = 1*minutes + 30*seconds;

    // determines how long the turle takes to swim from the
    // left of the screen to the right of the screen
    turtleStart = 0;
    turtleDelay = 60;
    turtleTime = 0*minutes + 30*seconds;

    // maximum platform speed
    minSpeed = 400;
    maxSpeed = 900;
    curSpeed = minSpeed;

    //number of platforms in array
    numberOfPlatforms = 2;

    // length of platforms. note: min length is length at
    // speed = minspeed, and max length is length at
    // speed = maxspeed. As such, minlength is actually
    // bigger than maxLength.
    minPlatformLength = width * 2;
    maxPlatformLength = width / 2;

    // These are parameters for the random platform generation
    // at minimum speed. These values increase as speed is
    // picked up
    minSpaceBetweenPlatforms = 0.1 * width;
    maxSpaceBetweenPlatforms = 0.5 * width;

    // minimum and maximum for platform end points on y axis
    platformDY = 250;
    minPlatformY = 250;
    maxPlatformY = minPlatformY + platformDY;

    // distance skywoman appears from left edge of screen on x axis
    distanceFromScreenEdge = 90;

    // records how many frames were rendered since skywoman fell last
    framesSinceReset = 0;

    yTranslationFactor = 0;
    yTranslateStart = -1000;

    //This is in units down per second squared
    gravityAcceleration = 2400.0;

    // this is the scroll speed skywoman runs at horizontally
    xVelocity = 400;

    takeoff = null;
    score = 0;

    cloudtranslate = 0;
    preEndGame = false;
    endGame = false;
    endGameX = 0;
    endGameFrame = 0;
  }

  /**
   * Setup the cloud layers
   */
  void setupClouds() {
    cloudSprites.add(new SpriteFactory("data/descent/clouds/B_Ground_Cloud_01.png", "center", "middle", 1260, 300, true));
    cloudSprites.add(new SpriteFactory("data/descent/clouds/B_Ground_Cloud_02.png", "center", "middle", 1260, 350, true));
    cloudSprites.add(new SpriteFactory("data/descent/clouds/B_Ground_Cloud_03.png", "center", "middle", 1260, 400, true));

    // midground clouds start 250-420 Y move up to 150-250 Y
    cloudSprites.add(new SpriteFactory("data/descent/clouds/M_Ground_Cloud_01.png", "center", "middle", 1300, 225, true));
    cloudSprites.add(new SpriteFactory("data/descent/clouds/M_Ground_Cloud_02.png", "center", "middle", 1300, 375, true));
    cloudSprites.add(new SpriteFactory("data/descent/clouds/M_Ground_Cloud_03.png", "center", "middle", 1300, 300, true));
    cloudSprites.add(new SpriteFactory("data/descent/clouds/M_Ground_Cloud_04.png", "center", "middle", 1300, 150, true));

    // forground clouds start 450-640 Y move up to 0-200 Y
    cloudSprites.add(new SpriteFactory("data/descent/clouds/F_Ground_Cloud_01.png", "center", "middle", 1500, 200, true));
    cloudSprites.add(new SpriteFactory("data/descent/clouds/F_Ground_Cloud_02.png", "center", "middle", 1500, 300, true));
    cloudSprites.add(new SpriteFactory("data/descent/clouds/F_Ground_Cloud_03.png", "center", "middle", 1500, 370, true));

    cloudSprites.get(0).setMovement(0.6, -240, 230, false);
    cloudSprites.get(1).setMovement(0.5, -280, 280, false);
    cloudSprites.get(2).setMovement(0.7, -160, 330, false);

    cloudSprites.get(3).setMovement(1.0, -190, 150, false);
    cloudSprites.get(4).setMovement(1.2, -160, 300, false);
    cloudSprites.get(5).setMovement(1.1, -185, 225, false);
    cloudSprites.get(6).setMovement(1.0, -250, 75, false);

    cloudSprites.get(7).setMovement(1.5, -290, -100, false);
    cloudSprites.get(8).setMovement(1.4, -370, 0, false);
    cloudSprites.get(9).setMovement(1.6, -230, -130, false);

    // override start locations of clouds initially
    cloudSprites.get(1).moveTo(450,315);
    cloudSprites.get(2).moveTo(750,380);
    cloudSprites.get(3).moveTo(260,190);
    cloudSprites.get(4).moveTo(420,320);
    cloudSprites.get(5).moveTo(600,275);
    cloudSprites.get(6).moveTo(870,130);
    cloudSprites.get(7).moveTo(330,80);
    cloudSprites.get(8).moveTo(890,275);
    cloudSprites.get(9).moveTo(550,240);
  }

  /**
   * Set up all six birds to be used in the platforming.
   */
  void setupBirds() {

    // Set up all birds used in the platforms.
    duck = new SpriteFactory("data/descent/bird sprites/Duck.png", 15, 1, true, "center", "middle", 0, 0, true);
    eagle = new SpriteFactory("data/descent/bird sprites/Eagle.png", 20, 1, true, "center", "middle", 0,0, true);
    goose = new SpriteFactory("data/descent/bird sprites/Goose.png", 15, 1, true, "center", "middle", 0,0, true);
    loon = new SpriteFactory("data/descent/bird sprites/Loon.png", 10, 1, true, "center", "middle", 0,0, true);
    raven = new SpriteFactory("data/descent/bird sprites/Raven.png", 15, 1, true, "center", "middle", 0,0, true);
    seagull = new SpriteFactory("data/descent/bird sprites/Seagull.png", 15, 1, true, "center", "middle", 0,0, true);
    swan = new SpriteFactory("data/descent/bird sprites/Swan.png", 15, 1, true, "center", "middle", 0,0, true);

    eagle.setExactAnchors(70, 165);
    raven.setExactAnchors(60, 66);
    seagull.setExactAnchors(54, 45);
    swan.setExactAnchors(87, 69);

    // Order based on not entirely useful information found on
    // http://nationalzoo.si.edu/scbi/MigratoryBirds/Fact_Sheets/default.cfm?fxsht=9
    // (not entirely useful because without land, what is migration? Also, it's kind of general)
    birds.add(seagull);
    birds.add(loon);
    birds.add(eagle);
    birds.add(raven);
    birds.add(goose);
    birds.add(swan);
    birds.add(duck);
  }

  /**
   * Skywoman has two sprites, one for running, and one for jumping
   */
  void setupSkyWoman() {
    // run sprite
    skyWomanRunning.setExactAnchors(71, -36);
    skyWomanJumping.setExactAnchors(71, -36);

    // initial positioning
    playerPosition = new PVector(60, -50);
    playerVelocity = new PVector(xVelocity, 0);
    // bind
    skyWomanSprite = skyWomanRunning;
  }

  /**
   * our draw loop has three layers
   */
  void drawScreen() {
    // are we done? fade out the screen before transitioning
    if(endGame && (playerPosition.x-endGameX) > width) {
      setFinished(true, loadImage("data/general/endScreens/" + (javascript!=null && javascript.getLanguage()=="french" ? "french/" : "") + "descent.png"));
    }

    // we are not done. Draw game screen
    else {
      //Draw Background
      drawBackground();
      //Draw Actors
      drawActors();
      //Draw foreground
      drawForeground();
    }
  }

  /**
   * This removes any platform that has scrolled past the
   * left edge of the screen.
   */
  private void clearOldLines() {
    // don't clear at the end stages
    if(preEndGame) return;
    // otherwise, remove off-screen lines
    if (boundingLines.size() != 0){
      BoundingLine currentLine = boundingLines.get(0);
      if (currentLine.getEndX() < (playerPosition.x - distanceFromScreenEdge)){
        boundingLines.remove(0);
      }
    }
  }

  private void generateLines() {
    while (boundingLines.size() < numberOfPlatforms) {
      generateLine();
    }
  }

  /**
   * Generate a platform, consisting of random bounding
   * line over which Skywoman can walk.
   */
  private void generateLine() {
    // initial values - these are used when no lines have been defined yet
    float xStart = playerPosition.x, yStart = 100, xEnd = 3000, yEnd = 400;
    if (boundingLines.size() != 0) {
      BoundingLine previousLine = boundingLines.get(boundingLines.size() - 1);
      // determine next platform start based on current speed
      float fs = (curSpeed - minSpeed) / (maxSpeed - minSpeed);
      xStart = previousLine.getEndX() + lerp(minSpaceBetweenPlatforms, maxSpaceBetweenPlatforms, fs);
      xEnd = xStart + lerp(minPlatformLength, maxPlatformLength, fs) + random(0,200);

      // use this if you want less strongly sloped lines
      // TODO: figure out the best minimum and maximum slope here.
      yStart = random(minPlatformY, maxPlatformY);
      yEnd = yStart + random(-100,100);

      //float len = dist(xStart, yStart, xEnd, yEnd);
      //println("platform length: "+len);
    }
    boundingLines.add(new BoundingBirdLine(new PVector(xStart, yStart), new PVector(xEnd, yEnd), birds, yTranslate/(backdrop.height-height)));
  }

  /**
   * Draw the background water layer, as well as the clouds
   */
  private void drawBackground() {

    // this slowly raises the background water
    float timeElapsed = millis() - gameStartTime;
    if(timeElapsed < backgroundMoveTime) {
      yTranslationFactor = timeElapsed/backgroundMoveTime;
    } else if (turtleStart == 0) {
      turtleStart = millis();
    }

    yTranslate = yTranslationFactor*(backdrop.height-height);
    backdrop.draw(0, -yTranslate);

    // render the cloud deck
    pushMatrix();
    translate(0,cloudtranslate);
    for(int i=0; i < cloudSprites.size(); i++){
      SpriteFactory temp = cloudSprites.get(i);
      temp.draw();
      if(temp.movementOver()){
        // reset cloud
        temp.restartMove();
        cloudtranslate -= 1;
      }
    }
    popMatrix();

    // draw the turtle, if it should be on screen.
    float txpos = 0, txposMax = width + 0.25 * turtle.sizeX;
    if(turtleStart > 0) {

      // move the turle slower when we're in the air,
      // or speed-augmented depending on how fast
      // we're running right now.
      // FIXME: make this work
      if(!onLine) { turtleTime += 0; }
      else { turtleTime -= 0; }

      float turtleNow = (millis()-turtleStart) / turtleTime;
      txpos = constrain(map(turtleNow,0,1, -100, width), 0, txposMax);
      if(txpos != txposMax) { turtle.setScale(turtleNow); }

      // final stages of the level?
      // - running on a platform
      // - turtle's docked at right of screen
      // - player's passed 2/3rd of the screen width
      // - we've not started jumping offscreen yet
      if(onLine && (txpos == txposMax) && playerPosition.x-endGameX > width/1.5 && !preEndGame) {
        preEndGame = true;
        // if last platform does not extend beyond the screen, immediately
        // add a platform that starts just outside the screen with an impossibly far
        // endpoint.


        // otherwise, modify the existing platform's endpoint to be very far
        // so that we can't fall off.


        // try to jump to the end of the screen
        longJump(width);
      }

      turtle.setPosition(txpos, RESOLUTIONY - 150);
      turtle.draw();
    }

    // End game condition: when the turtle has traversed
    // most of the screen, the game stops.
    // This basically means running a "scripted event"
    // where the birds fly up and SkyWoman jumps into
    // the turtle?
    if(!endGame && txpos == txposMax) {
      endGame = true;
      endGameX = playerPosition.x;
      endGameFrame = frameCount;
    }
  }

  /**
   * This part draws SkyWoman doing her platforming
   */
  private boolean moveActorForFrame(float timeLeft) {
    float startX = playerPosition.x;
    // Can stick some horizontal acceleration in here later if it is needed
    // if we add horizontal acceleration need to calculate end of frame
    // velocity not start for proper distance
    float endX = playerPosition.x + timeLeft * playerVelocity.x;
    boolean encounteredLineEdge = false;
    boolean isInLineRange = false;
    float timeSegment = 0;
    int lineHit = -1;

    BoundingLine currentLine = boundingLines.get(0);
    for (int lineIndex = 0; lineIndex < boundingLines.size();lineIndex++) {
      // For each platform we want to check if it starts or ends between
      //  startX and endX. If it does, we've found the current platform.
      currentLine = boundingLines.get(lineIndex);

      // Line starts between start of frame and end of frame
      if (startX < currentLine.getStartX() && endX > currentLine.getStartX()) {
        encounteredLineEdge = true;
        isInLineRange = false;
        lineHit = lineIndex;
        //Break out of the loop if we hit something
        lineIndex = boundingLines.size();
        //This is the amount of time we have before we encounter the line
        timeSegment = (timeLeft / (endX - startX)) * (currentLine.getStartX() - startX);
        timeLeft-=timeSegment;
      }

      // Line ends between start of frame and end of frame
      else if (startX < currentLine.getEndX() && endX > currentLine.getEndX()) {
        encounteredLineEdge = true;
        isInLineRange = true;
        lineHit = lineIndex;
        // Break out of the loop if we hit something
        lineIndex = boundingLines.size();
        // This is the amount of time we have before we encounter the line
        timeSegment = (timeLeft / (endX - startX)) * (currentLine.getEndX() - startX);
        timeLeft-=timeSegment;
      }

      // Frame is entirely within a line
      else if (startX > currentLine.getStartX() && endX < currentLine.getEndX()) {
        encounteredLineEdge = false;
        isInLineRange = true;
        lineHit = lineIndex;
        lineIndex = boundingLines.size();
      }
    }

    // Didn't hit a line edge so we don't need to break up our movement at all
    if (!encounteredLineEdge) {
      timeSegment = timeLeft;
      timeLeft = 0;
    }

    // If we're in the same range as a line then check if the player was above the
    // line at the start of the time segment. If they go below the line by the end
    // of the time segment then we know they collided with it and need to be stuck
    // back on top.
    boolean wasAboveAtStart = false;
    if (isInLineRange) {
      float lineHeight = currentLine.getHeight(playerPosition);
      if (playerPosition.y > lineHeight) {
        wasAboveAtStart = false;
      }
      else {
        wasAboveAtStart = true;
      }
    }

    PVector acceleration = gravity;
    PVector startVelocity = playerVelocity.get();
    playerVelocity.add(PVector.mult(acceleration, timeSegment));
    PVector intervalVelocity = PVector.div(PVector.add(startVelocity, playerVelocity), 2.0);
    playerPosition.add(PVector.mult(intervalVelocity, timeSegment));

    // The line will fail to stop the player if a player jumps in such a way that
    // they have an upward velocity when going into range of the line but are
    // underneath the line at the start and then, in that same frame, they go
    // above the line and then below it. This is a pretty extreme edge case and I
    // am not worried about it.
    boolean isOnLine = false;
    if (isInLineRange && wasAboveAtStart) {
      float lineHeight = currentLine.getHeight(playerPosition);
      // At high frame rates, particularly on downward sloped lines, the player won't
      // actually fall far enough between frames to go under the line and trigger the
      // "on the line" detection. The + 5 makes sure it detects that case properly.
      if (playerPosition.y + 5 > lineHeight) {
        playerPosition.y = lineHeight;
        playerVelocity.set(xVelocity, 0, 0);
        isOnLine = true;
      }
    }

    // If we still have time left between this frame and the next, call this method
    // again to see what happens in the remaining interfame period.
    if (timeLeft > 0) {
      return moveActorForFrame(timeLeft);
    }
    // When we're done moving we want to return a boolean
    // indicating whether or not the player is on a line.
    else {
      return isOnLine;
    }
  }

  /**
   * Draw all actors
   */
  private void drawActors() {
    float timeElapsed = (millis() - lastDrawTime) / 1000.0;
    lastDrawTime = millis();

    // calculate distance to move this frame based on time, velocity, and acceleration

    // While moving we may move into and out of the x range of various lines. We must divide our movement
    // into segments for these lines, with the dividing points in the movement being going over/under the
    // start or finish of a line. We can do this recursively in a function. This function goes through the
    // lines in our collection (which is and must be ordered from left to right) and checks if any of the
    // line is within the space that we are moving this turn. If none of the lines are, acceleration is
    // applied normally. If a line encompasses the start position this frame then we determine how long
    // we'll be in the x range of that line for, and we calculate movement and acceleration as normal and
    // stick the player on top of the line with velocity 0 if they would otherwise travel through it.
    // Otherwise if a line starts partway through the frame then we move as normal for the period before
    // we get in range of that line. Then we call this function again for the rest of our elapsed time.

    clearOldLines();
    generateLines();

    boolean landed = !onLine;

    // is SkyWoman on a platform now?
    onLine = moveActorForFrame(timeElapsed);

    // did she just land?
    landed = landed && onLine;
    if(takeoff!=null && takeoff != boundingLines.get(0)) {
      // increase the score
      score += curSpeed;
      takeoff = null;
    }

    // If onLine is false, either skyWoman is jumping,
    // or she's falling. Either way, on the first frame
    // that this is the case we need to swap her running
    // sprite with her jumping sprite.
    if(!onLine && skyWomanSprite != skyWomanJumping) {
      skyWomanSprite = skyWomanJumping;
    }

    // If there is no vertical velocity, and SkyWoman
    // is jumping, set the sprite back to running.
    if(playerVelocity.y == 0 && skyWomanSprite == skyWomanJumping) {
      skyWomanSprite = skyWomanRunning;
    }

    float animationTiming = timeElapsed;

    // NOTE:  -
    // FIXME: -
    // TODO:  Find out what this code does. It looks like
    //        an animation spin loop...
    //
    while (animationTiming > 0) {
      if (animationTiming > timeLeftOnAnimationFrame) {
        animationTiming-=timeLeftOnAnimationFrame;
        timeLeftOnAnimationFrame = timePerAnimationFrame;
        currentAnimationFrame++;
        if (currentAnimationFrame >= skyWomanRunning.size()) {
          currentAnimationFrame = 0;
        }
      }
      else {
        timeLeftOnAnimationFrame-=animationTiming;
        animationTiming = 0;
      }
    }

    pushMatrix();

    curSpeed = constrain(minSpeed + framesSinceReset++, minSpeed, maxSpeed);
    playerVelocity.x = (endGame? minSpeed : curSpeed);

    // FIXME: add a gradual slowdow at the endgame point
    translate((endGame ? -endGameX : -playerPosition.x) + distanceFromScreenEdge, 0);

    // Draw all background components of the platform lines
    for(BoundingLine bl: boundingLines) {
      bl.drawBackground();
    }

    // reposition SkyWoman so that it looks like her position is fixed with respect to the screen.
    skyWomanSprite.moveTo(125 + int(playerPosition.x - animationFrameWidth/2), int(playerPosition.y - animationFrameHeight));
    // set animation speed based on scroll speed
    if(skyWomanSprite == skyWomanRunning) {
      skyWomanSprite.setFrameSpeed(0.05 + 0.95*curSpeed/maxSpeed);
    }
    skyWomanSprite.draw();

    // Draw all foreground components of the platform lines.
    for(BoundingLine bl: boundingLines) {
      bl.drawForeground();
    }

    popMatrix();

    // SkyWoman fell - reset position and velocities
    if(playerPosition.y > 640){
      gDebug.add("Fell off world");
      playerPosition = new PVector(playerPosition.x,-80);
      playerVelocity = new PVector(xVelocity,0);
      framesSinceReset = 0;
      curSpeed = minSpeed;
      // decrease player score
      score -= 2*curSpeed;
      if(score<0) { score = 0; }
    }
  }

  /**
   * Make SkyWoman jump
   */
  void jump() {
    if(onLine) {
      takeoff = boundingLines.get(0);
      playerVelocity.add(new PVector(0, -DESCENT_JUMP_HEIGHT));
    }
  }

  /**
   * Make SkyWoman jump far.
   */
  void longJump(float distance) {
    playerVelocity.add(new PVector(distance, -DESCENT_JUMP_HEIGHT));
  }

  private void drawForeground() {
    textAlign(RIGHT);
    text("SCORE: "+score, width-10, 20);
  }

  // pausing the screen starts the "paused" timer, which will get added to the gameStartTime on resume
  void pauseScreen() {
    gamePauseTime = millis();
  }

  // resumig the screen sets "last frame" to "now" so that we resume, instead of skip ahead
  void resumeScreen() {
    lastDrawTime = millis();
    gameStartTime += millis()-gamePauseTime;
    if(turtleStart!=0) {
      turtleStart += millis()-gamePauseTime;
    }
  }

// =========

  void mousePressed(int x, int y) {
    jump();
  }

  void keyPressed(char key, int keyCode) {
    if(keyCode == 32) { jump(); }
  }

// =========

  // This method is intended to be used to reset assets that can be changed
  // on other screens to their correct positions and sizes.
  void reset() {
    initialise();
  }

  void loadambient() {
    SoundPlayer.load(this,"data/audio/Uprooted.mp3");
  }

  String getHelpContent() {
    String english = "Help Sky woman reach Turtle by jumping from bird platform to bird platform.\n"+
           "The longer you run, the faster you run, so be careful!\n"+
           "Click, or press space bar, to jump.";
    String french = "Aidez la Femme Céleste arriver à Tortue la faisant sauter d’estrade d’oiseau à\n"+
           "estrade d’oiseau. Plus vous courez, plus vous prenez de la vitesse, alors soyez\n"+
           "prudent! Cliquez ou appuyez sur la barre espace pour sauter.";
    if(javascript!=null && javascript.getLanguage()=="french") return french;
    return english;
  }

  float getHelpTranslateFactor() {
    return 0.0;
  }

  void goPreviousScreen() {
    changeScreen(mainMenu);
  }

  boolean hasPreviousScreen() {
    return false;
  }
}

