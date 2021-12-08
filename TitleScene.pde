
enum TitleSceneState {
  TITLE_DROP,
    PRESS_START,
    MENU_OPENING,
    MENU_OPEN,
}


class TitleScene extends Scene {
  private TitleSceneState state;
  private TitleText titleText;
  private Text pressStartText;
  private MainMenu mainMenu;

  private float titleTextDuration;
  private Storyboard titleSequence;
  private Storyboard menuOpeningSequence;

  public TitleScene() {
    this.children.add(new Background());

    state = TitleSceneState.TITLE_DROP;
    titleText = new TitleText(0, -100);
    pressStartText = new Text(0, 380, "PRESS START!", g_consolas64, color(0, 0, 0, 1));
    alignHorizontalCentre(pressStartText, width);

    mainMenu = new MainMenu(this);
    mainMenu.setActive(false);

    Storyboard titleTextStoryboard = titleText.getStoryboard();

    titleTextDuration = (float)titleTextStoryboard.getDuration();

    titleSequence = new Storyboard()
      .add(0, titleTextStoryboard)
      .then(new Trigger(() -> startPressStart()))
      .then(new Animation(1, 254, 0.5f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> pressStartText.fill = color(0, 0, 0, f)));

    menuOpeningSequence = new Storyboard()
      .add(0.0f, new Animation(-100, -320, 0.5f, EASE_OUT_CUBIC, (f) -> titleText.y = f))
      .then(new Trigger(() -> mainMenu.setActive(true)))
      .with(mainMenu.getOpenAnimation());

    this.children.add(titleText);
    this.children.add(pressStartText);
    this.children.add(mainMenu);
  }
  
  void awakeObject() {
    if (this.state == TitleSceneState.TITLE_DROP) {
      this.startTitleDrop(); 
    }
    
    g_audio.playBgm(6, 0.5f);
  }

  void startTitleDrop() {
    state = TitleSceneState.TITLE_DROP;
    titleSequence.begin(this);
  }

  void startPressStart() {
    state = TitleSceneState.PRESS_START;
  }

  void startMenuOpening() {
    state = TitleSceneState.MENU_OPENING;
    pressStartText.setActive(false);
    menuOpeningSequence.begin(this);
  }

  void startMenuOpen() {
    state = TitleSceneState.MENU_OPEN;
  }

  void goToGame(Difficulty difficulty, String word) {
    g_mainScene.goToScene(new GameScene(new GameSceneData(word, difficulty)));
  }

  void drawObject() {
    noStroke();
    fill(255, 255, 255);
    clip(0, 0, w, h);
    rect(0, 0, w, h);
    stroke(1);
  }

  void forceOpen() {
    titleText.skipAnimation();
    this.startMenuOpening();
  }

  void keyPressed() {

    super.keyPressed();
    if (state == TitleSceneState.TITLE_DROP) {
      // skip to the end of the title sequence
      titleSequence.seek(titleTextDuration - 0.05f);
    } else if (state == TitleSceneState.PRESS_START) {
      g_audio.playCue(1);
      startMenuOpening();
    }
  }
  
  void cleanup() {
    titleSequence.stop();
    menuOpeningSequence.stop();
  }
}
