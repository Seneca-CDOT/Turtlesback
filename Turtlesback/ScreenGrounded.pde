/**
 * A DDR-style game, where the player has to hit the
 * directions of the medicine wheel in sync with a
 * musical track. Every time they get a number of
 * correct hits in succession, Sky woman will dance,
 * and a piece of turtle island is added to the turtle's
 * back. The game ends when all pieces have been
 * accumulated.
 */
class ScreenGrounded extends Screen {
  // replaces background image with debug coloring
  boolean debug = false;

  // guidelines for each note
  ArrayList<GuideLine> guideLines = new ArrayList<GuideLine>();
 
  // visual cue coordinates
  int distance_x = 200;
  int distance_y = 0;
  int[] midpoint;

  // image assets
  PImage backDrop, medicineWheel, turtleIslandOutline, turtleIslandEnd;
  PImage arrows[] = new PImage[4];
  PImage[] turtlesBrown = new PImage[10];
  PImage[] turtlesGreen = new PImage[10];
  PImage[] skyWomanDance = new PImage[12];
  PImage[] skyWomanMask = new PImage[12];
  
  /*x,y coordinate relative to the outline image of each piece of turtle island*/
  int [] islandX={61,80,111,191,228,227,230,213,127,15};
  int [] islandY={138,238,264,259,249,199,128,11,8,49};
  
  int islandOffsetX=width/2+90;
  int islandOffsetY=10;
  int currentTurtleTile;
  float currentHitCount, requiredHitCount, halfRequiredHitCount;
  boolean greenTile;
  int currPose; //index of pose to show
  // sky woman animations
  SpriteFactory SkyWomanStanding;

  // debug backgroound color
  color bgcolor = color(200,200,255);

  // context switch for DDR vs. animation
  private final int DDR=0, DANCING=1;

  private int mode;
  private int modeSwitch;

  float skyWomanBaseHeight;
  // time sync information
  int[] timing;
  int timingPos;
  boolean pauseNotes;
  boolean gameover=false;
  int danceX, danceY; //location of feet of skywoman

  /**
   * Constructor
   */
  ScreenGrounded() {
    super("grounded");

    backDrop = loadImage("data/grounded/turtlesback_grounded_bg.png");

    medicineWheel = loadImage("data/grounded/medicinewheel.png");
    arrows[0] = loadImage("data/grounded/medicinewheel_arrowsyellow.png");
    arrows[1] = loadImage("data/grounded/medicinewheel_arrowsblack.png");

    arrows[2] = loadImage("data/grounded/medicinewheel_arrowsred.png");
    arrows[3] = loadImage("data/grounded/medicinewheel_arrowswhite.png");
    turtleIslandOutline = loadImage("data/grounded/Turtle Island/pieces/start.png");
    turtleIslandEnd = loadImage("data/grounded/Turtle Island/Turtle_Island_11_End.png");
    
    for(int i=0, j=1; i<10; i++) {
      j=i+1;
      turtlesBrown[i] = loadImage("data/grounded/Turtle Island/pieces/brown/piece-"+(j<10 ? "0":"") + j + ".png");
      turtlesGreen[i] = loadImage("data/grounded/Turtle Island/pieces/green/piece-"+(j<10 ? "0":"") + j + ".png");
    }

    SkyWomanStanding = new SpriteFactory("data/grounded/SkywomanIdle.png",20,1,true,"center","center",3*width/4,height/2-40,true);
    for(int i=0, j=1; i<12; i++) {
      j=i+1;
      skyWomanDance[i] = loadImage("data/grounded/poses/colored/static-"+(j<10 ? "0":"") + j + ".png");
      skyWomanMask[i] = loadImage("data/grounded/poses/silhouette/static-"+(j<10 ? "0":"") + j + ".png");
    }

    initialise();
  }

