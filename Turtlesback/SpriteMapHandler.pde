static class SpriteMapHandler {

  // local binding for sketch
  static PApplet sketch;

  // must be called from setup()
  static void init(PApplet s) { sketch = s;}

  static PImage[] cutTiledSpritesheet(String _spritesheet,int widthCount,int heightCount){
    return cutTiledSpritesheet(_spritesheet, widthCount, heightCount, false);
  }

  static PImage[] cutTiledSpritesheet(String _spritesheet, int widthCount, int heightCount, boolean leftToRightFirst){
    PImage spritesheet = sketch.loadImage(_spritesheet);

    // loop through spritesheet and cut out images
    // this method assumes sprites are all the same size and tiled in the spritesheet
    int spriteCount = widthCount*heightCount;
    int spriteIndex = 0;
    int tileWidth = spritesheet.width/widthCount;
    int tileHeight = spritesheet.height/heightCount;

    // safety first
    if(tileWidth == 0 || tileHeight == 0) {
      println("tile width or height is 0 (possible missing image preload for "+_spritesheet+"?)");
    }

    PImage[] sprites = new PImage[spriteCount];
    if (leftToRightFirst){
      for(int i = 0; i < heightCount; i++){
        for(int j =0; j < widthCount;j++){
          // cut image left to right, top to bottom
          sprites[spriteIndex] = spritesheet.get(j*tileWidth,i*tileHeight,tileWidth,tileHeight);
          spriteIndex++;
        }
      }
    }else{
      for(int i = 0; i < widthCount; i++){
        for(int j =0; j < heightCount;j++){
          // cut image left to right, top to bottom
          sprites[spriteIndex] = spritesheet.get(i*tileWidth,j*tileHeight,tileWidth,tileHeight);
          spriteIndex++;
        }
      }
    }
    return sprites;
  }
}
