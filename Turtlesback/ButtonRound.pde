class ButtonRound extends Button {
  ButtonRound(int x, int y, float r){
    super(x,y,r);
    hasImage= false;
    hasText = false;
  }
  
  //This is an actual round button. Amazing!
  boolean over(int x, int y){
    // x and y are screen coordinates
    isOver = sqrt(((this.x-x) * (this.x-x)) + ((this.y-y) * (this.y-y))) <= radius;
    return isOver;
  }
}
