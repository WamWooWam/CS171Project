
// 
// this object handles the H_ngm_n! text on the title screen
//

class TitleText extends GameObject {
  private Storyboard titleStoryboard;

  // each character falls for 1 second, with a spacing of 1/3rd of a second, from y=0 to y=360
  private final float ANIMATION_TIME = 1.0f;
  private final float ANIMATION_SPACE = 1.0f / 3.0f;
  private final int ANIMATION_Y = 360;

  public TitleText(float x, float y) {
    super(x, y, getWidth(g_consolas64) * 2 * TITLE_CHARS.length, 64);
    this.x = (width - this.w) / 2f;

    titleStoryboard = new Storyboard();
    for (int i = 0; i < TITLE_CHARS.length; i++) {
      HangmanCharacter character = new HangmanCharacter(getWidth(g_consolas64) * 2 * i, 0, TITLE_CHARS[i]);
      titleStoryboard.add(i * ANIMATION_SPACE, new Animation(0, ANIMATION_Y, ANIMATION_TIME, EASE_OUT_CUBIC, f -> character.y = f));
      this.children.add(character);
    }
  }

  Storyboard getStoryboard() {
    return titleStoryboard;
  }
  
  // skips the animation by forcing all characters to their final Y positions
  void skipAnimation() {
    for (int i = 0; i < TITLE_CHARS.length; i++) {
      this.children.get(i).y = ANIMATION_Y;
    }
  }
}
