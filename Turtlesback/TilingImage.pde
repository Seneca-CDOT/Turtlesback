public class TilingImage{
  PImage imageTile;
  int x,y,w,h;
  float repeatXamount, repeatYamount;
  int incrementX, incrementY;
  int width, height;
  
  TilingImage(String sourceImg, int xCoord, int yCoord, int totalW, int totalH){
    imageTile = loadImage(sourceImg);
    x = xCoord;
    y = yCoord;
    w = totalW;
    h = totalH;
    width = imageTile.width;
    height = imageTile.height;
    repeatXamount = (totalW / imageTile.width) < 1 ? 1 : (totalW / imageTile.width);   // make sure repeatXamount isnt lower than 1
    repeatYamount = (totalH / imageTile.height) < 1 ? 1 : (totalH / imageTile.height); // make sure repeatYamount isnt lower than 1
    incrementX = imageTile.width;
    incrementY = imageTile.height;
  }
  
  void draw(){
    draw(x,y);
  }
  
  void draw(float _x,float _y){
    for(int i = 0; i < repeatYamount; i ++){
      for(int j =0; j < repeatXamount; j++){
        image(imageTile,_x+(j*incrementX),_y+(i*incrementY));
      }
    }
  }
}
