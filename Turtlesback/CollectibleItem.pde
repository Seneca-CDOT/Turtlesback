class CollectibleItem{
  PVector startPoint;
  PVector endPoint;
  int itemType;
  BoundingBox[] itemBoundingBoxes;
  float height;
  PImage itemImage;
  PImage highlightImage;
  boolean hasImage;
  
  float scaleFactor = 0.5;
  float rotation;
  
  public CollectibleItem(int itemType, PVector startPoint, PVector endPoint, float height, PImage itemImage, PImage highlightImage, float rotation){
    this.itemType = itemType;
    itemBoundingBoxes = new BoundingBox[collectibleItems[itemType].length];
    this.itemImage = itemImage;
    this.highlightImage = highlightImage;
    //You can set this to false and it'll draw a wireframe which shows you the collision model
    hasImage = true;
    this.rotation = rotation;
    PVector imageCenter = new PVector(itemImage.width/2, itemImage.height/2);
    for (int boundingIndex = 0; boundingIndex < collectibleItems[itemType].length; boundingIndex++){
      PVector[] corners = collectibleItems[itemType][boundingIndex].getCorners();
      itemBoundingBoxes[boundingIndex] = new BoundingBox(PVector.sub(PVector.mult(corners[0],scaleFactor), imageCenter), 
                                                         PVector.sub(PVector.mult(corners[1],scaleFactor), imageCenter), 
                                                         PVector.sub(PVector.mult(corners[2],scaleFactor), imageCenter), 
                                                         PVector.sub(PVector.mult(corners[3],scaleFactor), imageCenter), rotation);
    }
    this.startPoint = startPoint.get();
    this.endPoint = endPoint.get();
    this.height = height;
  }
  
  public boolean collides(PVector toCheck){
    //Subtract our offset from toCheck and pass it into each of the bounding boxes until we either run out of bounding boxes or hit one
    //PVector offsetCheck = PVector.sub(toCheck, offset);
    PVector offsetCheck = new PVector(toCheck.x - endPoint.x, toCheck.y - endPoint.y);
    boolean hasCollided = false;
    for (int boundingIndex = 0; boundingIndex < itemBoundingBoxes.length; boundingIndex++){
      if (itemBoundingBoxes[boundingIndex].collides(offsetCheck)){
        hasCollided = true;
        boundingIndex = itemBoundingBoxes.length;
      }
    }
    return hasCollided;
  }
  
  public void addPosition(PVector positionToAdd){
    endPoint.add(positionToAdd);
  }
  
  public void setPosition(PVector positionToSet){
    endPoint = positionToSet.get();
  }
  
  public float getHeight(){
    return height;
  }
  
  public int getItemType(){
    return itemType;
  }
  
  public void draw(){
    pushMatrix();
    translate(endPoint.x, endPoint.y);
    rotate(rotation);
    //Comment out next line to see wireframe+image
    if (hasImage){
      image(highlightImage, highlightImage.width/-2,highlightImage.height/-2);
    //Comment out next line to see wireframe+image
    }else{
      rotate(-rotation);
      for (int boundingIndex = 0; boundingIndex < itemBoundingBoxes.length; boundingIndex++){
        itemBoundingBoxes[boundingIndex].draw();
      }
    //Comment out next line to see wireframe+image
    }
    popMatrix();
  }
  
  public void draw(float referenceHeight){
    pushMatrix();
    float reducedWidth = (itemImage.width/(referenceHeight - height));
    float reducedHeight = itemImage.height/(referenceHeight - height);
    translate(startPoint.x + ((endPoint.x - startPoint.x)/(referenceHeight - height)), startPoint.y + ((endPoint.y - startPoint.y)/(referenceHeight - height)));
    rotate(rotation);
    //If the image isn't sliding properly along Y then the problem is most likely here
    //Comment out next line to see wireframe+image
    if (hasImage){
      
      image(itemImage, (reducedWidth/-2), (reducedHeight/-2), reducedWidth, reducedHeight);
    //Comment out next line to see wireframe+image
    }else{
      rotate(-rotation);
      for (int boundingIndex = 0; boundingIndex < itemBoundingBoxes.length; boundingIndex++){
        itemBoundingBoxes[boundingIndex].draw(1/(referenceHeight - height));
      }
    //Comment out next line to see wireframe+image
    }
    popMatrix();
  }
  
}

