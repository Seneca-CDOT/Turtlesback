/**
 * This class models a bounding line consisting of
 * various bird sprites, for use in the Descent
 * mini-game. It overrides the default line draw
 * method to draw sprite layers instead.
 */
class BoundingBirdLine extends BoundingLine {
  /**
   * Sprite substitute class
   */
  class SpriteBox {
    SpriteFactory bird;
    float x,y,w,h;
    float r = random(255), g = random(255), b = random(255);
    int frameOffset = 0;

    SpriteBox(float _x, float _y, float _w, float _h, SpriteFactory _bird, float _frameOffset) {
      x = _x;
      y = _y;
      w = _w;
      h = _h;
      bird = _bird;
      frameOffset = (int) _frameOffset;
    }

    void drawBackground() {
      if(isDebugging) {
        // draw a transparent box
        fill(r,g,b,100);
        stroke(255,255,0);
        rect(x,y,w,h);
        fill(0);
        stroke(0); }}

    void drawForeground() {
      if(isDebugging) {
        // draw an opaque box
        fill(r,g,b);
        stroke(0);
        rect(x+w/2-20,y-10,40,20);
        fill(0);
        stroke(0); }
      // draw the bird sprite
      bird.moveTo(int(x+w/2),int(y+h/2));
      bird.setFrameOffset(frameOffset);
      bird.draw(); }
 }

  // pixels between birds
  float birdGap = -10;

  // local sprite list
  ArrayList<SpriteBox> sprites = new ArrayList<SpriteBox>();

  // local list of available bird sprites
  ArrayList<SpriteFactory> birds = new ArrayList<SpriteFactory>();

  /**
   * Construct a new bounding line, and set up the bird sprites
   * used to "decorate" this line.
   */
  BoundingBirdLine(PVector startPoint, PVector endPoint, ArrayList<SpriteFactory> _birds, float heightPercentage) {
    super(startPoint, endPoint);
    this.birds = _birds;
    setupSprites(heightPercentage);
  }

  // sprite fill substitute
  void setupSprites(float heightPercentage) {
    float startX = offsetStartPoint.x,
          startY = offsetStartPoint.y,
          endX = offsetEndPoint.x,
          endY = offsetEndPoint.y,
          lWidth = endX - startX,
          lHeight = endY - startY,
          lineCoefficient = lHeight/lWidth;
    // for now, generate several random sized boxes
    SpriteFactory bird = getSomeBird(heightPercentage);
    float runningTotal = 0,
          bWidth = bird.sizeX * bird.getScale()[0],
          bHeight = bird.sizeY * bird.getScale()[1];
    while(startX + bWidth < offsetStartPoint.x + lWidth) {
      sprites.add(new SpriteBox(startX, startY-bHeight/2.0, bWidth, bHeight, bird, random(bird.frames.length)));
      startX += bWidth + birdGap;
      runningTotal += bWidth + birdGap;
      startY = offsetStartPoint.y + runningTotal*lineCoefficient;
      // move on to the next bird
      bird = getSomeBird(heightPercentage);
      bWidth = bird.sizeX * bird.getScale()[0];
      bHeight = bird.sizeY * bird.getScale()[1];
    }

    // Is there space left? Add one more bird.
    float remainder = lWidth - runningTotal;
    if(remainder>0) {
      sprites.add(new SpriteBox(startX, startY-bHeight/2.0, bWidth, bHeight, bird, random(bird.frames.length)));
      // move our line end up a little.
      startY += bWidth*lineCoefficient;
      startX += bWidth;
      setEndPoint(new PVector(startX,startY));
    }
    // To make sure the sky woman doesn't fall thought the start,
    // we move the start up a tiny bit
    float salt = 30;
    setStartPoint(new PVector(offsetStartPoint.x-salt, offsetStartPoint.y-salt*lineCoefficient));

  }

  // internal variable to prevent selecting the same bird twice in a row
  int lastBird = -1;

  /**
   * What bird is used for the platform depends on how high we are
   */
  SpriteFactory getSomeBird(float heightPercentage) {
    int start = (int) (4 * heightPercentage);
    int end = (int) (3 * (1-heightPercentage) + (birds.size()+1) *  heightPercentage);
    int birdId;
    do {
      birdId = (int) random(start, end);
    } while(birdId==lastBird);
    lastBird = birdId;
    return birds.get(birdId);
  }

  void draw() {
    // draw the master line
    super.draw();
    // draw background sprites
    drawBackground();
    // draw foreground sprites
    drawForeground();
  }

  // background: all box sprites
  void drawBackground() {
    for(SpriteBox b: sprites) {
      b.drawBackground();
    }
  }

  // foreground: nothing right now
  void drawForeground() {
    for(SpriteBox b: sprites) {
      b.drawForeground();
    }
    if(isDebugging) {
      super.draw();
    }
  }
}

