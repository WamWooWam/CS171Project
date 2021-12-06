
char[] titleChars = { 'H', 0, 'n', 'g', 'm', 0, 'n', '!' };

class TitleText extends GameObject {
  private Storyboard titleStoryboard;
  private final float ANIMATION_TIME = 1.0f;
  private final float ANIMATION_SPACE = 1.0f / 3.0f;
  private final int ANIMATION_Y = 420;

  public TitleText(float x, float y) {
    super(x, y, g_consolas64CharWidth * 2 * titleChars.length, 64);
    this.x = (width - this.w) / 2f;

    titleStoryboard = new Storyboard();
    for (int i = 0; i < titleChars.length; i++) {
      HangmanCharacter character = new HangmanCharacter(g_consolas64CharWidth * 2 * i, 0, titleChars[i]);
      titleStoryboard.add(i * ANIMATION_SPACE, new Animation(0, ANIMATION_Y, ANIMATION_TIME, EASE_OUT_CUBIC, f -> character.y = f));
      this.children.add(character);
    }
  }

  Storyboard getStoryboard() {
    return titleStoryboard;
  }

  void skipAnimation() {
    for (int i = 0; i < titleChars.length; i++) {
      this.children.get(i).y = ANIMATION_Y;
    }
  }
}
