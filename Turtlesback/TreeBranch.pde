class TreeBranch{
  PVector startPoint;
  PVector endPoint;
  int branchType;
  BoundingBox[] branchBoundingBoxes;
  //This is the location within the branch image of the actual part of the branch that connects to the tree
  PVector branchBaseOffset;
  float height;
  PImage branchImage;
  boolean hasImage;
  boolean canCollide;
  float rotation;
  boolean hasRotation;

  public TreeBranch(int branchType, PVector startPoint, PVector endPoint, float height, PVector branchBaseOffset, PImage branchImage){
    this(branchType,startPoint,endPoint,height,branchBaseOffset,branchImage,0);
  }

  public TreeBranch(int branchType, PVector startPoint, PVector endPoint, float height, PVector branchBaseOffset, PImage branchImage, float rotation){
    reset(branchType, startPoint, endPoint, height, branchBaseOffset, branchImage, rotation);
  }

  // actually set all values
  void reset(int branchType, PVector startPoint, PVector endPoint, float height, PVector branchBaseOffset, PImage branchImage, float rotation){
    this.branchType = branchType;
    this.branchBaseOffset = branchBaseOffset.get();
    branchBoundingBoxes = treeBranches[branchType];
    this.startPoint = startPoint.get();
    this.endPoint = endPoint.get();
    this.height = height;
    this.branchImage = branchImage;
    hasImage = true;
    this.rotation = rotation;
    if (rotation == 0){
      canCollide = true;
      hasRotation = false;
    }else{
      canCollide = false;
      hasRotation = true;
    }
  }


  public boolean collides(PVector toCheck){
    if (canCollide){
      //Subtract our offset from toCheck and pass it into each of the bounding boxes until we either run out of bounding boxes or hit one
      //PVector offsetCheck = PVector.sub(toCheck, offset);
      PVector offsetCheck = new PVector(toCheck.x - endPoint.x, toCheck.y - endPoint.y);
      offsetCheck.add(branchBaseOffset);
      boolean hasCollided = false;
      for (int boundingIndex = 0; boundingIndex < branchBoundingBoxes.length; boundingIndex++){
        if (branchBoundingBoxes[boundingIndex].collides(offsetCheck)){
          hasCollided = true;
          boundingIndex = branchBoundingBoxes.length;
        }
      }
      return hasCollided;
    }else{
      return false;
    }
  }

  public float getHeight(){
    return height;
  }

  public void draw(){
    pushMatrix();
    translate(endPoint.x, endPoint.y);
    if (hasRotation){
      rotate(rotation);
    }
    translate(-branchBaseOffset.x, -branchBaseOffset.y);
    if (hasImage){
      image(branchImage,0,0);
    }else{
      for (int boundingIndex = 0; boundingIndex < branchBoundingBoxes.length; boundingIndex++){
        branchBoundingBoxes[boundingIndex].draw();
      }
    }
    if (hasRotation){
      rotate(-rotation);
    }
    popMatrix();
  }

  //STOPHERE
  //TODO: Get rotated tree branches working. Maybe even with collisions or something cool like that.
  //We can do this by translating the origin over to the draw point, rotating by the angle of the circle at that point,
  //and then drawing the branch with the normal translations applied


  //This draws the image centered on Y but not on x
  public void draw(float referenceHeight){
    pushMatrix();
    float heightDifference = referenceHeight - height;
    PVector drawPoint = PVector.sub(startPoint, PVector.div(PVector.sub(startPoint, endPoint), heightDifference));

    //If the image isn't sliding properly along Y then the problem is most likely here
    translate(drawPoint.x, drawPoint.y);
    if (hasRotation){
      rotate(rotation);
    }
    translate(-(branchBaseOffset.x/heightDifference), -(branchBaseOffset.y/heightDifference));
    if (hasImage){
      image(branchImage,0,0, branchImage.width/heightDifference, branchImage.height/heightDifference);
    }else{
      for (int boundingIndex = 0; boundingIndex < branchBoundingBoxes.length; boundingIndex++){
        branchBoundingBoxes[boundingIndex].draw(1/(referenceHeight - height));
      }
    }
    if (hasRotation){
        rotate(-rotation);
    }
    popMatrix();
  }

}

