public class BoundingLine{
  PVector startPoint;
  PVector endPoint;
  PVector bLine;
  PVector lineNormal;
  PVector offset;
  PVector offsetStartPoint;
  PVector offsetEndPoint;
  
  BoundingLine(PVector startPoint, PVector endPoint){
    offset = new PVector(0,0);
    this.startPoint = startPoint;
    this.endPoint = endPoint;
    bLine = PVector.sub(endPoint, startPoint);
    lineNormal = new PVector(-bLine.y, bLine.x);
    offsetStartPoint = startPoint;
    offsetEndPoint = endPoint;
  }
  
  void setStartPoint(PVector startPoint){
    this.startPoint = startPoint;
    offsetStartPoint = startPoint;
    bLine = PVector.sub(endPoint, startPoint);
    lineNormal = new PVector(-bLine.y, bLine.x);
  }
  
  void setEndPoint(PVector endPoint){
    this.endPoint = endPoint;
    offsetEndPoint = endPoint;
    bLine = PVector.sub(endPoint, startPoint);
    lineNormal = new PVector(-bLine.y, bLine.x);
  }
  
  boolean isAbove(PVector toCheck){
    return lineNormal.dot(PVector.sub(toCheck,offsetStartPoint)) >= 0;
  }
  
  boolean isBelow(PVector toCheck){
    return lineNormal.dot(PVector.sub(toCheck,offsetStartPoint)) < 0;
  }
  
  boolean isAfterStart(PVector toCheck){
    return toCheck.x >= offsetStartPoint.x;
  }
  
  float getStartX(){
    return offsetStartPoint.x;
  }
  
  float getEndX(){
    return offsetEndPoint.x;
  }
  
  boolean isBeforeEnd(PVector toCheck){
    return toCheck.x <= offsetEndPoint.x;
  }
  
  void draw(){
    line(offsetStartPoint.x, offsetStartPoint.y, offsetEndPoint.x, offsetEndPoint.y);
  }

  void drawBackground(){
  }

  void drawForeground(){
    draw();
  }
  
  void move(PVector moveBy){
    offset.add(moveBy);
    offsetStartPoint = PVector.add(startPoint,offset);
    offsetEndPoint = PVector.add(endPoint, offset);
  }
  
  float getHeight(PVector xPoint){
    //Normalize the line, multiply it so that the x portion of the line = (x portion of xPoint - offset and startPoint)
    //add that line to startpoint+offset and return the y portion
    PVector normalizedLine = bLine.get();
    normalizedLine.normalize();
    PVector xPointOnLine = PVector.sub(xPoint, PVector.add(startPoint, offset));    
    return PVector.add(PVector.mult(normalizedLine, (xPointOnLine.x/normalizedLine.x)), PVector.add(startPoint,offset)).y;
  }
  
  void attachSprite(Sprite _sprite){
    // attach an actor to the line. For ScreenDescent
    
  }
}
