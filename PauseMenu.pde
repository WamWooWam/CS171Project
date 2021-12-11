
//
// this file handles the pause menu/game overlay
//

class PauseOverlay extends GameObject {
  private PauseMenu menu;
  private Rectangle overlayRect;

  private Storyboard menuOpenAnimation;
  private Storyboard menuCloseAnimation;

  public PauseOverlay() {
    super(0, 0, width, height);

    // create the actual pause menu
    menu = new PauseMenu();

    // create a rectangle to dim the screen
    overlayRect = new Rectangle(0, 0, width, height);
    overlayRect.strokeThickness = 0;
    overlayRect.fill = color(0, 0, 0, 1);

    // to show the menu, fade in the background overlay, fade out the audio, and open the menu
    this.menuOpenAnimation = new Storyboard()
      .add(0.0f, new Animation(0, 256, 0.33f, EASE_OUT_CUBIC, (f) -> this.menu.currentHeight = f))
      .with(new Animation(1, 64, 0.33f, (f) -> this.overlayRect.fill = color(0, 0, 0, f)))
      .with(new Animation(1.0f, 0.5f, 0.33f, (f) -> g_audio.setVolume(f)));

    // reverse this to close
    this.menuCloseAnimation = new Storyboard()
      .add(0.0f, new Animation(256, 0, 0.33f, EASE_OUT_CUBIC, (f) -> this.menu.currentHeight = f))
      .with(new Animation(64, 1, 0.33f, (f) -> this.overlayRect.fill = color(0, 0, 0, f)))
      .with(new Animation(0.5f, 1f, 0.33f, (f) -> g_audio.setVolume(f)))
      .then(new Trigger(() -> this.setActive(false)));

    this.children.add(overlayRect);
    this.children.add(menu);
  }

  // shows the menu
  void open() {
    this.setActive(true);
    this.menuOpenAnimation.begin(this);
  }

  // hides the menu
  void close() {
    this.menuCloseAnimation.begin(this);
  }

  // ensures the selected button is always the first when open
  void awakeObject() {
    menu.selectedButton = 0;
  }

  boolean onKeyPressed() {
    if (keyCode == ESC) {
      g_mainScene.togglePause();
      return true;
    }

    return false;
  }
}

class PauseMenu extends ButtonContainer {
  // for the opening clip effect, we have to scale the clipping rect around its centre
  // in order to make this maths easier, we keep the width, height, centre x, centre y
  // top left corner, and top right corner values of the menu in sync here.
  private static final float MENU_WIDTH = 400;
  private static final float MENU_HEIGHT = 256;
  private static final float MENU_X = 640;
  private static final float MENU_Y = 360;
  private static final float MENU_LEFT = MENU_X - (MENU_WIDTH / 2);
  private static final float MENU_TOP = MENU_Y - (MENU_HEIGHT / 2);

  float currentHeight = 0.0f;

  public PauseMenu() {
    super(MENU_LEFT, MENU_TOP, MENU_WIDTH, MENU_HEIGHT);

    var titleText = new Text(0, 24, "Paused", g_consolas48);
    alignHorizontalCentre(titleText, w);

    this.children.add(titleText);
    
    this.addButton(12, 96, w - 24, 48, "Resume");
    this.addButton(12, 160, w - 24, 48, "Quit to Title");
  }

  boolean shouldHandleEvents() {
    return true;
  }

  void onClick(int idx) {
    // close this menu
    g_audio.playCue(1);
    g_mainScene.togglePause();

    // return to the title screen if selected
    if (idx == 1) {
      var scene = new TitleScene();
      scene.forceOpen();
      g_mainScene.goToScene(scene);
    }
  }

  void drawObject() {
    stroke(0, 0, 0);
    strokeWeight(1);
    fill(255, 255, 255);
    rect(0, ((MENU_HEIGHT - this.currentHeight) / 2), MENU_WIDTH, this.currentHeight);
    clip(MENU_LEFT, MENU_TOP + ((MENU_HEIGHT - this.currentHeight) / 2), MENU_WIDTH, this.currentHeight);
  }
}