//This was entered by hand. Make outlines over trees in seperate layer in paint.net, then put in the coords of 4 sided polygons that
//cover the outlines. Doesn't have to be pixel perfect.
void populateTreeBranches(){
  treeBranches = new BoundingBox[8][];
  treeBranches[0] = new BoundingBox[22];
  treeBranches[0][0] = new BoundingBox(new PVector(59,89), new PVector(96,39), new PVector(150,120), new PVector(118,148));
  treeBranches[0][1] = new BoundingBox(new PVector(150,120), new PVector(253,171), new PVector(190,187), new PVector(118,148));
  treeBranches[0][2] = new BoundingBox(new PVector(190,187), new PVector(226,211), new PVector(191,313), new PVector(184,268));
  treeBranches[0][3] = new BoundingBox(new PVector(190,187), new PVector(253,171), new PVector(284,218), new PVector(229,211));
  treeBranches[0][4] = new BoundingBox(new PVector(208,271), new PVector(287,352), new PVector(272,379), new PVector(199,353));
  treeBranches[0][5] = new BoundingBox(new PVector(201,377), new PVector(207,535), new PVector(116,428), new PVector(145,386));
  treeBranches[0][6] = new BoundingBox(new PVector(198,353), new PVector(207,535), new PVector(354,538), new PVector(439,439));
  treeBranches[0][7] = new BoundingBox(new PVector(272,379), new PVector(334,276), new PVector(451,419), new PVector(441,439));
  treeBranches[0][8] = new BoundingBox(new PVector(233,211), new PVector(285,218), new PVector(334,276), new PVector(318,303));
  treeBranches[0][9] = new BoundingBox(new PVector(293,227), new PVector(353,244), new PVector(340,264), new PVector(321,260));
  treeBranches[0][10] = new BoundingBox(new PVector(402,165), new PVector(447,204), new PVector(451,416), new PVector(334,276));
  treeBranches[0][11] = new BoundingBox(new PVector(449,289), new PVector(555,338), new PVector(551,349), new PVector(449,307));
  treeBranches[0][12] = new BoundingBox(new PVector(475,301), new PVector(529,290), new PVector(571,300), new PVector(555,338));
  treeBranches[0][13] = new BoundingBox(new PVector(571,300), new PVector(640,334), new PVector(574,471), new PVector(521,424));
  treeBranches[0][14] = new BoundingBox(new PVector(601,227), new PVector(643,242), new PVector(640,334), new PVector(572,300));
  treeBranches[0][15] = new BoundingBox(new PVector(641,334), new PVector(722,364), new PVector(713,374), new PVector(636,344));
  treeBranches[0][16] = new BoundingBox(new PVector(653,338), new PVector(760,297), new PVector(761,313), new PVector(678,347));
  treeBranches[0][17] = new BoundingBox(new PVector(725,309), new PVector(731,288), new PVector(763,259), new PVector(767,271));
  treeBranches[0][18] = new BoundingBox(new PVector(823,74), new PVector(865,88), new PVector(892,205), new PVector(803,118));
  treeBranches[0][19] = new BoundingBox(new PVector(803,120), new PVector(937,250), new PVector(949,388), new PVector(759,323));
  treeBranches[0][20] = new BoundingBox(new PVector(759,323), new PVector(946,388), new PVector(700,592), new PVector(690,411));
  treeBranches[0][21] = new BoundingBox(new PVector(700,593), new PVector(947,389), new PVector(957,397), new PVector(717,593));
  treeBranches[1] = new BoundingBox[17];
  treeBranches[1][0] = new BoundingBox(new PVector(64,169), new PVector(101,146), new PVector(158,196), new PVector(148,206));
  treeBranches[1][1] = new BoundingBox(new PVector(158,196), new PVector(242,229), new PVector(244,250), new PVector(148,208));
  treeBranches[1][2] = new BoundingBox(new PVector(242,228), new PVector(245,266), new PVector(345,292), new PVector(345,206));
  treeBranches[1][3] = new BoundingBox(new PVector(345,206), new PVector(430,203), new PVector(583,403), new PVector(345,326));
  treeBranches[1][4] = new BoundingBox(new PVector(364,333), new PVector(545,391), new PVector(510,452), new PVector(362,350));
  treeBranches[1][5] = new BoundingBox(new PVector(379,361), new PVector(483,435), new PVector(428,517), new PVector(357,469));
  treeBranches[1][6] = new BoundingBox(new PVector(484,436), new PVector(509,454), new PVector(488,470), new PVector(472,454));
  treeBranches[1][7] = new BoundingBox(new PVector(429,203), new PVector(450,198), new PVector(734,236), new PVector(585,402));
  treeBranches[1][8] = new BoundingBox(new PVector(450,196), new PVector(553,55), new PVector(595,51), new PVector(735,236));
  treeBranches[1][9] = new BoundingBox(new PVector(597,53), new PVector(639,29), new PVector(718,27), new PVector(735,236));
  treeBranches[1][10] = new BoundingBox(new PVector(718,27), new PVector(762,1), new PVector(774,23), new PVector(735,235));
  treeBranches[1][11] = new BoundingBox(new PVector(703,271), new PVector(997,303), new PVector(951,413), new PVector(688,290));
  treeBranches[1][12] = new BoundingBox(new PVector(753,320), new PVector(951,414), new PVector(885,498), new PVector(739,450));
  treeBranches[1][13] = new BoundingBox(new PVector(749,453), new PVector(886,497), new PVector(889,526), new PVector(760,532));
  treeBranches[1][14] = new BoundingBox(new PVector(767,278), new PVector(815,124), new PVector(867,93), new PVector(996,303));
  treeBranches[1][15] = new BoundingBox(new PVector(867,95), new PVector(890,37), new PVector(964,99), new PVector(966,252));
  treeBranches[1][16] = new BoundingBox(new PVector(965,185), new PVector(1045,278), new PVector(996,304), new PVector(966,253));
  treeBranches[2] = new BoundingBox[13];
  treeBranches[2][0] = new BoundingBox(new PVector(74,325), new PVector(181,383), new PVector(249,420), new PVector(71,382));
  treeBranches[2][1] = new BoundingBox(new PVector(192,389), new PVector(305,395), new PVector(324,417), new PVector(249,421));
  treeBranches[2][2] = new BoundingBox(new PVector(304,394), new PVector(360,368), new PVector(362,406), new PVector(326,418));
  treeBranches[2][3] = new BoundingBox(new PVector(360,368), new PVector(400,294), new PVector(426,424), new PVector(363,407));
  treeBranches[2][4] = new BoundingBox(new PVector(400,293), new PVector(424,279), new PVector(502,255), new PVector(428,425));
  treeBranches[2][5] = new BoundingBox(new PVector(502,255), new PVector(582,393), new PVector(584,426), new PVector(427,426));
  treeBranches[2][6] = new BoundingBox(new PVector(502,255), new PVector(604,250), new PVector(618,273), new PVector(582,393));
  treeBranches[2][7] = new BoundingBox(new PVector(530,426), new PVector(584,426), new PVector(616,530), new PVector(602,545));
  treeBranches[2][8] = new BoundingBox(new PVector(601,631), new PVector(720,610), new PVector(724,634), new PVector(620,702));
  treeBranches[2][9] = new BoundingBox(new PVector(582,393), new PVector(897,364), new PVector(780,600), new PVector(600,630));
  treeBranches[2][10] = new BoundingBox(new PVector(619,274), new PVector(876,233), new PVector(897,362), new PVector(581,393));
  treeBranches[2][11] = new BoundingBox(new PVector(602,276), new PVector(620,73), new PVector(678,0), new PVector(698,261));
  treeBranches[2][12] = new BoundingBox(new PVector(679,1), new PVector(697,1), new PVector(875,232), new PVector(699,261));
  treeBranches[3] = new BoundingBox[14];
  treeBranches[3][0] = new BoundingBox(new PVector(29,419), new PVector(111,382), new PVector(134,382), new PVector(46,448));
  treeBranches[3][1] = new BoundingBox(new PVector(111,382), new PVector(145,323), new PVector(164,318), new PVector(135,381));
  treeBranches[3][2] = new BoundingBox(new PVector(165,317), new PVector(266,341), new PVector(244,350), new PVector(156,338));
  treeBranches[3][3] = new BoundingBox(new PVector(228,331), new PVector(384,297), new PVector(339,323), new PVector(269,342));
  treeBranches[3][4] = new BoundingBox(new PVector(339,323), new PVector(386,297), new PVector(840,456), new PVector(480,377));
  treeBranches[3][5] = new BoundingBox(new PVector(494,380), new PVector(840,457), new PVector(840,484), new PVector(620,478));
  treeBranches[3][6] = new BoundingBox(new PVector(663,479), new PVector(839,485), new PVector(834,524), new PVector(741,529));
  treeBranches[3][7] = new BoundingBox(new PVector(385,297), new PVector(399,238), new PVector(419,222), new PVector(840,456));
  treeBranches[3][8] = new BoundingBox(new PVector(420,222), new PVector(447,210), new PVector(752,80), new PVector(840,456));
  treeBranches[3][9] = new BoundingBox(new PVector(753,80), new PVector(805,124), new PVector(865,396), new PVector(840,456));
  treeBranches[3][10] = new BoundingBox(new PVector(447,210), new PVector(435,176), new PVector(482,106), new PVector(650,122));
  treeBranches[3][11] = new BoundingBox(new PVector(499,107), new PVector(535,63), new PVector(752,80), new PVector(651,123));
  treeBranches[3][12] = new BoundingBox(new PVector(552,63), new PVector(542,5), new PVector(578,11), new PVector(618,68));
  treeBranches[3][13] = new BoundingBox(new PVector(618,68), new PVector(625,24), new PVector(687,52), new PVector(697,74));
  treeBranches[4] = new BoundingBox[15];
  treeBranches[4][0] = new BoundingBox(new PVector(43,183), new PVector(154,170), new PVector(203,212), new PVector(89,249));
  treeBranches[4][1] = new BoundingBox(new PVector(154,169), new PVector(228,189), new PVector(234,211), new PVector(204,212));
  treeBranches[4][2] = new BoundingBox(new PVector(228,188), new PVector(249,183), new PVector(297,203), new PVector(236,212));
  treeBranches[4][3] = new BoundingBox(new PVector(250,183), new PVector(241,155), new PVector(291,128), new PVector(297,204));
  treeBranches[4][4] = new BoundingBox(new PVector(297,204), new PVector(291,46), new PVector(329,64), new PVector(376,283));
  treeBranches[4][5] = new BoundingBox(new PVector(330,63), new PVector(376,284), new PVector(418,225), new PVector(432,190));
  treeBranches[4][6] = new BoundingBox(new PVector(432,189), new PVector(400,94), new PVector(340,43), new PVector(331,63));
  treeBranches[4][7] = new BoundingBox(new PVector(412,234), new PVector(480,238), new PVector(482,272), new PVector(399,251));
  treeBranches[4][8] = new BoundingBox(new PVector(480,238), new PVector(821,313), new PVector(807,392), new PVector(483,275));
  treeBranches[4][9] = new BoundingBox(new PVector(479,238), new PVector(503,118), new PVector(801,133), new PVector(821,312));
  treeBranches[4][10] = new BoundingBox(new PVector(529,118), new PVector(566,11), new PVector(582,1), new PVector(786,132));
  treeBranches[4][11] = new BoundingBox(new PVector(656,47), new PVector(699,51), new PVector(800,133), new PVector(786,132));
  treeBranches[4][12] = new BoundingBox(new PVector(483,275), new PVector(808,393), new PVector(818,459), new PVector(526,449));
  treeBranches[4][13] = new BoundingBox(new PVector(535,449), new PVector(818,459), new PVector(649,620), new PVector(569,548));
  treeBranches[4][14] = new BoundingBox(new PVector(650,620), new PVector(818,460), new PVector(822,573), new PVector(748,642));
  treeBranches[5] = new BoundingBox[16];
  treeBranches[5][0] = new BoundingBox(new PVector(35,154), new PVector(101,166), new PVector(140,188), new PVector(42,204));
  treeBranches[5][1] = new BoundingBox(new PVector(100,164), new PVector(173,162), new PVector(195,186), new PVector(140,187));
  treeBranches[5][2] = new BoundingBox(new PVector(173,163), new PVector(228,177), new PVector(263,218), new PVector(196,187));
  treeBranches[5][3] = new BoundingBox(new PVector(247,198), new PVector(362,175), new PVector(358,188), new PVector(263,218));
  treeBranches[5][4] = new BoundingBox(new PVector(362,174), new PVector(422,194), new PVector(443,214), new PVector(359,189));
  treeBranches[5][5] = new BoundingBox(new PVector(421,193), new PVector(432,151), new PVector(448,146), new PVector(445,214));
  treeBranches[5][6] = new BoundingBox(new PVector(449,146), new PVector(504,158), new PVector(451,253), new PVector(444,214));
  treeBranches[5][7] = new BoundingBox(new PVector(504,158), new PVector(693,315), new PVector(688,330), new PVector(451,253));
  treeBranches[5][8] = new BoundingBox(new PVector(475,259), new PVector(687,329), new PVector(464,317), new PVector(459,283));
  treeBranches[5][9] = new BoundingBox(new PVector(465,317), new PVector(577,324), new PVector(576,372), new PVector(520,410));
  treeBranches[5][10] = new BoundingBox(new PVector(519,410), new PVector(558,383), new PVector(562,398), new PVector(519,429));
  treeBranches[5][11] = new BoundingBox(new PVector(577,324), new PVector(687,330), new PVector(591,388), new PVector(576,372));
  treeBranches[5][12] = new BoundingBox(new PVector(504,159), new PVector(598,24), new PVector(706,186), new PVector(693,313));
  treeBranches[5][13] = new BoundingBox(new PVector(633,76), new PVector(657,71), new PVector(678,95), new PVector(704,184));
  treeBranches[5][14] = new BoundingBox(new PVector(504,159), new PVector(522,2), new PVector(558,9), new PVector(598,24));
  treeBranches[5][15] = new BoundingBox(new PVector(505,158), new PVector(466,112), new PVector(504,24), new PVector(520,5));
  treeBranches[6] = new BoundingBox[14];
  treeBranches[6][0] = new BoundingBox(new PVector(53,228), new PVector(234,282), new PVector(138,302), new PVector(43,277));
  treeBranches[6][1] = new BoundingBox(new PVector(138,302), new PVector(232,282), new PVector(253,296), new PVector(224,313));
  treeBranches[6][2] = new BoundingBox(new PVector(233,281), new PVector(312,221), new PVector(341,233), new PVector(253,296));
  treeBranches[6][3] = new BoundingBox(new PVector(341,233), new PVector(515,343), new PVector(490,381), new PVector(317,251));
  treeBranches[6][4] = new BoundingBox(new PVector(347,273), new PVector(411,322), new PVector(348,321), new PVector(338,298));
  treeBranches[6][5] = new BoundingBox(new PVector(388,323), new PVector(412,323), new PVector(490,383), new PVector(402,488));
  treeBranches[6][6] = new BoundingBox(new PVector(491,382), new PVector(469,459), new PVector(441,473), new PVector(425,462));
  treeBranches[6][7] = new BoundingBox(new PVector(402,489), new PVector(424,462), new PVector(440,472), new PVector(432,509));
  treeBranches[6][8] = new BoundingBox(new PVector(375,254), new PVector(631,20), new PVector(715,86), new PVector(515,344));
  treeBranches[6][9] = new BoundingBox(new PVector(392,239), new PVector(392,192), new PVector(418,162), new PVector(568,77));
  treeBranches[6][10] = new BoundingBox(new PVector(481,126), new PVector(461,87), new PVector(468,21), new PVector(616,33));
  treeBranches[6][11] = new BoundingBox(new PVector(484,21), new PVector(539,1), new PVector(575,16), new PVector(573,28));
  treeBranches[6][12] = new BoundingBox(new PVector(549,301), new PVector(717,87), new PVector(632,438), new PVector(586,433));
  treeBranches[6][13] = new BoundingBox(new PVector(653,357), new PVector(717,87), new PVector(712,256), new PVector(673,347));
  treeBranches[7] = new BoundingBox[12];
  treeBranches[7][0] = new BoundingBox(new PVector(45,156), new PVector(200,165), new PVector(198,187), new PVector(49,202));
  treeBranches[7][1] = new BoundingBox(new PVector(201,165), new PVector(261,201), new PVector(263,218), new PVector(198,188));
  treeBranches[7][2] = new BoundingBox(new PVector(261,202), new PVector(359,174), new PVector(355,189), new PVector(262,219));
  treeBranches[7][3] = new BoundingBox(new PVector(360,173), new PVector(421,194), new PVector(441,215), new PVector(355,189));
  treeBranches[7][4] = new BoundingBox(new PVector(420,194), new PVector(432,150), new PVector(444,145), new PVector(443,216));
  treeBranches[7][5] = new BoundingBox(new PVector(444,145), new PVector(705,188), new PVector(701,211), new PVector(444,215));
  treeBranches[7][6] = new BoundingBox(new PVector(443,216), new PVector(700,211), new PVector(693,313), new PVector(684,331));
  treeBranches[7][7] = new BoundingBox(new PVector(442,216), new PVector(684,331), new PVector(467,257), new PVector(452,252));
  treeBranches[7][8] = new BoundingBox(new PVector(488,152), new PVector(463,110), new PVector(529,1), new PVector(587,27));
  treeBranches[7][9] = new BoundingBox(new PVector(488,152), new PVector(587,27), new PVector(618,41), new PVector(641,177));
  treeBranches[7][10] = new BoundingBox(new PVector(624,74), new PVector(661,69), new PVector(705,187), new PVector(641,178));
  treeBranches[7][11] = new BoundingBox(new PVector(475,261), new PVector(683,331), new PVector(522,428), new PVector(456,290));
}
