public class BoundingBox{
  PVector offset;
  PVector[] corners;
  //Sides aren't actually needed beyond the constructor
  //PVector[] sides;
  PVector[] normals;
  PVector center;
  boolean hasRotation;
  //This is in radians
  float rotation;
  
  public BoundingBox(PVector[] corners, float rotation){
    this(corners[0], corners[1], corners[2], corners[3], rotation);
  }
  
  public BoundingBox(PVector cornerOne, PVector cornerTwo, PVector cornerThree, PVector cornerFour){
    this(cornerOne, cornerTwo, cornerThree, cornerFour, 0);
  }
  
  public BoundingBox(PVector cornerOne, PVector cornerTwo, PVector cornerThree, PVector cornerFour, float rotation){
    offset = new PVector();
    corners = new PVector[4];
    normals = new PVector[4];
    corners[0] = cornerOne;
    corners[1] = cornerTwo;
    corners[2] = cornerThree;
    corners[3] = cornerFour;
    
    //setRotation also calls the generate the sides, normals, and center function
    setRotation(rotation);
  }
  
  public PVector[] getCorners(){
    return corners;
  }
  
  public void setRotation(float rotation){
    //Because we're using a left handed rotational system, where y is down, our rotation will be clockwise
    //We could alternatively draw this rotated using the built-in rotate and just rotate the collision check vector,
    //but we're not because of CPU usage
    if (rotation == 0.0){
      if (hasRotation){
        rotateCorners(-rotation);
      }
      this.rotation = rotation;
      hasRotation = false;
    }else{
      rotateCorners(rotation);
      hasRotation = true;
      this.rotation = rotation;
    }
    generateSidesNormalsAndCenter();
  }
  
  private void rotateCorners(float rotation){
    float cosRotation = cos(rotation);
    float sinRotation = sin(rotation);
    for (int cornerIndex = 0; cornerIndex < corners.length; cornerIndex++){
      //Just a standard rotation matrix here
      float rotatedX = corners[cornerIndex].x*cosRotation - corners[cornerIndex].y*sinRotation;
      float rotatedY = corners[cornerIndex].x*sinRotation + corners[cornerIndex].y*cosRotation;
      corners[cornerIndex] = new PVector(rotatedX, rotatedY);
    }
  }
  
  private void generateSidesNormalsAndCenter(){
    
    PVector[] sides = new PVector[4];
    
    float minX = min(corners[0].x, corners[3].x);
    float maxX = max(corners[1].x, corners[2].x);
    float minY = min(corners[0].y, corners[1].y);
    float maxY = max(corners[2].y, corners[3].y);
    center = new PVector((minX + maxX) / 2, (minY + maxY) / 2);
    
    //Generate the sides
    sides[0] = PVector.sub(corners[1], corners[0]);
    sides[1] = PVector.sub(corners[2], corners[1]);
    sides[2] = PVector.sub(corners[3], corners[2]);
    sides[3] = PVector.sub(corners[0], corners[3]);
    
    //(x1,y1) to (x2,y2)
    // if we define dx=x2-x1 and dy=y2-y1, then the normals are (-dy, dx) and (dy, -dx).
    for (int currentNormal = 0; currentNormal < sides.length; currentNormal++){
      normals[currentNormal] = new PVector(-sides[currentNormal].y, sides[currentNormal].x);
    }
  }
  
  //Adds whatever the vector is to the offset
  public void addPosition(PVector positionToAdd){
    offset.add(positionToAdd);
  }
  
  //This doesn't directly set the center- instead it sets the offset to that the bounding box will end up drawing at the center
  public void setCenter(PVector centerToSet){
    offset = PVector.sub(centerToSet, center);
  }
  
  public void draw(){
    pushMatrix();
    translate(offset.x, offset.y);
    line(corners[0].x, corners[0].y, corners[1].x, corners[1].y);
    line(corners[1].x, corners[1].y, corners[2].x, corners[2].y);
    line(corners[2].x, corners[2].y, corners[3].x, corners[3].y);
    line(corners[3].x, corners[3].y, corners[0].x, corners[0].y);
    popMatrix();
  }
  
  public void draw(float scaleValue){
    pushMatrix();
    translate(offset.x, offset.y);
    //To scale a point towards the center we want to get the vector difference between it and the center, multiply that vector by scaleValue, and then add it onto the center
    PVector[] scaledCorners = new PVector[corners.length];
    for (int currentCorner = 0; currentCorner < corners.length; currentCorner++){
      scaledCorners[currentCorner] = PVector.add(center, PVector.mult(PVector.sub(corners[currentCorner], center), scaleValue));
    }
    line(scaledCorners[0].x, scaledCorners[0].y, scaledCorners[1].x, scaledCorners[1].y);
    line(scaledCorners[1].x, scaledCorners[1].y, scaledCorners[2].x, scaledCorners[2].y);
    line(scaledCorners[2].x, scaledCorners[2].y, scaledCorners[3].x, scaledCorners[3].y);
    line(scaledCorners[3].x, scaledCorners[3].y, scaledCorners[0].x, scaledCorners[0].y);
    popMatrix();
  }
  
  public boolean collides(PVector toCheck){
    PVector checkForCollision = PVector.sub(toCheck, offset);
    boolean doesCollide = true;
    for (int currentNormal = 0; currentNormal < normals.length; currentNormal++){
      if (!(normals[currentNormal].dot(PVector.sub(checkForCollision, corners[currentNormal])) > 0)){
        doesCollide = false;
        currentNormal = normals.length;
      }
    }
    return doesCollide;
  }
}