  void initialise() {
    skyWomanBaseHeight = 300;
    danceX = (width/4)*3;
    danceY = height-50;
    currPose = 0;
    pauseNotes = false;

    midpoint = new int[]{width/4+50, height/2};
    float[] endpoint;
    float[] angles = {0, PI/2, PI, 3*PI/2};
    float[] ctrpt1;
    float[] ctrpt2;
    float [] startpoint;

    float cosa;
    float sina;
    color[] co={color(255,204,0),color(0,0,0),color(204,0,0),color(255,255,255)};
    color[] tbc={color(255,204,0),color(0,0,0),color(204,0,0),color(127)};
    color[] fillco={color(255,255,255,144),color(255,255,255,144),color(255,255,255,144),color(255,255,255,144)};
    float rx=random(50,100);
    float ry=random(-30,30);
    int i=0;
    float[] offsetX={13,0,-10,0};
    float []offsetY={0,5,0,-5};
    for(float a: angles) {
      cosa=cos(a);
      sina=sin(a);

      rx = random(40,80);
      ry = (random(0,1)>0.5)?1:-1+random(20,50);
      endpoint   = new float[]{midpoint[0] + distance_x*cosa - distance_y*sina, midpoint[1] + distance_x*sina + distance_y*cosa};
      startpoint = new float[]{midpoint[0] + 40*cosa-0*sina, midpoint[1] + 40*sina + 0*cosa};
      // control point 1
      ctrpt1     = new float[]{startpoint[0] + rx*cosa-ry*sina, startpoint[1] + rx*sina + ry*cosa};
      // control point 2 uses slightly different random coordinates
      rx = random(80,120);
      ry = ((random(0,1)>0.5)?1:-1)+random(30,50);
      ctrpt2 = new float[]{startpoint[0]+ rx*cosa-ry*sina, startpoint[1] + rx*sina + ry*cosa};
      guideLines.add(new GuideLine(startpoint[0], startpoint[1],
                                   ctrpt1[0], ctrpt1[1],
                                   ctrpt2[0], ctrpt2[1],
                                   endpoint[0], endpoint[1],
                                   co[i], arrows[i], offsetX[i], offsetY[i],fillco[i],sina,cosa,tbc[i]));
      i++;
    }
    currentTurtleTile = 10;
    greenTile = true;
    currentHitCount = 0;
    halfRequiredHitCount=5;
    requiredHitCount = 10;
    mode = DDR;

    // load all the timestamps
    String[] data = loadStrings("data/grounded/timing.txt");
    timing = new int[data.length];
    for(int s=0, e=data.length; s<e; s++) { timing[s] = 20 + int(data[s]); }
    timingPos = 0;
  }

  /**
   * draw method
   */
  void drawScreen() {
    pushStyle();
    if (mode == DDR) {
      image(backDrop, 0,0);
      drawMusicSystem();
      drawDanceSystem();
    }
    else if (mode == DANCING) {      
      image(backDrop, 0,0);
      drawMusicSystem();
      drawDanceSystem();
      drawDanceAnimation();
    }
    popStyle();
  }

  /**
   * DDR part of the game
   */
  void drawMusicSystem() {
    // try to add a new quarter note cue
    int soundPosition = SoundPlayer.getPosition(this);
    // fast forward through DANCING mode timing skips
    if (timingPos==timing.length)
      timingPos=0;
    while(soundPosition >= timing[timingPos+1]) { timingPos++; }
    // update if quarternote passed
    if(pauseNotes==false){
      if(soundPosition >= timing[timingPos]) { timingPos++; addCue(); }
    }

    // medicine wheel
    float currentInterval = timing[timingPos] - (timingPos>0 ? timing[timingPos-1] : 0),
          currentProgress = soundPosition - timing[timingPos];
    float pulseScale = 2.0 + 0.5 * sin(currentProgress/currentInterval * PI);
    
    // cues

    for(GuideLine g: guideLines) {
      g.setPulse(pulseScale);
      g.draw();
    }
    imageMode(CENTER);
    image(medicineWheel, midpoint[0], midpoint[1], 30*pulseScale, 30*pulseScale);
    imageMode(CORNER);
//  image(medicineWheel, midpoint[0] - medicineWheel.width/2+15, midpoint[1] - medicineWheel.height/2+15, (medicineWheel.width-30), (medicineWheel.height-30));
  }

