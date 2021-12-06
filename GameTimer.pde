
//
// Displays a simple MM:SS timer
//
class GameTimer extends Text {
  private GameSceneData state;
  private Animation blinkingAnimation;

  public GameTimer(GameSceneData state, float x, float y) {
    super(x, y, "0:00", g_consolas48);
    this.state = state;
  }

  void updateObject(float deltaTime) {
    int remaining = (int)Math.ceil(state.remainingTime);
    int secs = remaining % 60;
    int mins = remaining / 60;

    // https://stackoverflow.com/questions/473282/how-can-i-pad-an-integer-with-zeros-on-the-left
    this.setText(mins + ":" + String.format("%02d", secs));
  }

  void startBlinking() {
    if (blinkingAnimation == null) {
      blinkingAnimation = new Animation(0, 255, 0.5f, -1, LoopMode.REVERSE, ROUND, (f) -> fill = color(f, 0, 0));
      blinkingAnimation.begin(this);
    }
  }
}
