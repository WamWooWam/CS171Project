
//
// this class draws a hangman character, that is either a space, an _ or an underlined character
//
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
    h = textAscent();
  }

  void drawObject() {
    textFont(font);

    // dont draw spaces
    if (character == ' ')
      return;
    
    // draw the character if it's not null
    if (character != 0)
      text(character, 0, this.h);
    // and the underline
    text('_', 0, this.h);
  }
}
