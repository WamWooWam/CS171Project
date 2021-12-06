
class HangmanCharacter extends GameObject {
  PFont font;
  char character;

  public HangmanCharacter(float x, float y, char character) {
    this(x, y, character, g_consolas96);
  }

  public HangmanCharacter(float x, float y, char character, PFont font) {
    super(x, y, 0, 0);
    this.font = font;
    this.character = character;
    this.fill = color(0, 0, 0);
    
    textFont(font);
    w = textWidth("w");
    h = 0;
  }  

  void drawObject() {
    textFont(font);
    
    if (character != 0)
      text(character, 0, 0);
    if (character != ' ')
      text('_', 0,0);
  }
}