//This was entered by hand. Make outlines over items in seperate layer in paint.net, then put in the coords of 4 sided polygons that
//cover the outlines. Doesn't have to be pixel perfect.
void populateCollectibleItems(){
  collectibleItems = new BoundingBox[8][];
  collectibleItems[0] = new BoundingBox[4];
  collectibleItems[0][0] = new BoundingBox(new PVector(51,1), new PVector(117,32), new PVector(118,72), new PVector(4,36));
  collectibleItems[0][1] = new BoundingBox(new PVector(21,43), new PVector(118,73), new PVector(5,123), new PVector(1,72));
  collectibleItems[0][2] = new BoundingBox(new PVector(6,123), new PVector(117,74), new PVector(69,175), new PVector(31,160));
  collectibleItems[0][3] = new BoundingBox(new PVector(69,175), new PVector(119,74), new PVector(127,114), new PVector(106,153));
  collectibleItems[1] = new BoundingBox[4];
  collectibleItems[1][0] = new BoundingBox(new PVector(20,11), new PVector(71,1), new PVector(6,95), new PVector(1,51));
  collectibleItems[1][1] = new BoundingBox(new PVector(71,1), new PVector(64,133), new PVector(28,124), new PVector(6,96));
  collectibleItems[1][2] = new BoundingBox(new PVector(71,1), new PVector(112,6), new PVector(144,48), new PVector(65,134));
  collectibleItems[1][3] = new BoundingBox(new PVector(143,50), new PVector(141,89), new PVector(113,127), new PVector(66,133));
  collectibleItems[2] = new BoundingBox[6];
  collectibleItems[2][0] = new BoundingBox(new PVector(43,50), new PVector(61,76), new PVector(8,119), new PVector(3,91));
  collectibleItems[2][1] = new BoundingBox(new PVector(65,52), new PVector(86,6), new PVector(99,1), new PVector(62,76));
  collectibleItems[2][2] = new BoundingBox(new PVector(100,1), new PVector(110,5), new PVector(109,78), new PVector(62,77));
  collectibleItems[2][3] = new BoundingBox(new PVector(61,77), new PVector(108,78), new PVector(55,105), new PVector(26,104));
  collectibleItems[2][4] = new BoundingBox(new PVector(53,106), new PVector(116,74), new PVector(77,160), new PVector(63,160));
  collectibleItems[2][5] = new BoundingBox(new PVector(116,80), new PVector(128,79), new PVector(131,117), new PVector(101,110));
  collectibleItems[3] = new BoundingBox[6];
  collectibleItems[3][0] = new BoundingBox(new PVector(3,3), new PVector(40,17), new PVector(103,49), new PVector(30,26));
  collectibleItems[3][1] = new BoundingBox(new PVector(31,27), new PVector(103,50), new PVector(101,79), new PVector(41,41));
  collectibleItems[3][2] = new BoundingBox(new PVector(104,49), new PVector(167,71), new PVector(187,122), new PVector(101,79));
  collectibleItems[3][3] = new BoundingBox(new PVector(167,71), new PVector(232,87), new PVector(282,161), new PVector(187,122));
  collectibleItems[3][4] = new BoundingBox(new PVector(232,86), new PVector(298,116), new PVector(372,196), new PVector(282,160));
  collectibleItems[3][5] = new BoundingBox(new PVector(300,118), new PVector(325,133), new PVector(353,163), new PVector(372,196));
  collectibleItems[4] = new BoundingBox[5];
  collectibleItems[4][0] = new BoundingBox(new PVector(44,0), new PVector(50,0), new PVector(113,31), new PVector(3,37));
  collectibleItems[4][1] = new BoundingBox(new PVector(27,36), new PVector(88,33), new PVector(118,60), new PVector(1,72));
  collectibleItems[4][2] = new BoundingBox(new PVector(1,72), new PVector(117,60), new PVector(125,83), new PVector(1,100));
  collectibleItems[4][3] = new BoundingBox(new PVector(1,100), new PVector(125,84), new PVector(116,138), new PVector(29,159));
  collectibleItems[4][4] = new BoundingBox(new PVector(30,157), new PVector(116,139), new PVector(92,166), new PVector(65,174));
  collectibleItems[5] = new BoundingBox[7];
  collectibleItems[5][0] = new BoundingBox(new PVector(33,2), new PVector(52,1), new PVector(56,10), new PVector(23,23));
  collectibleItems[5][1] = new BoundingBox(new PVector(23,23), new PVector(56,10), new PVector(57,23), new PVector(23,36));
  collectibleItems[5][2] = new BoundingBox(new PVector(23,36), new PVector(58,23), new PVector(54,58), new PVector(25,68));
  collectibleItems[5][3] = new BoundingBox(new PVector(25,68), new PVector(54,58), new PVector(71,110), new PVector(18,113));
  collectibleItems[5][4] = new BoundingBox(new PVector(18,113), new PVector(71,110), new PVector(89,162), new PVector(1,155));
  collectibleItems[5][5] = new BoundingBox(new PVector(1,155), new PVector(89,162), new PVector(89,184), new PVector(2,180));
  collectibleItems[5][6] = new BoundingBox(new PVector(3,179), new PVector(89,184), new PVector(65,219), new PVector(26,215));
  collectibleItems[6] = new BoundingBox[6];
  collectibleItems[6][0] = new BoundingBox(new PVector(0,0), new PVector(16,4), new PVector(21,72), new PVector(0,21));
  collectibleItems[6][1] = new BoundingBox(new PVector(17,4), new PVector(73,63), new PVector(34,108), new PVector(22,72));
  collectibleItems[6][2] = new BoundingBox(new PVector(74,64), new PVector(108,123), new PVector(40,157), new PVector(33,109));
  collectibleItems[6][3] = new BoundingBox(new PVector(40,157), new PVector(109,123), new PVector(140,160), new PVector(50,201));
  collectibleItems[6][4] = new BoundingBox(new PVector(50,201), new PVector(140,160), new PVector(166,204), new PVector(77,234));
  collectibleItems[6][5] = new BoundingBox(new PVector(76,235), new PVector(167,204), new PVector(175,227), new PVector(123,254));
  collectibleItems[7] = new BoundingBox[8];
  collectibleItems[7][0] = new BoundingBox(new PVector(33,14), new PVector(64,0), new PVector(56,56), new PVector(1,46));
  collectibleItems[7][1] = new BoundingBox(new PVector(64,0), new PVector(105,54), new PVector(96,63), new PVector(56,55));
  collectibleItems[7][2] = new BoundingBox(new PVector(1,47), new PVector(96,63), new PVector(91,74), new PVector(21,77));
  collectibleItems[7][3] = new BoundingBox(new PVector(21,78), new PVector(92,76), new PVector(90,100), new PVector(27,101));
  collectibleItems[7][4] = new BoundingBox(new PVector(27,101), new PVector(90,100), new PVector(63,149), new PVector(52,148));
  collectibleItems[7][5] = new BoundingBox(new PVector(32,156), new PVector(51,148), new PVector(62,149), new PVector(35,179));
  collectibleItems[7][6] = new BoundingBox(new PVector(62,150), new PVector(74,158), new PVector(78,170), new PVector(36,178));
  collectibleItems[7][7] = new BoundingBox(new PVector(37,179), new PVector(77,171), new PVector(75,176), new PVector(50,202));
  
}