  /**
   * Sky woman idling, dancing, and the turtle world forming
   */
  void drawDanceSystem() {
    int missed=0;
    if(debug) {
      fill(0,0,100);
      rect(width/2,0,width/2,height);
    }
    for(GuideLine g: guideLines) {
      missed+=g.missed;
      g.missed=0;
    }
    if(currentHitCount >= 5){
      currentHitCount=max(0,currentHitCount-missed);
      if(currentHitCount < 5){   //if we crossed back over the line, update the tile counter
        greenTile=!greenTile;
        currentTurtleTile--;
      }
    }
    else{
      currentHitCount=max(0, currentHitCount-missed);
    }
    if(gameover==true){
      image(turtleIslandEnd, islandOffsetX+5, islandOffsetY+2);
    }
    else{
      if(currentTurtleTile <= 11){
        for(int i=0;i<min(currentTurtleTile,10);i++){
          image(turtlesGreen[i], islandOffsetX+islandX[i], islandOffsetY+islandY[i]);
        }
        if(currentTurtleTile > 0 && currentTurtleTile<= 10 && !greenTile){
           image(turtlesBrown[currentTurtleTile-1], islandOffsetX+islandX[currentTurtleTile-1], islandOffsetY+islandY[currentTurtleTile-1]);
        }
        /*draw turtleIsland*/
        image(turtleIslandOutline, islandOffsetX, islandOffsetY);
      }
    }

    if(mode==DDR){
    // Sky woman
      SkyWomanStanding.draw();
    }

    // progress bar: blocks
    int xpos = width/2 + width/8,
        ypos = height-50,
        xw = width/4,
        yh = 40;

 
    if(currentHitCount!=0){
      noStroke();
      color progress = lerpColor(color(255,0,0), color(255,255,0), requiredHitCount/currentHitCount);
      fill(progress);
      rect(xpos, ypos, currentHitCount/requiredHitCount*xw, yh);
    }
    // progress bar: box
    strokeWeight(6);
    stroke(255);
    noFill();
    rect(xpos, ypos, xw, yh);

  }

  private float timeSinceSwitch = 0;

  /**
   * "you have assembled enough hits" dance animation
   */
  void drawDanceAnimation() {
    float runtime = millis()-timeSinceSwitch;

    if(runtime > 500) {
      skyWomanBaseHeight+=35;
      currPose++;
      if(currPose>11)
        currPose=0;
      timeSinceSwitch = millis(); 
    }
    if(gameover==true){
      fill(0,255);
    }
    else{
      fill(0,50);
    }
    noStroke();
    rect(0,0,width,height);

    float animScale = skyWomanBaseHeight/skyWomanMask[currPose].height;
    float h=skyWomanMask[currPose].height*(animScale+runtime/3000);
    float w=skyWomanMask[currPose].width*(animScale+runtime/3000);    
    image(skyWomanMask[currPose],danceX-w/2,danceY-h,w,h);

    animScale = skyWomanBaseHeight/skyWomanDance[currPose].height;
    h=skyWomanBaseHeight;
    w=skyWomanDance[currPose].width*animScale;
    image(skyWomanDance[currPose],danceX-w/2,danceY-h,w,h);
    
    if(millis()-modeSwitch>(gameover? 3000 : 2000)) {
      if (gameover==true) {
        setFinished(true, loadImage("data/general/endScreens/" + (javascript!=null && javascript.getLanguage()=="french" ? "french/" : "") + "grounded.png"));
      } 
      else { 
        setMode(DDR);
        pauseNotes=false;
      }
    }
  }

  /**
   * decide whether or not to add a "note", and
   * if so, to which guideline.
   */
  void addCue() {
    int lineNr = (int) random(0,4);
    guideLines.get(lineNr).addCue();
  }

  /**
   * process the hits
   */
  void processHitAttempt(boolean success) {
    if(success) {
      currentHitCount += 1;
      if(currentHitCount == halfRequiredHitCount){
        moveToNextTile();
      }
      else if(currentHitCount == requiredHitCount) {
        moveToNextTile();
        currentHitCount = 0;
      }
    }
  }

  /**
   * Make skywoman dance and place a section of tile
   */
  void moveToNextTile() {
    greenTile = !greenTile;
    if(!greenTile) { 
      currentTurtleTile++; 
    }
    //if(currentTurtleTile<11) {
    //  turtleIslandCurrent = (greenTile ? turtlesGreen[int(currentTurtleTile-1)] : turtlesBrown[int(currentTurtleTile-1)]);
    //}
    if(currentTurtleTile==11){
      gameover=true; 
    }
    if(greenTile) { 
      setMode(DANCING); 
      for(GuideLine g: guideLines) {
        g.clear();
      }
      pauseNotes=true;
    }
  }

  /**
   * switch between DDR and DANCING mode
   */
  void setMode(int mode) {
    this.mode = mode;
    modeSwitch = millis();
    timeSinceSwitch = millis();
    skyWomanBaseHeight=300;
    if(gameover==true){
      danceX=width/2;
      danceY=height-25;
      skyWomanBaseHeight=400;
    }

  }

