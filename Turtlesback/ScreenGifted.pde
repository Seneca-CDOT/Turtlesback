class ScreenGifted extends Screen {

  //Variable Declarations
  PImage[] muskratSprites,muskratSpritesMask, muskratGrabSprites, muskratGrabSpritesMask, muskratHasSprites, muskratHasSpritesMask, muskratHitUp, muskratHitDown;
  PImage bgImage;

  PGraphics maskImage, muskratSnapshot;
  ArrayList<SpriteFactory> obstacles;

  Button left_button, right_button;
  int button_pressed;


  SpriteFactory masterFishSchool, masterWhale, masterSalmon, masterEel, masterShark, masterCoral;
  SpriteFactory turtle, mountain, muskrat, muskratMask, muskratDirt, muskratOnTurtle;
  SpriteFactory bubbles, lightRay;

  ArrayList lightRayLocations, bubbleLocations;

  int timerObstacle, timerLightRay, timer;
  int score, hitCount;

  boolean muskratReturn, muskratHasPoint, muskratCollide;

  float xTranslate, muskratPrevPosX, counter;
  int xTurtle, muskrateMoveRate, muskratGrabFrame, collisionTimer;

  boolean calculateSimpleCollision = false;

  ScreenGifted() {
    super("gifted");

    //Setup the different sprite factories for each of the actors
    turtle = new SpriteFactory(GIFTED_GAME_IMAGE_TURTLE + ".png", 15, 2, true, "center", "middle", RESOLUTIONX / 2, 135, true);
    // TEST TEST TEST
    PImage[] tmp = new PImage[15];
    arrayCopy(turtle.frames, 15, tmp, 0, 15);
    for(int i=0; i<15; i++) { turtle.frames[15+i] = tmp[14-i]; }
    // TEST TEST TEST
    turtle.setFrameSpeed(0.5);

    //The muskrat has several different sprite sheets depending on what it is doing.
    //Here we are setting up the arrays that will carry those sprite sheets
    muskratHitUp = new PImage[] { loadImage(GIFTED_GAME_IMAGE_MUSKRAT_HIT_UP) };
    muskratHitDown = new PImage[] { loadImage(GIFTED_GAME_IMAGE_MUSKRAT_HIT_DOWN) };

    muskratSprites = SpriteMapHandler.cutTiledSpritesheet( GIFTED_GAME_IMAGE_MUSKRAT + ".png",10,2, true);
    muskratSpritesMask = SpriteMapHandler.cutTiledSpritesheet(GIFTED_GAME_IMAGE_MUSKRAT + "_mask.png",10,2, true);
    muskratGrabSprites = SpriteMapHandler.cutTiledSpritesheet( GIFTED_GAME_IMAGE_MUSKRAT_GRAB + ".png",10,2, true);
    muskratGrabSpritesMask = SpriteMapHandler.cutTiledSpritesheet(GIFTED_GAME_IMAGE_MUSKRAT_GRAB + "_mask.png",10,2, true);
    muskratHasSprites = SpriteMapHandler.cutTiledSpritesheet( GIFTED_GAME_IMAGE_MUSKRAT_HAS + ".png",10,2, true);
    muskratHasSpritesMask = SpriteMapHandler.cutTiledSpritesheet(GIFTED_GAME_IMAGE_MUSKRAT_HAS + "_mask.png",10,2, true);

    muskrat = new SpriteFactory(GIFTED_GAME_IMAGE_MUSKRAT + ".png", 10, 2, true, "center", "middle", RESOLUTIONX / 2, GIFTED_MUSKRAT_START_HEIGHT, false);
    muskratOnTurtle = new SpriteFactory(GIFTED_GAME_IMAGE_MUSKRAT_CHILLING + ".png", "center", "center", 0, 0, false);
    muskratMask = new SpriteFactory(GIFTED_GAME_IMAGE_MUSKRAT + "_mask.png", 10, 2, true, "left", "top", 0, 0, true);
    muskratDirt = new SpriteFactory(GIFTED_GAME_IMAGE_EARTH_DROP + ".png", 4, 1, true, "center", "middle", 0, 0, false);

    //Master sprites that the obstacles are created from
    masterFishSchool = new SpriteFactory(GIFTED_GAME_IMAGE_FISH + ".png", 10, 2, true, "center", "middle", 0, 0, false);
    masterWhale = new SpriteFactory(GIFTED_GAME_IMAGE_WHALE + ".png", 10, 2, true, "center", "middle", 0, 0, false);
    masterSalmon = new SpriteFactory(GIFTED_GAME_IMAGE_SALMON+ ".png", 15, 1, true, "center", "middle", 0, 0, false);
    masterShark = new SpriteFactory(GIFTED_GAME_IMAGE_SHARK+ ".png", 15, 1, true, "center", "middle", 0, 0, false);
    masterEel = new SpriteFactory(GIFTED_GAME_IMAGE_EEL+ ".png", 15, 2, true, "center", "middle", 0, 0, false);

    masterCoral = new SpriteFactory(GIFTED_GAME_IMAGE_CORAL + ".png", "center", "bottom", 0, 0, true);
    bubbles = new SpriteFactory(GIFTED_GAME_IMAGE_BUBBLE+ ".png", 30, 2, true, "center", "middle", 0, 0, true);
    lightRay = new SpriteFactory(GIFTED_GAME_IMAGE_LIGHTRAY + ".png", "center", "middle", 0, 0, true);

    // controls
    left_button = new Button(40,360,102);
    left_button.setImage(loadImage("data/gifted/Directional_left.png"),0,0);

    right_button = new Button(width-40-102, 360, 102);
    right_button.setImage(loadImage("data/gifted/Directional_right.png"),0,0);

    initialise();
  }

  void initialise() {
    //Startup Timer
    timer = millis();

    //background
    bgImage = loadImage(GIFTED_GAME_BACKGROUND);

    //backbuffer stuff for collisions
    maskImage = createGraphics(2116, RESOLUTIONY, P2D);
    muskratSnapshot = createGraphics(200, 200, P2D);

    // set administrative values;
    xTranslate = 0;
    xTurtle = 0;
    muskratPrevPosX = 0;
    muskrateMoveRate = 3;
    muskratGrabFrame = 0;
    collisionTimer = 0;
    counter = 0.0;

    //Arrays that will hold an unknown # of items
    obstacles = new ArrayList<SpriteFactory>();
    lightRayLocations = new ArrayList();
    bubbleLocations = new ArrayList();

    //Score
    score = 0;
    hitCount = 0;

    //position stuff
    xTranslate = (2116 - RESOLUTIONX/2 ) / 2;

    timerLightRay = timerObstacle = millis() - 4000;

    muskratReturn = false;
    muskratHasPoint = false;
    muskratCollide = false;
    muskratOnTurtle.visible = true;

    //change to regular sprites
    muskrat.setSprites(muskratSprites, 20);

    //change to correct mask
    muskratMask.setSprites(muskratSpritesMask, 20);

    turtle.setPosition(RESOLUTIONX / 2, 135);
    muskrat.setPosition(RESOLUTIONX / 2, GIFTED_MUSKRAT_START_HEIGHT);
    muskrat.visible = false;

    mountain = null;
    button_pressed = -1;

    // should we perform full, or simplified collision detection? (iE9 and iPad need simple)
    calculateSimpleCollision = false;
  }

  //Draw Loop
  void drawScreen(){
    int fulltimer = millis();//draw loop timer

    // mouse/touch handling
    if(button_pressed==LEFT) { moveLeft(); }
    if(button_pressed==RIGHT) { moveRight(); }

    //constraints
    score = constrain(score, 0, 9);
    xTranslate = constrain(xTranslate, 0, 2116 - width);
    turtle.positionX = constrain(turtle.positionX, -xTranslate + ( width / 2),( 2116 - width/2) - xTranslate);

    //reset our backbuffers
    maskImage.background(255,0,0);
    muskratSnapshot.background(255,255,255);

    //Generate obstacles & clean up array containing them
    doObstacles();

    //Draw Background
    drawBackground();

    //Draw Actors
    drawActors();

    //Draw foreground
    drawForeground();

    left_button.draw();
    right_button.draw();

    //Do collision detection
    detectCollisions();

    //Win State
    if (score > 9)
    {
      gDebug.add("Game is in win state");
      setFinished(true, loadImage("data/general/endScreens/" + (javascript!=null && javascript.getLanguage()=="french" ? "french/" : "") + "gifted.png"));
    }

    //debug info
    gDebug.add("Entire Draw Loop Took: " + ( millis() - fulltimer )+ "ms");
    if (gDebug.getStatus())
      line(RESOLUTIONX/2,0,RESOLUTIONX/2,RESOLUTIONY);
  }


  private void drawBackground(){
    background(#000000);
    pushMatrix();
      translate(-xTranslate, 0);
      image(bgImage, 0, -100,2116,700);//keeps original aspect ratio. Since the sky area is too high, it is translated up by 100px too...
    popMatrix();
  }

  private void drawActors(){
    muskrat.draw();

    //Draws out all of the obstacles (fish)
    pushMatrix();
      translate(-xTranslate, 0);
      muskratDirt.draw();
      for(int i = 0; i < obstacles.size(); i++){
          SpriteFactory currentObstacle = obstacles.get(i);
          currentObstacle.draw();

          // 1% chance per frame to have bubbles created at obstacle
          if (random(0,101) > 99)
            bubbleLocations.add(new float[]{currentObstacle.positionX + (currentObstacle.getHorizontalFlip()? 1 : -1) * currentObstacle.getWidth()/2, currentObstacle.positionY, 0, 2});

          //once off screen, remove it
          if(currentObstacle.movementOver()){
            obstacles.remove(i);
          }
      }
    popMatrix();

    if(muskrat.visible==false) {
      boolean flipped = turtle.getHorizontalFlip();
      muskratOnTurtle.setFlipHorizontal(flipped);
      int f = (flipped ? -1 : 1);
      muskratOnTurtle.setPosition(turtle.positionX-f*80, turtle.positionY-55);
      muskratOnTurtle.draw();
    }

    turtle.draw();

    // draw mountain on the turtle
    if(mountain!=null) {
      pushMatrix();
      translate(turtle.positionX-106,turtle.positionY-216);
      mountain.draw();
      popMatrix(); }

    // draw mountain on the turtle
    if(mountain!=null) {
      pushMatrix();
      translate(turtle.positionX-108,turtle.positionY-216);
      scale(1.05,1);
      mountain.draw();
      popMatrix(); }

    //Do backbuffer stuff for collision
    maskImage.beginDraw();
    for(int i = 0; i < obstacles.size(); i++){
      SpriteFactory currentObstacle = obstacles.get(i);
      //Don't calculate movement twice!
      currentObstacle.pauseMovement(true);

      //Reduces load for drawing to backbuffer, ensure obstacle is close
      float distFromMuskrat = (currentObstacle.positionX - (xTranslate + RESOLUTIONX/2));
      if (distFromMuskrat  > -200 && distFromMuskrat < 200)
        currentObstacle.draw(maskImage);

      //turn off movement pause
      currentObstacle.pauseMovement(false);
    }
    maskImage.endDraw();

    //Get muskrat frame
    muskratSnapshot.beginDraw();
    muskratMask.pauseMovement(true); //Don't calculate movement twice!
    muskratMask.draw(muskratSnapshot);
    muskratMask.pauseMovement(false); //turn off movement pause
    muskratSnapshot.endDraw();


    //Draw out bubbles
    for(int i = 0; i < bubbleLocations.size(); i++){
       pushMatrix();
        float[] currentbubble = (float[])bubbleLocations.get(i); // array of float arrays
        translate(currentbubble[0] -xTranslate,currentbubble[1]); //0 = x, 1 = y
        bubbles.setFrame((int)currentbubble[2]); // 2 = frame #
        bubbles.draw();
        if (currentbubble[2] == 59 || currentbubble[1] < 175 ){ // if end of frames or has gone too high, remove
          bubbleLocations.remove(i);
        }else
          currentbubble[2] ++;//next frame
          currentbubble[1] -= currentbubble[3]; // 3 = speed
       popMatrix();
    }


    //Dirt Movement Logic
    if (muskratDirt.visible && muskratDirt.getFrame() < 3 && muskratDirt.movementOver()){
      muskratDirt.setFrame(muskratDirt.getFrame() + 1);
      muskratDirt.setDestination(muskratDirt.positionX, muskratDirt.positionY + 25);
    }else if(muskratDirt.visible && muskratDirt.movementOver()){
      muskratDirt.visible = false;
    }

    //Muskrat Movement Logic
    if(muskrat.visible){ // if we are drawing it
      if (muskratCollide && (muskratHasPoint || !muskratReturn)) //if we have detected a collide and are in a state that is viable for it to affect us
      {
         if (muskratHasPoint){ // we are going up
           muskrat.setDestination(muskrat.positionX, muskrat.positionY); // stop moving

           //change to stun sprite
           muskrat.setSprites(muskratHitUp, 1);

           //do stun movement
           xTranslate -= 1;
           turtle.positionX += 1;
         } else if (!muskratReturn){ // we are going down
           muskrat.setDestination(muskrat.positionX, muskrat.positionY); //stop moving

           //change to stun sprite
           muskrat.setSprites(muskratHitDown, 1);

           //do stun movement
           xTranslate -= 1;
           turtle.positionX += 1;
         }
         //stun movement over
         if (millis() - collisionTimer > 1000)
         {
           hitCount++;

           //change to regular sprites
           muskrat.setSprites(muskratSprites, 20);
           muskrat.setFlipVertical(true);

           //change to correct mask
           muskratMask.setSprites(muskratSpritesMask, 20);
           muskratMask.setFlipVertical(true);

           //start up the movement process again
           muskrat.setDestination(turtle.positionX, 120);

           //reset variables
           muskratReturn = true;
           muskratCollide = false;
           muskratHasPoint = false;
         }
      }else{//Regular movement
        if (muskrat.positionY >= 495){ //if we are above px 495, do the grab motion
          if(muskratReturn){
            if (muskrat.getFrame() == 19){//if on the last frame
              //change to correct frames
              muskrat.setSprites(muskratHasSprites, 20);
              muskrat.positionY = 494;

              //change to correct mask
              muskratMask.setSprites(muskratHasSpritesMask, 20);

            }else if (muskrat.getFrame() == 10){//set off bubble on frame 10
                bubbleLocations.add(new float[]{muskrat.positionX + xTranslate, muskrat.positionY- 50, 0, 4});
            }
          }
          else if (muskrat.getFrame() == 0 && !muskratReturn){//Frame 0, start the grab sequence
            //set sprites
            muskrat.setSprites(muskratGrabSprites, 20);

            //set mask
            muskratMask.setSprites(muskratGrabSpritesMask, 20);

            //set info  variables
            muskratHasPoint = true;
            muskratReturn = true;
          }
        }else if (muskratReturn){ //if we are lower than px 495 and are moving back up
          if (muskrat.movementOver() && muskrat.positionY == 120){//are we back at the surface?
            //reset the sprites
            muskrat.setSprites(muskratSprites, 20);
            muskrat.setFlipVertical(false);

            //reset mask
            muskratMask.setSprites(muskratSpritesMask, 20);
            muskratMask.setFlipVertical(false);

            //hide the muskrat
            muskrat.visible = false;
            muskratReturn = false;

            //force turtle to center of screen
            turtle.positionX = RESOLUTIONX / 2;

            if (muskratHasPoint){
              // add a new layer of mountains
              boolean flipped = turtle.getHorizontalFlip();
              float xpos = flipped? -28 : 0;
              mountain = new SpriteFactory(GIFTED_MOUNTAIN_PREFIX + score+".png", "CENTER", "CENTER", xpos, 0, true);
              mountain.setFlipHorizontal(flipped);

              // make the muskrate face pop up behind the turtle for a bit
              muskratOnTurtle.visible = true;

              // add a point
              score++;
            }

            //reset info variables
            muskratCollide = false;
            muskratHasPoint = false;
          }//--Otherwise...

          //reset the destination in case the turtle has moved
          muskrat.setDestination(turtle.positionX, 120);

          //slide the screen back to the correct location
          float tempCalc = (RESOLUTIONX/2 - muskrat.positionX);
          xTranslate -= tempCalc;
          turtle.positionX += tempCalc;
          muskrat.positionX = RESOLUTIONX/2;
        }
      }
    }
  }

  private void drawForeground(){
    //Draw the coral
    for (int i = 0; i < 2616; i += 500)
    {
      pushMatrix();
        translate(i-xTranslate*1.5, RESOLUTIONY); //parallax scroll on the coral
        masterCoral.draw();
      popMatrix();
    }

    //light rays are randomly added
    if(millis() - timerLightRay >= 1000){
        //currently off since the tint fucntion is not cooperating in pjs
        //lightRayLocations.add(new float[]{ random(0, 2116), 450, 0, 0});
        timerLightRay = millis();
    }

    //draw out the light rays
    for(int i = 0; i < lightRayLocations.size(); i++){
      pushMatrix();
      pushStyle();

      float[] currentRay = (float[])lightRayLocations.get(i);//get the lightray info
      // 2 = alpha, 3 = increase(0) or decrease(1)
      if (currentRay[2] == 255 &&  currentRay[3] == 0)//full alpha and trying to increase
        currentRay[3] = 1; // start to decrease the alpha
      else if (currentRay[2] == 0 &&  currentRay[3] == 1)// 0 alpha and trying to decrease
        lightRayLocations.remove(i);//remove
      else if (currentRay[3] == 1)//decrease
        currentRay[2]-= 5;
      else//increase
        currentRay[2] += 5;

      currentRay[2] = constrain(currentRay[2], 0, 255);// don't let opacity go into error territory
      tint( 255, (int)currentRay[2]); // set opacity
      translate(currentRay[0] -xTranslate, currentRay[1]); //move
        lightRay.draw();//draw
      noTint();//turn off tint
      popStyle();
      popMatrix();
    }

    fill(0,0,100);
    textAlign(RIGHT);
    text("PIECES: "+score+"/10    SCORE: "+constrain(score*10 - hitCount, 0, 100)+"/100", width-10, 20);
  }

  private void doObstacles(){
    //if we are not full up on obstacles and the time since last generate is over 1.5 seconds
    if (obstacles.size() < GIFTED_MAX_OBSTACLE_COUNT && millis() - timerObstacle > GIFTED_MIN_OBSTACLE_INTERVAL){
      // add a new obstacle
      obstacles.add(GenerateRandom());
      timerObstacle = millis();
    }
  }


  private void detectCollisions(){
    if(muskrat.visible && !muskratCollide){ // only do this if we are not colliding and we are drawing muskrat

      // Get the current muskrat boxing values
      float scaleFactor = muskrat.getScale()[0];
      float mw = muskrat.sizeX * scaleFactor,
            mh = muskrat.sizeY * scaleFactor,
            mmx = muskrat.positionX, // horizontal box midpoint
            mmy = muskrat.positionY; // vertical box midpoint

      int dx=0, dy=0, dw=0, dh=0;
      float omx=0, omy=0, ow=0, oh=0;

      // check if the muskrat's bounding box is overlapping with any of the fish bounding boxes.
      // if this is not the case, we can shortcut collision detection.
      boolean possibleCollision = false;
      SpriteFactory collider = obstacles.get(0);
      for(SpriteFactory sf: obstacles) {
        ow = sf.frames[0].width;
        oh = sf.frames[0].height;
        omx = sf.positionX - xTranslate;  // horizontal box midpoint
        omy = sf.positionY;               // vertical box midpoint
        
        dx = (int)abs(mmx - omx);
        dy = (int)abs(mmy - omy);
        dw = (int)(mw+ow)/2;
        dh = (int)(mh+oh)/2;

        // possible box collision?
        possibleCollision = dx < dw && dy < dh;
        if(possibleCollision) { break; }
      }
      if(!possibleCollision) return;
      // after this block of code, there is a potential collision,
      // and we should perform mask-based collision verification


      if(!calculateSimpleCollision) {
        //get the part of the backbuffer we need
        PImage backbuffer = maskImage.get((int)(xTranslate + RESOLUTIONX / 2  - mw / 2), (int)(muskrat.positionY - mh / 2), (int)mw , (int)mh);
        PImage muskratMaskBuffer = muskratSnapshot.get(0,0, (int)mw, (int)mh);
  
        //load pixels so we can inspect colour
        backbuffer.loadPixels();
        muskratMaskBuffer.loadPixels();
  
        int backBufferSize = backbuffer.pixels.length;

        // check the pixel mask, with a specific fidelity. This
        // value gets updated during the loop if the loop is
        // taking too long. The default is 4, set in initialise
        float startTime = millis();
        for (int i = 0; i < backBufferSize && !muskratCollide; i += 4) {
          if ( (backbuffer.pixels[i] != color(255, 0, 0) &&  backbuffer.pixels[i] != color(254, 0, 0)) // if the pixel is not either of these reds on the back buffer (processing bug)
               &&
               (muskratMaskBuffer.pixels[i] == color(2,2,2) || muskratMaskBuffer.pixels[i] == color(0,0,0) )) // and the pixel color is either of these blacks on the muskrat buffer (processing bug)
          {
            muskratCollide = true; //we are colliding
            break;
          }
        }

        //close up
        backbuffer.updatePixels();
        muskratMaskBuffer.updatePixels();

        // check whether this collision detection takes intolerably long.
        // if it does, fall back to primitive box collision instead
        float timeTaken = millis()-startTime;
//        println("check took: " + timeTaken + "ms");
        if(timeTaken >= 4) {
//          println("switching to simple collision");
          calculateSimpleCollision = true;
        }
      }

      // perform simple collision detection rather than mask-based collision detection
      if(calculateSimpleCollision) {
        muskratCollide = dx<0.8*dw && dy < 0.8*dh;
      }
      
      // so: was there a collision?
      if(muskratCollide) {
        collisionTimer = millis(); //start timer to stun for 1.5 second
        if(muskratHasPoint){ //show dirt if the muskrat had it in his hands
          muskratDirt.setPosition(muskrat.positionX + xTranslate, muskrat.positionY);
          muskratDirt.visible = true;
          muskratDirt.setMovement(1, muskratDirt.positionX, muskratDirt.positionY + 25, false);
          muskratDirt.setFrame(0);
        }
      }
    }
  }


  private SpriteFactory GenerateRandom(){
    SpriteFactory result;//sprite to return

    //Constraints
    int presetRangeMin = 1, presetRangeMax = 101,
        posXMin = 0,     posXMax = 1, //left or right side of screen
        posYMin = 150,   posYMax = RESOLUTIONY,
        speedMin = 1,    speedMax = 5;

    //Generate Randoms
    int rPreset = int(random(presetRangeMin,presetRangeMax)),
        rPosX = random(posXMin,posXMax) >= 0.5 ? 1 : 0,
        rPosY = int(random(posYMin,posYMax)),
        rSpeed = int(random(speedMin,speedMax));

    //Select
      if (rPreset < 35)
        result = (SpriteFactory)masterFishSchool.clone();
      else if (rPreset < 60)
        result = (SpriteFactory)masterEel.clone();
      else if (rPreset < 80)
        result = (SpriteFactory)masterSalmon.clone();
      else if (rPreset < 95)
        result = (SpriteFactory)masterShark.clone();
      else
        result = (SpriteFactory)masterWhale.clone();

    //Adjustments
    rPosY = (int)(rPosY - (result.sizeY / 2)  < GIFTED_GAME_MIN_DRAWY ? GIFTED_GAME_MIN_DRAWY + (result.sizeY / 2) : rPosY);
    rPosY = (int)(rPosY + (result.sizeY / 2) > GIFTED_GAME_MAX_DRAWY ? GIFTED_GAME_MAX_DRAWY - (result.sizeY / 2) : rPosY);

    result.setPosition((rPosX == 1 ? 2116 + result.sizeX /2 : -result.sizeX /2), rPosY); // set correct start position
    result.setMovement(rSpeed, (rPosX == 1 ? - result.sizeX /2 :  2116 + (result.sizeX / 2)), rPosY, false); // set the correct destination

    if(rPosX == 0)
      result.setFlipHorizontal(true); // face the correct direction

    result.visible = true;

    return result;
  }

  // unused
  void pauseScreen() {}

  // unused
  void resumeScreen() {}

// =========

  void keyPressed(char key, int keyCode){
    if (keyCode == LEFT){// implicitly move left
      button_pressed = LEFT;
    }
    else if (keyCode == RIGHT){//implicitly move right
      button_pressed = RIGHT;
    }
    else if (keyCode == 32){//launch muskrat on <space>
      launchMuskrat();
    }
  }

  void keyReleased(char key, int keyCode) {
    if (keyCode == LEFT){// implicitly move left
      button_pressed = -1;
    }
    else if (keyCode == RIGHT){//implicitly move right
      button_pressed = -1;
    }
  }

  void moveLeft() {
    if (muskrat.visible) {
      if(muskrat.positionY>200)//move the turtle
      turtle.positionX -= 10;
    }
    else { //move the screen
      xTranslate -= 10;
    }
    turtle.setFlipHorizontal(false);
    if(mountain!=null) {
      mountain.setFlipHorizontal(false);
      mountain.positionX = 0;
    }
  }

  void moveRight() {
    if (muskrat.visible) {
       if(muskrat.positionY>200) //move the turtle
        turtle.positionX+= 10;
    }
    else { //move the screen
      xTranslate += 10;
    }
    turtle.setFlipHorizontal(true);
    if(mountain!=null) {
      mountain.setFlipHorizontal(true);
      mountain.positionX = -28; }
  }

  void launchMuskrat() {
    if (!muskrat.visible){//not already drawing muskrat
      muskrat.positionX = turtle.positionX; // move it to the correct location
      muskrat.setMovement(muskrateMoveRate, turtle.positionX, 495, false);//set movement
      muskrat.visible = true;//show it
    }
  }

  void mousePressed(int x, int y){
    if(left_button.over(x,y)) { button_pressed = LEFT; }
    else if(right_button.over(x,y)) { button_pressed = RIGHT; }
    else {
      button_pressed = -1;
      launchMuskrat();
    }
  }

  void mouseReleased(int x, int y){
    super.mouseReleased(x,y);
    button_pressed = -1;
  }

// =========

  // This method is intended to be used to reset assets that can be changed
  // on other screens to their correct positions and sizes.
  void reset() {
    initialise();
  }


  String getHelpContent() {
    String english = "Help Muskrat dive to the bottom and collect earth, without getting hit.\n"+
           "Click, or press space bar, to make Muskrat dive. Move Turtle left and right with\n"+
           "the arrow keys on screen or keyboard. Muskrat will always swim back to Turtle.";
    String french = "Aidez Muskrat à plonger au fond de l’océan pour ramasser de la terre,\n"+
           "sans se faire frapper. Cliquez ou appuyez sur la barre espace pour plonger.\n"+
           "Orientez Tortue à gauche et à droit avec les touches de direction sur votre\n"+
           "clavier ou votre écran. Muskrat va toujours retourner à Tortue.";
    if(javascript!=null && javascript.getLanguage()=="french") return french;
    return english;
  }

  float getHelpTranslateFactor(){
    return 0.0;
  }

  void goPreviousScreen() {
    changeScreen(mainMenu);
  }

  boolean hasPreviousScreen(){
    return false;
  }

  void loadambient() {
    SoundPlayer.load(this, "data/audio/Gifted.mp3");
  }
}


