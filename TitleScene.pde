
enum TitleSceneState {
  TITLE_DROP, PRESS_START, MENU_OPENING, MENU_OPEN,
}

//
// this is the title scene, the first scene you see upon launching the game, it handles the intro sequence
// and also selecting a difficulty.
//
class TitleScene extends Scene {
  private TitleSceneState state;
  private TitleText titleText;
  private Text pressStartText;
  private MainMenu mainMenu;

  private float titleTextDuration;
  private Storyboard titleSequence;
  private Storyboard pressStartSequence;
  private Storyboard menuOpeningSequence;

  public TitleScene() {
    // add our particle field, simulated for 5 seconds
    this.children.add(new Background(5));

    this.state = TitleSceneState.TITLE_DROP;

    this.titleText = new TitleText(0, -100);
    this.pressStartText = new Text(0, 380, "PRESS START!", g_consolas64, color(0, 0, 0, 1));
    alignHorizontalCentre(pressStartText, width);

    // create our menu
    this.mainMenu = new MainMenu(this);
    this.mainMenu.setActive(false);

    // get the title storyboard and store its duration
    var titleTextStoryboard = titleText.getStoryboard();
    this.titleTextDuration = (float)titleTextStoryboard.getDuration();

    // create the title sequence storyboard
    this.titleSequence = new Storyboard()
      .add(0, titleTextStoryboard)
      .then(new Trigger(() -> startPressStart()));

    this.pressStartSequence = new Storyboard()
      .add(0, new Animation(0, 255, 0.5f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> pressStartText.fill = color(0, 0, 0, f)));

    // create a storyboard for opening the menu
    this.menuOpeningSequence = new Storyboard()
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

  // begins the title drop sequence
  void startTitleDrop() {
    this.state = TitleSceneState.TITLE_DROP;
    this.titleSequence.begin(this);
  }

  // begins the press start sequence
  void startPressStart() {
    this.state = TitleSceneState.PRESS_START;
    this.pressStartSequence.begin(this);
  }

  // opens the main menu
  void startMenuOpening() {
    this.state = TitleSceneState.MENU_OPENING;
    this.pressStartText.setActive(false);
    this.menuOpeningSequence.begin(this);
  }

  // tells the game that the main menu is open
  void startMenuOpen() {
    this.state = TitleSceneState.MENU_OPEN;
  }

  void goToGame(Difficulty difficulty, String word) {
    g_mainScene.goToScene(new GameScene(new GameSceneData(word, difficulty)));
  }

  void forceOpen() {
    titleText.skipAnimation();
    this.startMenuOpening();
  }

  boolean onKeyPressed() {
    if (state == TitleSceneState.TITLE_DROP) {
      // skip to the end of the title sequence
      titleSequence.stop();
      titleText.skipAnimation();
      startPressStart();
    } else if (state == TitleSceneState.PRESS_START) {
      g_audio.playCue(1);
      startMenuOpening();
    }

    return false;
  }

  void onMouseReleased(float x, float y) {
    if (state == TitleSceneState.TITLE_DROP) {
      // skip to the end of the title sequence
      titleSequence.stop();
      titleText.skipAnimation();
      startPressStart();
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