  // cursor key values
  protected final int VK_UP=38, VK_LEFT=37, VK_DOWN=40, VK_RIGHT=39;

  /**
   * key handling
   */
  void keyPressed(char key, int keyCode) {
    boolean success = false;
    int [] keys = { VK_RIGHT, VK_DOWN, VK_LEFT, VK_UP};
    int i=0;
    for(GuideLine g: guideLines) {
      if(keyCode==keys[i]){ 
        success = g.hit();
        if(success){
          g.setTapState(2);
        }
        else{
          g.setTapState(3);
        }
      }
      processHitAttempt(success);
      success=false;
      i++;
    }

    processHitAttempt(success);
  }

  /**
   * mouse handling
   */
  void mouseMoved(int mx, int my){
    super.mouseMoved(mx,my);
    boolean changecursor=false;
    for(GuideLine g: guideLines) {
      if(g.over(mx,my)) 
         changecursor=true;
    }
    if(changecursor==true){
      cursor(HAND);
    } else {
      cursor(ARROW);
    }
  }
  void mousePressed(int mx, int my) {
    boolean success=false;
    for(GuideLine g: guideLines) {
      if(g.over(mx,my)) {
        success = g.hit();
        if(success){
          g.setTapState(2);
        }
        else{
          g.setTapState(3);
        }
        processHitAttempt(success);
        success=false;
      }
    }
  }

  void pauseScreen() {
  }

  void resumeScreen() {
     for(GuideLine g: guideLines) {
       g.clear();
     }
  }

  void loadambient() {
    SoundPlayer.load(this, "data/audio/Grounded.mp3");
  }

  //This method is intended to be used to reset assets that can be changed on other screens to their correct positions and sizes
  void reset(){
  }

  String getHelpContent() {
    String english = "Tap the arrows in time with the music when they light up, by clicking\n"+
           "on screen or using the arrows on your keyboard, to make Sky woman dance!";
    String french = english;
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
  void updateTitle(){
  }
}

// =============================

/**
  tap button
**/
class TapButton {
  float x, y, r;
  color hitColor = color(0,255,0);
  color missColor = color(200,0,0);
  color neutralColor = color(255);
  color fillColor;
  color strokeColor;
  int step = 0;
  boolean isHit;
  // constructor
  TapButton(float _x, float _y, float _r,color sc) {
    x=_x;
    y=_y;
    r=_r;
    strokeColor=sc;
    fillColor = neutralColor;
    isHit=false;
  }
  // draw plain circl ellispe
  void draw() {
    stroke(strokeColor);
    fill(fillColor);
    ellipseMode(CENTER);
    ellipse(x,y,r*2,r*2);
    fill(0);
    ellipse(x,y,2,2);
  }
  // mouse over button?
  boolean over(float mx, float my) {
   return dist(x,y,mx,my) <= r; 
  }
  // change x/y
  void setPosition(float _x, float _y) { x = _x; y = _y; }
  // change radius
  void setRadius(float _r) { r=_r; }
  // get/set step value
  float getStep() { return step; }
  void setStep(int s) { step = s; }
  // color changing methods
  boolean hit(float lpv) { fillColor = hitColor; return true; }//lerpColor(missColor, hitColor, lpv); }
  boolean miss() { fillColor = missColor; return false; }
  void reset() { fillColor = neutralColor; }
}

/**
  bezier curve base class
**/
class CubicBezier {
  float xa,ya,
        xb,yb,
        xc,yc,
        xd,yd;
  color co;
  float sinofa;
  float cosofa;
  color fillco;
  boolean doFill;
  boolean drawCurve;
  float offsetX,offsetY;
  PImage medicineWheelArrow;
  float pulse;
  int tapState;
  float lastHitStateChangeTime;
  int clear_state=1;
  int hit_state=2;
  int miss_state=3;

