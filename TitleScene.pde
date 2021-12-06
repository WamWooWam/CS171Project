
enum TitleSceneState {
  TITLE_DROP,
    PRESS_START,
    MENU_OPENING,
    MENU_OPEN,
}


class TitleScene extends Scene {
  private TitleSceneState _state;
  private TitleText _titleText;
  private Text _pressStartText;
  private MainMenu _mainMenu;

  private float _titleTextDuration;
  private Storyboard _titleSequence;
  private Storyboard _menuOpeningSequence;

  public TitleScene() {
    this.children.add(new Background());

    _state = TitleSceneState.TITLE_DROP;
    _titleText = new TitleText(0, -100);
    _pressStartText = new Text(0, 380, "PRESS START!", g_consolas64);
    _pressStartText.x = (width - _pressStartText.w) / 2;
    _pressStartText.fill = color(0, 0, 0, 1);

    _mainMenu = new MainMenu(this);
    _mainMenu.setActive(false);

    Storyboard titleTextStoryboard = _titleText.getStoryboard();

    _titleTextDuration = titleTextStoryboard.getDuration();

    _titleSequence = new Storyboard()
      .add(0, titleTextStoryboard)
      .then(new Trigger(() -> startPressStart()))
      .then(new Animation(1, 254, 0.5f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> _pressStartText.fill = color(0, 0, 0, f)));

    _menuOpeningSequence = new Storyboard()
      .add(0.0f, new Animation(-100, -320, 0.5f, EASE_OUT_CUBIC, (f) -> _titleText.y = f))
      .then(new Trigger(() -> _mainMenu.setActive(true)))
      .with(_mainMenu.getOpenAnimation());

    this.children.add(_titleText);
    this.children.add(_pressStartText);
    this.children.add(_mainMenu);
  }
  
  void awakeObject() {
    if (this._state == TitleSceneState.TITLE_DROP) {
      this.startTitleDrop(); 
    }
    
    g_audio.playBgm(6, 0.5f);
  }

  void startTitleDrop() {
    _state = TitleSceneState.TITLE_DROP;
    _titleSequence.begin(this);
  }

  void startPressStart() {
    _state = TitleSceneState.PRESS_START;
  }

  void startMenuOpening() {
    _state = TitleSceneState.MENU_OPENING;
    _pressStartText.setActive(false);
    _menuOpeningSequence.begin(this);
  }

  void startMenuOpen() {
    _state = TitleSceneState.MENU_OPEN;
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
    _titleText.skipAnimation();
    this.startMenuOpening();
  }

  void keyPressed() {
    super.keyPressed();
    if (_state == TitleSceneState.TITLE_DROP) {
      // skip to the end of the title sequence
      _titleSequence.seek(_titleTextDuration - 0.05f);
    } else if (_state == TitleSceneState.PRESS_START) {
      g_audio.playCue(1);
      startMenuOpening();
    } else if (_state == TitleSceneState.MENU_OPENING) {
      // skip to the end of the menu sequence
      _menuOpeningSequence.seek(_menuOpeningSequence.getDuration() - 0.05f);
    }
  }
}
