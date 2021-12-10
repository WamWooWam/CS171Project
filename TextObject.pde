
//
// This object is used to draw text on the screen
//
public class Text extends GameObject {

  private String text;
  private PFont font;

  public Text(float x, float y, String text, PFont font, color col) {
    super(x, y, 0, 0);
    this.fill = col;
    this.font = font;
    this.setText(text);
  }

  public Text(float x, float y, String text, PFont font) {
    this(x, y, text, font, color(0, 0, 0));
  }

  // sets the text to be drawn, ensures bounds are measured correctly
  void setText(String text) {
    textFont(this.font);
    
    this.h = textAscent();
    this.w = textWidth(text);
    this.text = text;
  }
  
  void drawObject() {
    textFont(font);
    text(text, 0, this.h);
  }
}