  // constructor
  CubicBezier(float a, float b, float c, float d, float e, float f, float g, float h, color colour,PImage img,float offx,float offy, color fillColour,float sa,float ca){
    xa=a; ya=b; xb=c; yb=b; xc=e; yc=f; xd=g; yd=h;
    co=colour;
    medicineWheelArrow=img;
    offsetX=offx;
    offsetY=offy;
    fillco=fillColour;
    doFill=false;
    drawCurve=false;
    sinofa=sa;
    cosofa=ca;
    pulse=0;
    tapState=clear_state;
  }
  void setTapState(int state){
    tapState=state;
    lastHitStateChangeTime=millis();   
  }
  void setButtonFill(){
    if(tapState!=clear_state){
      if(tapState==hit_state){
        fill(0,255,0,100);
      }
      else{
        fill(255,0,0,150);
      }

      if(millis()-lastHitStateChangeTime > 100){

        tapState=clear_state;
      }
    }
    else{
      noFill();
    }    
  }
  void resetCurve(){
    float rx = random(40,80);
    float ry = (random(0,1)>0.5)?1:-1+random(20,50);      // control point 1
    xb=xa+ rx*cosofa-ry*sinofa;
    yb=ya+ rx*sinofa + ry*cosofa;
      // control point 2 uses slightly different random coordinates
    rx = random(80,120);
    ry = ((random(0,1)>0.5)?1:-1)+random(30,50);
    xc=xa+ rx*cosofa-ry*sinofa;
    yc=ya + rx*sinofa + ry*cosofa;
  }
  // draw bezier curve
  void draw() {
    float r=red(fillco);
    float g=green(fillco);
    float b=blue(fillco);
    float alpha=144;
    if(doFill==true){
      pushStyle();
      noFill();
      strokeWeight(2);
      ellipseMode(CENTER);
      int numSteps=15;
      float step=144.0/numSteps;
      for(int i=1;i<numSteps;i++){
        stroke(r,g,b,alpha-i*step);
        ellipse(xd,yd,(100+2*i)+(pulse*5),(100+2*i)+(pulse*5));
      }
      stroke(co);
     // fill(color(0,255,0,144));
      setButtonFill();
      ellipse(xd,yd,110+(pulse*5),110+(pulse*5));
      popStyle();
    }
    else{
      stroke(co);
      strokeWeight(3);
      setButtonFill();
      ellipse(xd,yd,110+(pulse*5),110+(pulse*5));
    }

    if(drawCurve){
      noFill();
      r=red(co);
      g=green(co);
      b=blue(co);
      for(int i=0;i<3;i++){
        stroke(r,g,b,50+30*i);
        strokeWeight((12-i*3)*pulse);
        bezier(xa,ya,xb,yb,xc,yc,xd,yd);
      }
      stroke(co);
      strokeWeight(3);
      bezier(xa,ya,xb,yb,xc,yc,xd,yd);
    }

    stroke(co);
    strokeWeight(3);
    noFill();
    imageMode(CENTER);
    image(medicineWheelArrow,xd +offsetX,yd+offsetY,medicineWheelArrow.width+(pulse*5),medicineWheelArrow.height+(pulse*5));
    imageMode(CORNER);
    ellipse(xd,yd,110+(pulse*5),110+(pulse*5));

  }

  // compute X/Y values given t
  float[] getCoordinateValues(float t) {
	float mt = 1-t,
            t1 = mt*mt*mt,
            t2 = t*mt*mt*3,
            t3 = t*t*mt*3,
            t4 = t*t*t;
	return new float[]{t1*xa + t2*xb + t3*xc + t4*xd, t1*ya + t2*yb + t3*yc + t4*yd};
  }
  void setPulse(float p){
    pulse=p-0.5;   //p is ranged from 1.5 to 2.5, adjust it to be 1 to 2
  }

  // split a cubic curve into two curves at time=t
  CubicBezier[] splitCubicCurve(float t) {
    // interpolate from 4 to 3 points
    float[] p5 = {(1-t)*xa + t*xb, (1-t)*ya + t*yb};
    float[] p6 = {(1-t)*xb + t*xc, (1-t)*yb + t*yc};
    float[] p7 = {(1-t)*xc + t*xd, (1-t)*yc + t*yd};
    // interpolate from 3 to 2 points
    float[] p8 = {(1-t)*p5[0] + t*p6[0], (1-t)*p5[1] + t*p6[1]};
    float[] p9 = {(1-t)*p6[0] + t*p7[0], (1-t)*p6[1] + t*p7[1]};
    // interpolate from 2 points to 1 point
    float[] p10 = {(1-t)*p8[0] + t*p9[0], (1-t)*p8[1] + t*p9[1]};
    // we now have all the values we need to build the subcurves
    CubicBezier[] curves = new CubicBezier[2];
    curves[0] = new CubicBezier(xa,ya, p5[0], p5[1], p8[0], p8[1], p10[0], p10[1],co,medicineWheelArrow,offsetX,offsetY,fillco,sinofa,cosofa);
    curves[1] = new CubicBezier(p10[0], p10[1], p9[0], p9[1], p7[0], p7[1], xd, yd,co,medicineWheelArrow,offsetX, offsetY,fillco,sinofa,cosofa);
    return curves;
  }
}

/**
  tap guideline - bezier curve
**/
class GuideLine extends CubicBezier {

