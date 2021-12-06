
public class Text extends GameObject {

  private String text;
  private PFont font;

  public Text(float x, float y, String text, PFont font) {
    super(x, y, 0, font.getSize());
    this.fill = color(0, 0, 0);
    this.font = font;
    this.setText(text);
  }

  void setText(String text) {
    textFont(this.font);
    this.w = textWidth(text);
    this.text = text;
  }

  void updateObject(float deltaTime) {
  }

  void drawObject() {
    textFont(font);
    text(text, 0, this.h);
  }
}
