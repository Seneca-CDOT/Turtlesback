class ScreenUprooted extends Screen{

  PVector playerPosition;
  float playerHeight;
  boolean isMouseOut;

  float timePerAnimationFrame = 1.0/15.0;
  float timePerAnimationFrameHit = 1.0/15.0;

  float timeToUseHitAnimation = 1.7;

  PVector[] playerCollisionPoints;
  PVector[] rotatedCollisionPoints;
  int numberOfOptionalPoints;

  int animationIterateOrder = 1;
  float timeLeftOnAnimationFrame;
  int currentAnimationFrame;

  float timeLeftOnHitAnimation;

  //These are in pixels (at 960x640) per second
  PVector playerVelocity;

  PImage backdrop;

  PImage[] itemImages, itemImagesFaded, itemImagesHighlight;

  // This is supposed to be in chances that one will appear each second.
  // I'm not confident in the algorithm I use to determine if one should
  // be generated each frame, so think of these numbers as fuzzy.
  float chanceOfCollectibleItem = 0.82;
  float chanceToLoseCollectedItem = 0.5;
  float chanceOfTreeBranch = 0.65;
  float chanceOfCosmeticTreeBranch = 5;
  float chanceOfCloud = 1.65;

  // these values track the user input
  boolean isUpPressed;
  boolean isDownPressed;
  boolean isLeftPressed;
  boolean isRightPressed;

  // While this is true, accelerate the player towards the mouse coords
  boolean isMousePressed;
  PVector lastMouse;

  ArrayList activeItems;

  ArrayList playerCollectedItems;
  int[] collectedItemTallies;
  int maxDimensionOfTallyImages;

  ArrayList mobileItems;
  ArrayList mobileItemTimeouts;
  ArrayList mobileItemVelocities;

  int playerHitPenalty = 1;
  float minPlayerHitVelocity = 2400;
  float maxPlayerHitVelocity = 3600;

  PImage trunk;

  PImage[][] barkImages;
  float[][] minBarkY;
  float[][] maxBarkY;
  float[] minBarkSpacing;
  float[] maxBarkSpacing;
  float[] heightOfNextBark;

  ArrayList activeBarkHeights;
  ArrayList activeBarkTypes;
  ArrayList activeBarkSubtypes;
  ArrayList activeBarkXDestination;
  ArrayList activeBarkYDestination;

  // these variables keep track of branches on the screen
  ArrayList<TreeBranch> passiveBranches;
  ArrayList<TreeBranch> activeBranches;
  PVector[] branchBaseOffsets;

  // to prevent needless GC, we 'retire' rather than
  // kill off offscreen branches, and then recycle them
  // rather than only calling new Branch.
  ArrayList<TreeBranch> passiveBranchesRecycler;
  ArrayList<TreeBranch> activeBranchesRecycler;

  //Contains PImages
  ArrayList imagesToDraw;
  //Contains PVectors
  ArrayList imagesToDrawCoords;

  //This sets the distance from 0 on the x axis that the bark will reach full size at
  float barkMagnificationOffset = 0;

  PVector barkSpawnPoint = new PVector(408,RESOLUTIONY/2);
  PVector branchSpawnPoint = barkSpawnPoint;
  PVector itemSpawnPoint = barkSpawnPoint;
  PVector cloudSpawnPoint = barkSpawnPoint;

  // Only the x component of the following endpoint is actually used. We need to change
  // these. Right now, we are actually showing a wall that branches and bark are coming
  // up. In order to make it a cylrindrical tree we have to make a a circle that the
  // branches are coming to. Distance from origin to points on the circle is r. So:
  //
  //   sqrt(x^2 + y^2) = r, x^2 + y^2 = r^2, x^2 = r^2 - y^2,
  //   x = sqrt(r^2 - y^2)
  //   y = +/- sqrt(r^2 - y^2)
  //
  // In order to rotate branches to align to the circle, we should rotate them by atan(y/x)

  PVector barkEndPoint = new PVector(-585,RESOLUTIONY/2);
  PVector branchEndPoint = barkEndPoint;

  float treeRadius = 585;
  // So the centre of the tree, according to the tree graphic once it gets to our height,
  // is at -585, 300 and the radius is 585, so at "player" height, the tree lies outside
  // the left of the screen, with its bark touching the left edge.

  // these are the lowest and highest Y values on the
  // circle described by the tree (centered at -585/300)
  // the corrections prevent straight-up/down branches
  int lowestYPointOnCircle = -285 + 10;
  int highestYPointOnCircle = 885 - 10;

  //Distance below the player that bark spawns at
  float barkSpawnHeight = -25;
  float branchSpawnHeight = -16;
  float itemSpawnHeight = -10;
  float cloudSpawnHeight = -30;

  PImage[] branchImages, cosmeticBranchImages;
  int[] lowRangesForBranches;
  int[] highRangesForBranches;
  int[] lowLimitsForCosmeticBranches;
  int[] upperLimitsForCosmeticBranches;

  PImage[] cloudImages;
  ArrayList activeCloudHeights;
  ArrayList activeCloudTypes;
  ArrayList activeCloudDestinations;
  ArrayList activeCloudRotations;
  //If the cloud goes on the other side of this point then it is no longer visible and should be cleared
  ArrayList activeCloudTerminationPoints;

  //The clouds are placed by finding a random angle within this range, finding a random length within the range of maxDistanceToScreenEdge to maxDistanceToScreenEdge + cloudMaxRange,
  //and then determining the coordinates of the end of a line of that length drawn at the given angle from the spawn point
  float minCloudAngle = -1.953;
  float maxCloudAngle = 1.704;
  //This is the length of the longest line from the spawn point to the edge of the screen- in this case, the upper and lower right corners
  //IMPORTANT NOTE: This needs to be manually recalculated if the barkSpawnPoint ever changes. The game won't break if it isn't, but the clouds might still be onscreen at the player's height
  float maxDistanceToScreenEdge = 628;
  //This is the distance that clouds have to be offscreen in order to not show up onscreen at the player's height. Find the distance from the center of the biggest image to the corner for this number
  float minimumCloudDistanceOffscreen = 300;//736;//160;
  //This is the range, in pixels, beyond the edge of the screen that clouds can have their destination set to;
  float cloudMaxRange = 2000;

  PImage[] collectImages;

  float minItemSpeed = 700.0;
  float maxItemSpeed = 800.0;
  float mobileItemLifespan = 3.0;

  PImage[] skyWomanSprites;
  PImage[] skyWomanHitSprites;

  int lastDrawTime;

  //This is in pixels (at 960x640) per second^2
  float playerAccelerationRate = (1700.0 * RESOLUTIONX) / 960;
  float playerMaxVelocity = (700.0 * RESOLUTIONX) / 960;

  //Each frame reduce the magnitude of the player's velocity by this * the acceleration for that frame. This will cause the player to move more towards the mouse cursor while still giving a sense of momentum
  float velocityReductionFactor = 0.25;

  // This is in units per second
  float initialFallVelocity = 2.25;
  float maxFallVelocity = 4.5;
  float playerFallVelocity = initialFallVelocity;

  //******************************************************************************************************************************************************************************************************************
  //End of initialization, start of code
  //******************************************************************************************************************************************************************************************************************


  /**
   * Constructor
   */
  ScreenUprooted(){
    super("uprooted");

    // set up treebranches and collectibles
    populateTreeBranches();
    populateCollectibleItems();

    // set up the background image
    backdrop = loadImage("data/uprooted/Water.png");

    isMouseOut = false;

    currentAnimationFrame = 0;
    timeLeftOnAnimationFrame = timePerAnimationFrame;
    timeLeftOnHitAnimation = 0;

    skyWomanSprites = SpriteMapHandler.cutTiledSpritesheet("data/uprooted/SkywomanFall_Sprite-266x300.png", 15, 2, true);
    skyWomanHitSprites = SpriteMapHandler.cutTiledSpritesheet("data/uprooted/SkywomanHit_Sprite-266x267.png", 6, 1, true);

    // the tree trunk graphic
    trunk = loadImage("data/uprooted/Trunk.png");

    // set up the collectibles
    itemImages = new PImage[collectibleItems.length];
    itemImagesFaded = new PImage[collectibleItems.length];
    itemImagesHighlight =  new PImage[collectibleItems.length];
    for (int itemIndex = 0; itemIndex < itemImages.length; itemIndex++){
      itemImages[itemIndex] = loadImage("data/uprooted/CollectItem-0" + (itemIndex + 1) + ".png");
      itemImagesFaded[itemIndex] = loadImage("data/uprooted/CollectItem-0" + (itemIndex + 1) + "-faded.png");
      itemImagesHighlight[itemIndex] = loadImage("data/uprooted/CollectItem-0" + (itemIndex + 1) + "-highlight.png");
    }

    collectedItemTallies = new int[itemImages.length];
    maxDimensionOfTallyImages = RESOLUTIONY/collectedItemTallies.length;

    // set up the bark that moves along the trunk image
    PImage[] allBarkImages = new PImage[7];
    for (int barkIndex = 0; barkIndex < allBarkImages.length; barkIndex++){
      allBarkImages[barkIndex] = loadImage("data/uprooted/Bark-0" + (barkIndex + 1) + ".png");
    }

    barkImages = new PImage[5][];
    barkImages[0] = new PImage[3];
    barkImages[1] = new PImage[1];
    barkImages[2] = new PImage[1];
    barkImages[3] = new PImage[1];
    barkImages[4] = new PImage[1];

    barkImages[0][0] = allBarkImages[0];
    barkImages[0][1] = allBarkImages[1];
    barkImages[0][2] = allBarkImages[2];
    barkImages[1][0] = allBarkImages[3];
    barkImages[2][0] = allBarkImages[4];
    barkImages[3][0] = allBarkImages[5];
    barkImages[4][0] = allBarkImages[6];

    //Initialize other arrays based off the sizes of barkImages
    heightOfNextBark = new float[barkImages.length];
    minBarkSpacing = new float[barkImages.length];
    maxBarkSpacing = new float[barkImages.length];
    minBarkY = new float[barkImages.length][];
    maxBarkY = new float[barkImages.length][];
    for (int index = 0; index < barkImages.length; index++){
      minBarkY[index] = new float[barkImages[index].length];
      maxBarkY[index] = new float[barkImages[index].length];
    }

    //Range for y values is -285 to 885
    minBarkY[0][0] = -60;
    minBarkY[0][1] = -60;
    minBarkY[0][2] = -60;
    minBarkY[1][0] = 100;
    minBarkY[2][0] = 200;
    minBarkY[3][0] = 340;
    minBarkY[4][0] = 500;//430;

    maxBarkY[0][0] = 75;
    maxBarkY[0][1] = 75;
    maxBarkY[0][2] = 75;
    maxBarkY[1][0] = 175;
    maxBarkY[2][0] = 330;
    maxBarkY[3][0] = 470;//420;
    maxBarkY[4][0] = 525;

    minBarkSpacing[0] = 0.3;
    minBarkSpacing[1] = 0.5;
    minBarkSpacing[2] = 0.3;
    minBarkSpacing[3] = 0.5;
    minBarkSpacing[4] = 0.5;

    maxBarkSpacing[0] = 0.5;
    maxBarkSpacing[1] = 0.7;
    maxBarkSpacing[2] = 0.6;
    maxBarkSpacing[3] = 0.6;
    maxBarkSpacing[4] = 0.7;

    //Center of sprite is at 66, 75

    playerCollisionPoints = new PVector[16];
    rotatedCollisionPoints = new PVector[playerCollisionPoints.length];

    //Non-optional sprite collision points
    playerCollisionPoints[0] = new PVector(-14,-57);
    playerCollisionPoints[1] = new PVector(16,-56);
    playerCollisionPoints[2] = new PVector(10,3);
    playerCollisionPoints[3] = new PVector(10,46);
    playerCollisionPoints[4] = new PVector(-7,49);
    playerCollisionPoints[5] = new PVector(-24,0);
    playerCollisionPoints[6] = new PVector(15,-37);
    playerCollisionPoints[7] = new PVector(-21,-15);
    playerCollisionPoints[8] = new PVector(13,17);
    playerCollisionPoints[9] = new PVector(-10,35);
    playerCollisionPoints[10] = new PVector(-1,-31);
    playerCollisionPoints[11] = new PVector(-4,1);

    //optional sprite collision points
    numberOfOptionalPoints = 4;
    playerCollisionPoints[12] = new PVector(-57,-54);
    playerCollisionPoints[13] = new PVector(58,-31);
    playerCollisionPoints[14] = new PVector(55,-17);
    playerCollisionPoints[15] = new PVector(-58,-27);

    activeBarkHeights = new ArrayList();
    activeBarkTypes = new ArrayList();
    activeBarkSubtypes = new ArrayList();
    activeBarkYDestination = new ArrayList();
    activeBarkXDestination = new ArrayList();

    activeBranches = new ArrayList<TreeBranch>();
    passiveBranches = new ArrayList<TreeBranch>();

    activeBranchesRecycler = new ArrayList<TreeBranch>();
    passiveBranchesRecycler = new ArrayList<TreeBranch>();

    imagesToDraw = new ArrayList();
    imagesToDrawCoords = new ArrayList();

    playerHeight = 10000.0;

    for (int currentBark = 0; currentBark < barkImages.length; currentBark++){
      heightOfNextBark[currentBark] = playerHeight - barkSpawnHeight;
    }

    for (int initIndex = 0; initIndex < abs((int)barkSpawnHeight); initIndex++){
      for(int barkType = 0; barkType < barkImages.length; barkType++){
        addNewBark(barkType);
      }
    }

    branchImages = new PImage[8];
    cosmeticBranchImages = new PImage[8];
    for (int branchIndex = 0; branchIndex < branchImages.length; branchIndex++){
      branchImages[branchIndex] = loadImage("data/uprooted/Branch-0" + (branchIndex + 1) + ".png");
      cosmeticBranchImages[branchIndex] = loadImage("data/uprooted/Branch-0" + (branchIndex + 1) + "-cosmetic.png");
    }

    branchBaseOffsets = new PVector[branchImages.length];
    branchBaseOffsets[0] = new PVector(70,37);
    branchBaseOffsets[1] = new PVector(50,135);//(33,135);
    branchBaseOffsets[2] = new PVector(31,346);
    branchBaseOffsets[3] = new PVector(18,440);
    branchBaseOffsets[4] = new PVector(27,220);
    branchBaseOffsets[5] = new PVector(14,178);
    branchBaseOffsets[6] = new PVector(14,243);
    branchBaseOffsets[7] = new PVector(14,181);

    lowRangesForBranches = new int[branchImages.length];
    highRangesForBranches = new int[branchImages.length];

    //TODO: Clean up branch spawn height, make extra branches spawn rotated so that they disappear before collision height
    //These are where the offset branch should be displayed when at the end point on the tree trunk

    lowRangesForBranches[0] = -60;
    highRangesForBranches[0] = 500;
    lowRangesForBranches[1] = -60;
    highRangesForBranches[1] = 500;
    lowRangesForBranches[2] = -60;
    highRangesForBranches[2] = 500;
    lowRangesForBranches[3] = -60;
    highRangesForBranches[3] = 500;
    lowRangesForBranches[4] = -60;
    highRangesForBranches[4] = 500;
    lowRangesForBranches[5] = -60;
    highRangesForBranches[5] = 500;
    lowRangesForBranches[6] = -60;
    highRangesForBranches[6] = 500;
    lowRangesForBranches[7] = -60;
    highRangesForBranches[7] = 500;

    lowLimitsForCosmeticBranches = new int[branchImages.length];
    upperLimitsForCosmeticBranches = new int[branchImages.length];

    lowLimitsForCosmeticBranches[0] = -180;
    upperLimitsForCosmeticBranches[0] = 500;
    lowLimitsForCosmeticBranches[1] = -60;
    upperLimitsForCosmeticBranches[1] = 500;
    lowLimitsForCosmeticBranches[2] = 0;
    upperLimitsForCosmeticBranches[2] = 580;
    lowLimitsForCosmeticBranches[3] = 75;
    upperLimitsForCosmeticBranches[3] = 650;
    lowLimitsForCosmeticBranches[4] = 0;
    upperLimitsForCosmeticBranches[4] = 600;
    lowLimitsForCosmeticBranches[5] = 40;
    upperLimitsForCosmeticBranches[5] = 550;
    lowLimitsForCosmeticBranches[6] = -5;
    upperLimitsForCosmeticBranches[6] = 600;
    lowLimitsForCosmeticBranches[7] = 25;
    upperLimitsForCosmeticBranches[7] = 550;

    cloudImages = new PImage[5];
    for (int cloudIndex = 0; cloudIndex < cloudImages.length; cloudIndex++){
      cloudImages[cloudIndex] = loadImage("data/uprooted/Cloud-0" + (cloudIndex + 1) + ".png");
    }

    activeCloudHeights = new ArrayList();
    activeCloudTypes = new ArrayList();
    activeCloudDestinations = new ArrayList();
    activeCloudRotations = new ArrayList();
    //If the cloud goes on the other side of this point then it is no longer visible and should be cleared
    activeCloudTerminationPoints = new ArrayList();

    mobileItems = new ArrayList();
    mobileItemTimeouts = new ArrayList();
    mobileItemVelocities = new ArrayList();
    playerCollectedItems = new ArrayList();
    activeItems = new ArrayList();
    isUpPressed = false;
    isDownPressed = false;
    isLeftPressed = false;
    isRightPressed = false;
    isMousePressed = false;
    playerPosition = new PVector(RESOLUTIONX/2, RESOLUTIONY/2);
    playerVelocity = new PVector(0,0);
    lastMouse = new PVector(0,0);
    lastDrawTime = millis();
  }

  // pausing the screen does not cause anything special to happen
  void pauseScreen() {}

  // resumig the screen sets "last frame" to "now" so that we resume, instead of skip ahead
  void resumeScreen() { lastDrawTime = millis(); }

  /**
   * Draw method - this is where everything is updated before drawing, at the moment.
   * the method body can be refactored into multiple methods instead, but some care
   * must be taken not to cut up the code in a way that leaves methods lacking
   * specific values set earlier.
   */
  void drawScreen(){
    float timeElapsed = (millis() - lastDrawTime) / 1000.0;
    lastDrawTime = millis();

    // draw the background coloring
    image(backdrop,0,0);

    //Draw all of our active clouds
    //Also detect any cloud that is no longer visible and remove it from the game
    for (int cloudIndex = activeCloudHeights.size() - 1; cloudIndex >= 0; cloudIndex--){
      float currentCloudHeight = (Float)activeCloudHeights.get(cloudIndex);
      int currentCloudType = (Integer)activeCloudTypes.get(cloudIndex);
      float currentCloudRotation = (Float)activeCloudRotations.get(cloudIndex);
      PVector cloudDestination = (PVector)activeCloudDestinations.get(cloudIndex);
      PVector cloudTermination = (PVector)activeCloudTerminationPoints.get(cloudIndex);
      float heightDifference = playerHeight - currentCloudHeight;
      //Avoid any divide by 0 problems
      if (heightDifference == 0){
        heightDifference = 0.0001;
      }
      //Reduce the height and width of the image because of its distance from the player
      int imageHeight = (int)(cloudImages[currentCloudType].height / heightDifference);
      int imageWidth = (int)(cloudImages[currentCloudType].width / heightDifference);
      //Should be 1/heightDifference of the way from spawn to destination
      //Get y difference between spawn and destination
      int cloudX = (int)(cloudSpawnPoint.x - ((float)(cloudSpawnPoint.x - cloudDestination.x))/heightDifference);
      int cloudY = (int)(cloudSpawnPoint.y - ((float)(cloudSpawnPoint.y - cloudDestination.y)/heightDifference));

      if ((abs(cloudX) < abs(cloudTermination.x)) || (abs(cloudY) < abs(cloudTermination.y))){
        pushMatrix();
        translate(cloudX,cloudY);
        rotate(currentCloudRotation);
        image(cloudImages[currentCloudType],-imageWidth/2,-imageHeight/2,imageWidth,imageHeight);
        popMatrix();
      }else{
        activeCloudRotations.remove(cloudIndex);
        activeCloudHeights.remove(cloudIndex);
        activeCloudTypes.remove(cloudIndex);
        activeCloudDestinations.remove(cloudIndex);
        activeCloudTerminationPoints.remove(cloudIndex);
      }
    }

    // Draw passive branches behind the tree trunk
    for (int branchIndex = passiveBranches.size() - 1; branchIndex >= 0; branchIndex--){
      TreeBranch branch = ((TreeBranch)passiveBranches.get(branchIndex));
      if (branch.getHeight()+1 > playerHeight) {
        passiveBranches.remove(branchIndex);
        passiveBranchesRecycler.add(branch);
      } else {
        branch.draw(playerHeight);
      }
    }

    // draw the tree trunk
    image(trunk,0,0);

    //The acceleration here is an approximation of an actual acceleration- an orbit around the mouse cursor here is actually composed of short line segments rather than a true curve. But this is accurate enough for making the sky mother fly around.
    float accelerationDirection;
    PVector accelerationUnit;
    //Accelerate if the mouse is pressed, otherwise slow to a stop
    if (isMousePressed && !isMouseOut){
      //accelerationDirection = atan2(lastMouse.y - playerPosition.y, lastMouse.x - playerPosition.x);
      accelerationUnit = PVector.sub(lastMouse, playerPosition);
      accelerationUnit.normalize();

    }else if ((!isMousePressed && !isUpPressed && !isDownPressed && !isLeftPressed && !isRightPressed) || isMouseOut){
      accelerationUnit = PVector.mult(playerVelocity, -1);
      accelerationUnit.normalize();
    }else{
      accelerationUnit = new PVector(0,0);
    }

    /**
     * Process movement controls
     */
    if (isUpPressed) { accelerationUnit.add(new PVector(0,-1)); }
    if (isDownPressed) { accelerationUnit.add(new PVector(0,1)); }
    if (isLeftPressed) { accelerationUnit.add(new PVector(-1,0)); }
    if (isRightPressed) { accelerationUnit.add(new PVector(1,0)); }

    float tempAccelerationRate = playerAccelerationRate;
    float totalVelocity = playerVelocity.mag();

    // If we are slowing to a stop and the acceleration will take them beyond a stop then reduce the acceleration to that needed to stop
    if ((isMouseOut || (!isMousePressed && !isUpPressed && !isDownPressed && !isLeftPressed && !isRightPressed)) && (tempAccelerationRate * timeElapsed) > totalVelocity){
      tempAccelerationRate = totalVelocity/timeElapsed;
    }

    PVector startVelocity = playerVelocity.get();

    //It's possible, by pressing two contradictory arrow keys, for the player to not have any acceleration but still maintain their velocity. This checks for that case
    if (accelerationUnit.mag() != 0.0){
      accelerationDirection = accelerationUnit.heading2D();
      PVector acceleration = new PVector(tempAccelerationRate * cos(accelerationDirection), tempAccelerationRate * sin(accelerationDirection));

      //Reduce the velocity by the velocity factor * acceleration for this turn
      float velocityReductionAmount = (PVector.mult(acceleration, (timeElapsed * velocityReductionFactor))).mag();
      PVector oppositeVelocity = PVector.mult(playerVelocity, -1);
      oppositeVelocity.normalize();
      oppositeVelocity.mult(velocityReductionAmount);
      playerVelocity.add(oppositeVelocity);

      if ((!isMousePressed && !isUpPressed && !isDownPressed && !isLeftPressed && !isRightPressed) || isMouseOut){
        playerVelocity.add(PVector.mult(acceleration, timeElapsed * 0.4));
      }else{
        playerVelocity.add(PVector.mult(acceleration, timeElapsed));
      }
    }
    playerVelocity.limit(playerMaxVelocity);

    //Because the player is accelerating we must apply their average speed over the frame to get their true position instead of taking the start or end speeds
    PVector intervalVelocity = PVector.div(PVector.add(startVelocity, playerVelocity),2.0);

    //Determine player's final position
    playerPosition.add(PVector.mult(intervalVelocity, timeElapsed));

    //Keep the player's position within the bounds of the screen, snapping velocity back to 0 if they go off the edge
    if (playerPosition.x < 0){
      playerPosition.x = 0;
      playerVelocity.x = 0;
    }else if (playerPosition.x > RESOLUTIONX - maxDimensionOfTallyImages){
      playerPosition.x = RESOLUTIONX - maxDimensionOfTallyImages;
      playerVelocity.x = 0;
    }
    if (playerPosition.y < 0){
      playerPosition.y = 0;
      playerVelocity.y = 0;
    }else if (playerPosition.y > RESOLUTIONY){
      playerPosition.y = RESOLUTIONY;
      playerVelocity.y = 0;
    }

    //Reduce the player's height by the amount that they fell during the frame
    playerHeight -= playerFallVelocity * timeElapsed;

    //Take the x component of the player's velocity. Ratio of player's x velocity/max velocity * pi/4 radians (45 degrees) is how much we want to rotate.
    float spriteRotationAmount = (playerVelocity.x/playerMaxVelocity) * PI/4;

    //Generate our rotated set of player collision points;
    float cosRotation = cos(spriteRotationAmount);
    float sinRotation = sin(spriteRotationAmount);
    for (int pointIndex = 0; pointIndex < playerCollisionPoints.length; pointIndex++){
      //Just a standard rotation matrix here
      float rotatedX = playerCollisionPoints[pointIndex].x*cosRotation - playerCollisionPoints[pointIndex].y*sinRotation;
      float rotatedY = playerCollisionPoints[pointIndex].x*sinRotation + playerCollisionPoints[pointIndex].y*cosRotation;
      rotatedCollisionPoints[pointIndex] = new PVector(rotatedX, rotatedY);
    }

    //Generate any new bark
    for (int barkCheckNumber = 0; barkCheckNumber < barkImages.length; barkCheckNumber++){
      while (heightOfNextBark[barkCheckNumber] > playerHeight){
        addNewBark(barkCheckNumber);
      }
    }

    //Draw all of our active pieces of bark
    //Also detect any bark that is no longer visible and remove it from the game
    for (int barkIndex = activeBarkHeights.size() - 1; barkIndex >= 0; barkIndex--){
      float currentBarkHeight = (Float)activeBarkHeights.get(barkIndex);
      int currentBarkType = (Integer)activeBarkTypes.get(barkIndex);
      int currentBarkSubtype = (Integer)activeBarkSubtypes.get(barkIndex);
      int barkYDestination = (Integer)activeBarkYDestination.get(barkIndex);
      int barkXDestination = (Integer)activeBarkXDestination.get(barkIndex);
      float heightDifference = playerHeight - currentBarkHeight;
      //Avoid any divide by 0 problems
      if (heightDifference == 0){
        heightDifference = 0.0001;
      }

      if (heightDifference >= 0){
        //Reduce the height and width of the image because of its distance from the player
        int imageHeight = (int)(barkImages[currentBarkType][currentBarkSubtype].height / heightDifference);
        int imageWidth = (int)(barkImages[currentBarkType][currentBarkSubtype].width / heightDifference);
        //Should be 1/heightDifference of the way from spawn to destination
        //Get y difference between spawn and destination
        int barkX = (int)(barkSpawnPoint.x - ((float)(barkSpawnPoint.x - barkXDestination))/heightDifference);
        int barkY = (int)(barkSpawnPoint.y - ((float)(barkSpawnPoint.y - barkYDestination)/heightDifference));
        image(barkImages[currentBarkType][currentBarkSubtype],barkX,barkY - imageHeight/2,imageWidth,imageHeight);
      }else{
        activeBarkHeights.remove(barkIndex);
        activeBarkTypes.remove(barkIndex);
        activeBarkSubtypes.remove(barkIndex);
        activeBarkXDestination.remove(barkIndex);
        activeBarkYDestination.remove(barkIndex);
      }
    }

    //Generate any new clouds
    if (random(0,1) < chanceOfCloud*timeElapsed*(playerFallVelocity/maxFallVelocity)){
      int cloudType = (int)random(0,cloudImages.length);
      PImage currentCloudImage = cloudImages[cloudType];
      float angle = random(minCloudAngle, maxCloudAngle);
      //The sqrt guarantees equal distribution over the circle instead of having the clouds be clustered towards the center
      float distance = sqrt(random(0,1)) * random(0, cloudMaxRange);
      float terminationDistance = maxDistanceToScreenEdge + minimumCloudDistanceOffscreen;
      distance+=maxDistanceToScreenEdge + minimumCloudDistanceOffscreen;
      terminationDistance= distance;
      PVector cloudDestination = new PVector(int(distance * cos(angle)) + cloudSpawnPoint.x, int(distance * sin(angle)) + cloudSpawnPoint.y);
      PVector cloudTermination = new PVector(int(terminationDistance * cos(angle)) + cloudSpawnPoint.x, int(distance * sin(angle)) + cloudSpawnPoint.y);
      activeCloudHeights.add(playerHeight + cloudSpawnHeight);
      activeCloudTypes.add(cloudType);
      activeCloudDestinations.add(cloudDestination);
      activeCloudRotations.add(angle + PI/2.0);
      activeCloudTerminationPoints.add(cloudTermination);
    }

    //Generate any items to add to the scene
    if (random(0,1) < chanceOfCollectibleItem*timeElapsed*(playerFallVelocity/maxFallVelocity)){
      int itemType = (int)random(0,collectibleItems.length);
      float rotation = random(0, 2*PI);
      activeItems.add(new CollectibleItem(itemType, itemSpawnPoint,new PVector(random(0,RESOLUTIONX - maxDimensionOfTallyImages),random(0,RESOLUTIONY)), playerHeight + itemSpawnHeight, itemImages[itemType], itemImagesHighlight[itemType], rotation));
    }

    //Generate any tree branches to add to the scene
    if (random(0,1) < chanceOfTreeBranch*timeElapsed*(playerFallVelocity/maxFallVelocity)){
      addNewTreeBranch(false);
    }

    //Generate any cosmetic tree branches to add to the scene
    if (random(0,1) < chanceOfCosmeticTreeBranch*timeElapsed*(playerFallVelocity/maxFallVelocity)){
      addNewTreeBranch(true);
    }

    //Our mobile items are the collection of items that have been knocked off of the player by tree branches.
    //They are not collectible and travel in straight lines until they disappear
    for (int mobileItemIndex = mobileItems.size() - 1; mobileItemIndex >= 0; mobileItemIndex--){
      CollectibleItem currentMobileItem = (CollectibleItem)mobileItems.get(mobileItemIndex);
      PVector currentVelocity = (PVector)mobileItemVelocities.get(mobileItemIndex);
      Float currentTimeout = (Float)mobileItemTimeouts.get(mobileItemIndex);
      currentTimeout-=timeElapsed;
      mobileItemTimeouts.set(mobileItemIndex,currentTimeout);
      if (currentTimeout < 0){
        mobileItemTimeouts.remove(mobileItemIndex);
        mobileItemVelocities.remove(mobileItemIndex);
        mobileItems.remove(mobileItemIndex);
      }else{
        currentMobileItem.addPosition(PVector.mult(currentVelocity, timeElapsed));
        currentMobileItem.draw();
      }
    }

    //Draw every branch and perform collision detection on ones that are at the player's height.
    //Also remove branches that are above the player's height
    //Note that the height of the branch is effectively reduced by 1 in all calculations because extremely rapid scaling of image size
    //happen with our perspective calculations when the difference in heights is less than 1
    for (int branchIndex = activeBranches.size() - 1; branchIndex >= 0; branchIndex--){
      TreeBranch activeTreeBranch = ((TreeBranch)activeBranches.get(branchIndex));
      float currentHeight = activeTreeBranch.getHeight();
      if ((currentHeight + 1) >= playerHeight){
        boolean branchCollides = false;
        //The player cannot collide if she's still in a hit animation
        if (timeLeftOnHitAnimation < 0){
          //Since she's not in a hit animation run skywoman's collision points through the collision detection for the current tree branch until one collides or none of them do
          for (int pointIndex = 0; pointIndex < rotatedCollisionPoints.length - numberOfOptionalPoints; pointIndex++){
            if (activeTreeBranch.collides(PVector.add(playerPosition, rotatedCollisionPoints[pointIndex]))){
              branchCollides = true;
              pointIndex = rotatedCollisionPoints.length;
            }
          }
        }
        if (branchCollides){
          //When we smack a branch the player has some instant velocity added to their current velocity
          addPlayerHitVelocity();
          //If not already in the hit animation we should go into it and set our current animation frame and stuff to 0
          if (timeLeftOnHitAnimation <= 0){
            currentAnimationFrame = 0;
            timeLeftOnAnimationFrame = timePerAnimationFrameHit;
            animationIterateOrder = 1;
          }
          timeLeftOnHitAnimation = timeToUseHitAnimation;

          // lose an item based on the "You might lose medicine" text - there's a 50/50 chance that you lose nothing
          // Remove the last item the player picked up and place it in the mobileitems collection at a semi-random velocity and angle
          if(random(1)>chanceToLoseCollectedItem) {
            for (int removalIndex = 0; removalIndex < playerHitPenalty; removalIndex++){
              if (playerCollectedItems.size() != 0){
                CollectibleItem toDrop = (CollectibleItem)playerCollectedItems.get(playerCollectedItems.size() - 1);
                playerCollectedItems.remove(playerCollectedItems.size() - 1);
                collectedItemTallies[toDrop.getItemType()]--;
                mobileItems.add(toDrop);
                mobileItemTimeouts.add(mobileItemLifespan);
                toDrop.setPosition(playerPosition);

                float speed = random(minItemSpeed, maxItemSpeed);
                float angle = random(0,2*PI);
                float xReturn = speed * cos(angle);
                float yReturn = speed * sin(angle);
                PVector mobileVel = new PVector(xReturn, yReturn);
                mobileItemVelocities.add(mobileVel);
              }
            }
          }
        }else{
          //We didn't hit the branch when it was at our height! Draw it one last time
          activeTreeBranch.draw();
        }
        //Now remove the branch because it will be too high to be visible next frame
        activeBranches.remove(branchIndex);
        activeBranchesRecycler.add(activeTreeBranch);
      }else{
        //Branch is still somewhere below us, draw it normally
        activeTreeBranch.draw(playerHeight);
      }
    }

    //Draw, at a scaled value, all activeItems that are below our height
    //Draw unscaled any activeItems that are at or above our height by less than 5 and do collision detection on them
    //Despawn any activeItems that are above our height by >=5
    //Active items are collectible items that the player hasn't picked up yet
    for (int currentItemIndex = activeItems.size() - 1; currentItemIndex >= 0; currentItemIndex--){
      Float currentHeight = ((CollectibleItem)activeItems.get(currentItemIndex)).getHeight();
      if ((currentHeight + 1) >= (playerHeight + 3)){
        activeItems.remove(currentItemIndex);
      }else if ((currentHeight + 1) < (playerHeight + 3) && (currentHeight + 1) >= playerHeight){
        CollectibleItem currentItem = ((CollectibleItem)activeItems.get(currentItemIndex));
        boolean itemCollides = false;
        //Player cannot collide with anything during their hit animation
        if (timeLeftOnHitAnimation < 0){
          for (int pointIndex = 0; pointIndex < rotatedCollisionPoints.length; pointIndex++){
            if (currentItem.collides(PVector.add(playerPosition, rotatedCollisionPoints[pointIndex]))){
              itemCollides = true;
              pointIndex = rotatedCollisionPoints.length;
            }
          }
        }
        if (itemCollides){
          playerCollectedItems.add(currentItem);
          collectedItemTallies[currentItem.getItemType()]++;
          activeItems.remove(currentItemIndex);
        }else{
          stroke(70,255,70);
          currentItem.draw();
        }
      }else{
        CollectibleItem currentItem = ((CollectibleItem)activeItems.get(currentItemIndex));
        stroke(0,0,0);
        currentItem.draw(playerHeight);
      }
    }

    stroke(0,0,0);

    //Figure out which set of sprites we are using and what the right timings are for their animations
    float animationTiming = timeElapsed;
    timeLeftOnHitAnimation -= timeElapsed;
    int currentSpriteArrayLength;
    if (timeLeftOnHitAnimation >= 0){
      currentSpriteArrayLength = skyWomanHitSprites.length;
    }else{
      currentSpriteArrayLength = skyWomanSprites.length;
    }

    float currentTimePerAnimationFrame;
    if (timeLeftOnHitAnimation >= 0){
      currentTimePerAnimationFrame = timePerAnimationFrameHit;
    }else{
      currentTimePerAnimationFrame = timePerAnimationFrame;
    }
    //Figure out which sprite is correct by iterating forwards/backwords through their arrays until you reach the appropriate one for the amount of time that has passed
    while (animationTiming > 0) {
      if (animationTiming > timeLeftOnAnimationFrame) {
        animationTiming-=timeLeftOnAnimationFrame;
        timeLeftOnAnimationFrame = currentTimePerAnimationFrame;
        currentAnimationFrame += animationIterateOrder;
        //If we've gone past the end of the sprite array then go to the last position - 1 and start going through the array the other way
        //Note that the animators stuck a bad frame at the end, so we're actually stopping one short in order to skip that one
        if (currentAnimationFrame == currentSpriteArrayLength - 1) {
          currentAnimationFrame -= 2;
          animationIterateOrder = -1;
        }
        if (currentAnimationFrame == -1){
          currentAnimationFrame += 2;
          animationIterateOrder = 1;
        }
      }
      else {
        timeLeftOnAnimationFrame-=animationTiming;
        animationTiming = 0;
      }
    }

    //Draw skywoman sprite
    pushMatrix();
    translate(playerPosition.x, playerPosition.y);
    //This is calculated much further up in this method
    rotate(spriteRotationAmount);
    if (timeLeftOnHitAnimation >= 0){
      image(skyWomanHitSprites[currentAnimationFrame], -(skyWomanHitSprites[currentAnimationFrame].width / 2), -(skyWomanHitSprites[currentAnimationFrame].height/2));
    }else{
      image(skyWomanSprites[currentAnimationFrame], -(skyWomanSprites[currentAnimationFrame].width / 2), -(skyWomanSprites[currentAnimationFrame].height/2));
    }
    popMatrix();

//    //Uncommenting this will result in small squares being drawn over the sprite's collision points. USEFUL FOR DEBUGGING
//    rectMode(CENTER);
//    for (int pointIndex = 0; pointIndex < rotatedCollisionPoints.length; pointIndex++){
//      PVector actualPoint = PVector.add(rotatedCollisionPoints[pointIndex], playerPosition);
//      rect(actualPoint.x, actualPoint.y, 3, 3);
//    }
//    rectMode(CORNER);

    //Draw the HUD on the right side which shows which items have been collected and which items need to be collected
    pushMatrix();
    imageMode(CENTER);
    noStroke();
    fill (255, 96);
    //Draw a backing rectangle for the HUD
    rect(RESOLUTIONX - maxDimensionOfTallyImages,0,maxDimensionOfTallyImages,600);
    boolean allItemsCollected = true;
    int numberOfCategoriesCollected = collectedItemTallies.length;
    for(int itemIndex = 0; itemIndex < itemImages.length; itemIndex++){
      PImage currentImage = itemImages[itemIndex];
      float resizeRatio = 1.0;
      //If our current item image is too big to fit in the little box we have for it, then figure out how much we need to shrink it by
      if (currentImage.width > currentImage.height && currentImage.width > maxDimensionOfTallyImages){
        //If the 1.0 is removed from this or the one a few lines down then it does integer division, resulting in a resizeRatio of 0.
        resizeRatio = maxDimensionOfTallyImages/(currentImage.width * 1.0);
      }else if (currentImage.height >= currentImage.width && itemImages[itemIndex].height > maxDimensionOfTallyImages){
        resizeRatio = maxDimensionOfTallyImages/(currentImage.height * 1.0);
      }
      //This will cause the current image to appear centered in a region at the right side of the screen.
      //Each image will be centered on the same line parallel to the y axis, and will be equally spaced down the screen
      if (collectedItemTallies[itemIndex] == 0){
        image(itemImagesFaded[itemIndex],
              RESOLUTIONX - maxDimensionOfTallyImages / 2,
              maxDimensionOfTallyImages / 2 + maxDimensionOfTallyImages * itemIndex,
              currentImage.width * resizeRatio,
              currentImage.height * resizeRatio);
         allItemsCollected = false;
         numberOfCategoriesCollected--;
      }else{
        fill(255);
        int xCoord = RESOLUTIONX - maxDimensionOfTallyImages / 2;
        int yCoord = maxDimensionOfTallyImages / 2 + maxDimensionOfTallyImages * itemIndex;
        float curWidth = currentImage.width * resizeRatio;
        float curHeight = currentImage.height * resizeRatio;
        image(currentImage,
              xCoord,
              yCoord,
              curWidth,
              curHeight);
        text(collectedItemTallies[itemIndex], width-10, yCoord + curHeight/2 - 3);
      }

    }
    popMatrix();
    imageMode(CORNER);

    //Make the player fall faster as they collect more categories of items
    if (numberOfCategoriesCollected == 0){
      playerFallVelocity = initialFallVelocity;
    }else{
      playerFallVelocity = initialFallVelocity + (maxFallVelocity - initialFallVelocity)/(collectedItemTallies.length - numberOfCategoriesCollected);
    }

    if (allItemsCollected){
      playerFallVelocity = maxFallVelocity;
      //If this point is reached then the player has won!
      setFinished(true, loadImage("data/general/endScreens/" + (javascript!=null && javascript.getLanguage()=="french" ? "french/" : "") + "uprooted.png"));
    }
  }

  //This gets the x coordinate on the circle of the tree trunk for the given y coordinate
  float getXDestinationForY(float yDestination, boolean isCosmetic){
    float yDestinationCenteredAboutTrunk = yDestination - barkEndPoint.y;
    //This is the positive root, not the negative root, so it'll be on the positive (visible) side of the tree trunk
    float xCoordOnCircle = sqrt((treeRadius*treeRadius) - (yDestinationCenteredAboutTrunk * yDestinationCenteredAboutTrunk));
    // if this is for a cosmetic branch, we also want to generate X coordinates
    // on the left side/behind the trunk. So, we make the x coordinate negative
    // every now and then to mirror it about the trunk origin.
    if(isCosmetic && random(1)>0.5) { xCoordOnCircle = -xCoordOnCircle; }
    float returnValue = xCoordOnCircle + barkEndPoint.x;
    return returnValue;
  }

  /**
   * Add a new branch to the collection of passive/active branches
   */
  void addNewTreeBranch(boolean isCosmetic){
    int branchType = (int)random(0,treeBranches.length);
    float branchYDestination;

    // These branches do not interact with the player (they will be added to the passive list)
    if (isCosmetic){
      // lower hemisphere
      if (random(1) < 0.5){
        branchYDestination = random(lowestYPointOnCircle, lowLimitsForCosmeticBranches[branchType]);
      }
      // upper hemisphere
      else{
        branchYDestination = random(upperLimitsForCosmeticBranches[branchType], highestYPointOnCircle);
      }
    }

    // These branches do interact (they will be added to the active list)
    else{ branchYDestination = random(lowRangesForBranches[branchType], highRangesForBranches[branchType]); }

    float branchXDestination = getXDestinationForY(branchYDestination, isCosmetic);
    PVector endPoint = new PVector(branchXDestination, branchYDestination);
    float newHeight = playerHeight + branchSpawnHeight;
    float angleOfTreeAtDestination = 0;
    if (isCosmetic){ angleOfTreeAtDestination = atan((branchYDestination - barkEndPoint.y)/(branchXDestination - barkEndPoint.x)); }

    // fetch image for this branch and build it. Cosmetic branches have darker foliage.
    PImage branchImage = (isCosmetic ? cosmeticBranchImages[branchType] : branchImages[branchType]);
    // if this is a cosmetic branch that is places to the left of the tree, we need to make
    // sure the image for it is rotated 180 degrees
    if(isCosmetic && (branchXDestination - barkEndPoint.x) < 0) { angleOfTreeAtDestination += PI; }


    TreeBranch newBranch;
    if (isCosmetic && passiveBranchesRecycler.size()>0) {
      newBranch = passiveBranchesRecycler.remove(0);
      newBranch.reset(branchType, branchSpawnPoint, endPoint, playerHeight + branchSpawnHeight, branchBaseOffsets[branchType], branchImage, angleOfTreeAtDestination);
    } else if (activeBranchesRecycler.size()>0) {
      newBranch = activeBranchesRecycler.remove(0);
      newBranch.reset(branchType, branchSpawnPoint, endPoint, playerHeight + branchSpawnHeight, branchBaseOffsets[branchType], branchImage, angleOfTreeAtDestination);
    } else {
      newBranch = new TreeBranch(branchType, branchSpawnPoint, endPoint, playerHeight + branchSpawnHeight, branchBaseOffsets[branchType], branchImage, angleOfTreeAtDestination);
    }

    // Add branch to either passive or active list
    if(isCosmetic) { passiveBranches.add(newBranch); } else { activeBranches.add(newBranch); }
  }

  void addNewBark(int barkType){
    activeBarkHeights.add(heightOfNextBark[barkType] + barkSpawnHeight);
    activeBarkTypes.add(barkType);
    int barkSubtype = (int)random(0,barkImages[barkType].length);
    activeBarkSubtypes.add(barkSubtype);
    float yDestination = random(minBarkY[barkType][barkSubtype], maxBarkY[barkType][barkSubtype]);
    //These are index-matched arraylists, so we're appending the destination, not adding it to some other number or something
    activeBarkYDestination.add((int)yDestination);
    activeBarkXDestination.add((int)getXDestinationForY(yDestination, false));

    float nextBarkSpacing = random(minBarkSpacing[barkType],maxBarkSpacing[barkType]);
    heightOfNextBark[barkType] -= nextBarkSpacing;
  }

  void addPlayerHitVelocity(){
    float speed = random(minPlayerHitVelocity, maxPlayerHitVelocity);
    float angle = random(0,2*PI);
    float xReturn = speed * cos(angle);
    float yReturn = speed * sin(angle);
    playerVelocity.add(new PVector(xReturn,yReturn));
  }

// =========

  void keyPressed(char key, int keyCode){
    if (key == CODED) {
      if (keyCode == UP) {
        isUpPressed = true;
      }
      else if (keyCode == DOWN) {
        isDownPressed = true;
      }
      else if (keyCode == LEFT) {
        isLeftPressed = true;
      }
      else if (keyCode == RIGHT) {
        isRightPressed = true;
      }
    }
  }

  void keyReleased(char key, int keyCode){
    if (key == CODED) {
      if (keyCode == UP) {
        isUpPressed = false;
      }
      else if (keyCode == DOWN) {
        isDownPressed = false;
      }
      else if (keyCode == LEFT) {
        isLeftPressed = false;
      }
      else if (keyCode == RIGHT) {
        isRightPressed = false;
      }
    }
  }

  void mouseReleased(int x, int y) {
    isMousePressed = false;
  }

  void mouseDragged(int x, int y){
    lastMouse.x = x;
    lastMouse.y = y;
    isMouseOut = false;
  }

  void mousePressed(int x, int y){
    isMousePressed = true;
    lastMouse.x = x;
    lastMouse.y = y;
  }

  void mouseOut(){
    isMouseOut = true;
  }

  void mouseMoved(){
    if (isMouseOut){
      isMouseOut = false;
      isMousePressed = false;
    }
  }

// =========

  //This method is intended to be used to reset assets that can be changed on other screens (like dragons) to their correct positions and sizes
  void reset(){
    lastDrawTime = millis();
  }

  void loadambient(){
    SoundPlayer.load(this, "data/audio/Uprooted.mp3");
  }

  String getHelpContent() {
    String english = "Collect all the medicines by clicking where Sky woman should fall towards\n"+
           "but be careful! If you hit light green branches, you might lose medicine!";
    String french = english;
    if(javascript!=null && javascript.getLanguage()=="french") return french;
    return english;
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