  TapButton target;
  ArrayList<TapButton> cues = new ArrayList<TapButton>();
  color lineColor;
  int st = 0;
  float[] tvalues;
  color tapButtonColor;
  int missed;
  
  private final float target_position = 0.9;
  private final float target_radius = 55;
 
  // constructor
  GuideLine(float a, float b, float c, float d, float e, float f, float g, float h, color co, PImage img,float offx,float offy, color fillcolour,float sa,float ca,color tbc) {
    super(a,b,c,d,e,f,g,h,co,img,offx,offy,fillcolour,sa,ca);
    missed=0;
    tapButtonColor=tbc;
    tvalues = ScreenGroundedUtils.getTimeValues(a,b,c,d,e,f,g,h, 36);
    target = new TapButton(g,h,target_radius,tbc);
  }

  // darw guide line, target, and music cue
  void draw() {
    float[] pos;
/*
    super.draw();
    ellipseMode(CENTER);
    strokeWeight(5);
    stroke(255,0,0);
    pos = getCoordinateValues(tvalues[int(target_position*tvalues.length)]);
    target.setPosition(pos[0],pos[1]);
    target.draw();
*/
   for(TapButton cue: cues) {
      float t = tvalues[cue.step];
      pos = getCoordinateValues(t);
      cue.setPosition(pos[0], pos[1]);
      if (dist(pos[0],pos[1],xd,yd)<55)
         doFill=true;

    }
    super.draw();


    for(TapButton cue: cues) {
      cue.step++;

      strokeWeight(3);
      float t = tvalues[cue.step];
      pos = getCoordinateValues(t);
      cue.setPosition(pos[0], pos[1]);
      cue.draw();

/*
      fill(0);
      ellipse(pos[0], pos[1], 2,2);
//      text(""+t, pos[0]+15, pos[1]+10);
*/
    }

    for(int i=cues.size()-1; i>=0; i--) {
      
      if(cues.get(i).step == tvalues.length-1 || cues.get(i).isHit==true) {
        if(cues.get(i).isHit==false){    //cues got to end without being hit
          missed++;
        }
        cues.remove(i);
        target.reset();
      }
    }
    if(cues.size()==0){
      drawCurve=false;
      resetCurve();
     }
    strokeWeight(1);
    stroke(0);
    noFill();
    doFill=false;
  }

  // pick a random color for a note
  void setRandomColor() {
    lineColor = color(random(255),random(255),random(255));
  }

  // shift control points a little bit
  void randomiseControls() {
    xb += random(-0.5,0.5);
    yb += random(-0.5,0.5);
    xc += random(-0.5,0.5);
    yc += random(-0.5,0.5);
  }

  // hit the target!
  boolean hit() {
    if(cues.size()>0)
    {
      TapButton cue = cues.get(0);
      float d = (float)cue.step/tvalues.length;
      /*(d<=0.9) make 0.9 smaller to make window wider, 1 is furthest point out, 0 is closest to centre
         the abs(d-tangent_position <= 0.1 and the 0.9 sums to 1.  Map values should also be modified accordingly*/
      float v=0.25;
      if(abs(d-target_position)<=v) {
        cue.isHit=true;
        if(d<=(1.0-v)) {
          return target.hit(map(d, (1.0-2*v), 1.0-v, 0.0, 1.0));
        }
        else {
          return target.hit(map(d, 1.0-v, 1.0, 1.0, 0.0));
        }
      }
      else { return target.miss(); }
    }
    return false;
  }

  // mouse over target?
  boolean over(float mx, float my) {
    return target.over(mx,my);
  }

  // add a visual cue to this guideline
  void addCue() {
    drawCurve=true;
    cues.add(new TapButton(xa,ya,10,tapButtonColor));
  }
  void clear(){
    tapState=clear_state;
    missed=0;
    for(int i=cues.size()-1; i>=0; i--) {
        cues.remove(i);
    }
    target.reset();
  }
}

