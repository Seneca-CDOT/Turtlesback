/* Debugging class
   Written by Andor
   Implemented and updated by Daniel Jun 4 2011
*/

public class gDebugger{
  private ArrayList strings;
  private PFont font;
  private int fontSize;
  private color textColor;
  private boolean isOn;

  public gDebugger(){
    strings = new ArrayList();
    setFont("verdana", 16);
    setColor(color(255));
    isOn = true;
  }
  public void add(String s){
    if(isOn){
      strings.add(s);
    }
  }
  
  // If off, the debugger will ignore calls to add() and draw()
  public void setOn(boolean on){
    isOn = on;
  }
  
  public void setFont(String fontName, int fsize){
    fontSize = fsize <= 0 ? 1 : fsize;
    font = createFont(fontName, fontSize);
  }
  
  public void setColor(color c){
    textColor = c;
  }
  
  public void clear(){
    while(strings.size() > 0){
      strings.remove(0);
    }
  }
  
  public void draw(){
    if(isOn){
      pushStyle();
      fill(textColor);
      textFont(font, fontSize);
      int y = fontSize+40;
      for(int i = 0; i < strings.size(); i++, y += fontSize){
        text((String)strings.get(i), 10, y);
      }
      popStyle();
      // Remove the strings since they have been rendered.
      clear();
    }
  }
  
  public boolean getStatus(){
    return isOn;
  }
}

