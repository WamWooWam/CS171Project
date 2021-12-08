enum MenuState {
  OPENING,
    PAGE1,
    TRANSITION,
    PAGE2,
    CLOSED
}

class MainMenuPage1 extends GameObject {
  private int selectedButton = 0;
  private ArrayList<MenuButton> buttons;
  private Text difficultyText;
  private MainMenu menu;

  public MainMenuPage1(MainMenu menu, float x, float y, float w, float h) {
    super(x, y, w, h);

    this.menu = menu;
    buttons = new ArrayList<MenuButton>();
    buttons.add(new MenuButton(12, 84, w - 24, 48, "Easy"));
    buttons.add(new MenuButton(12, 144, w - 24, 48, "Normal"));
    buttons.add(new MenuButton(12, 204, w - 24, 48, "Hard"));
    buttons.add(new MenuButton(12, 264, w - 24, 48, "Custom"));

    difficultyText = new Text(12, 12, "Select a Difficulty", g_consolas48);
    alignHorizontalCentre(difficultyText, w);

    this.children.add(difficultyText);
    this.children.addAll(buttons);
  }

  void updateObject(float deltaTime) {
    for (int i = 0; i < buttons.size(); i++) {
      buttons.get(i).isSelected = i == selectedButton;
    }
  }

  void keyPressed() {
    super.keyPressed();
    if (menu.state != MenuState.PAGE1) return;
    if (keyCode == UP) {
      selectedButton = selectedButton - 1;
      g_audio.playCue(0);
    }

    if (keyCode == DOWN) {
      selectedButton = selectedButton + 1;
      g_audio.playCue(0);
    }

    if (selectedButton >= buttons.size()) {
      selectedButton = 0;
    }

    if (selectedButton < 0) {
      selectedButton = buttons.size() - 1;
    }

    if (keyCode == ENTER || keyCode == RETURN) {
      menu.state = MenuState.TRANSITION;
      g_audio.playCue(1);

      var board = new Storyboard();
      board.add(0.0f, buttons.get(selectedButton).getPressAnimation());
      if (selectedButton == 3) {
        board.add(0.2f, new Trigger(() -> menu.goToCustom()));
      } else {
        board.add(0.2f, new Trigger(() -> menu.goToGame(getDifficulty(selectedButton), null)));
      }

      board.begin(this);
    }
  }
}

class MainMenuPage2 extends GameObject {

  private Text customGame;
  private Text customGameExplain;
  private MainMenu menu;
  private ArrayList<HangmanCharacter> characters;

  public MainMenuPage2(MainMenu menu, float x, float y, float w, float h) {
    super(x, y, w, h);

    this.menu = menu;

    this.customGame = new Text(12, 12, "Custom Game", g_consolas48);
    this.children.add(customGame);

    this.customGameExplain = new Text(12, 64, "Type a word for a friend to guess!", g_consolas32);
    this.children.add(customGameExplain);

    alignHorizontalCentre(customGame, w);
    alignHorizontalCentre(customGameExplain, w);

    this.characters = new ArrayList<HangmanCharacter>();
    this.addTerminatorChar();
    this.layoutCharacters();

    // make the last typed character (the _) blink
    var animation = new Animation(255, 1, 0.5f, -1, LoopMode.REVERSE, LINEAR, (f) ->  this.characters.get(this.characters.size() - 1).fill = color(0, 0, 0, f));
    animation.begin(this);
  }

  void layoutCharacters() {
    int characterCount = this.characters.size();

    float charWidth = g_consolas48CharWidth;
    float charSpacing = min((600 - ((charWidth) * characterCount)) / characterCount, 16);
    float startY = (height / 3) + 64;
    float startX = 100 + (600 - ((charWidth + charSpacing) * characterCount)) / 2;

    for (int i = 0; i < characterCount; i++) {
      var character = this.characters.get(i);
      character.x = startX + ((charWidth + charSpacing) * i);
      character.y = startY;
    }
  }

  void updateObject(float dt) {
    for (int i = 0; i < characters.size(); i++) {
      this.characters.get(i).update(dt);
    }
  }

  void drawObject() {
    for (int i = 0; i < characters.size(); i++) {
      this.characters.get(i).draw();
    }
  }

  void addTerminatorChar() {
    var nextCharacter = new HangmanCharacter(0, 0, '\0', g_consolas48);
    this.characters.add(nextCharacter);
  }

  void keyPressed() {
    super.keyPressed();
    if (menu.state != MenuState.PAGE2) return;

    if (keyCode == ESC) {
      this.characters.clear();
      this.addTerminatorChar();

      menu.goToMain();
    }

    if (keyCode == BACKSPACE && this.characters.size() > 1) {
      this.characters.remove(this.characters.size() - 2);
    }

    if (keyCode == RETURN || keyCode == ENTER && this.characters.size() > 3) {
      String word = "";
      for (int i = 0; i < this.characters.size() - 1; i++) {
        word += this.characters.get(i).character;
      }

      if (word.trim().length() > 3)
        menu.goToGame(Difficulty.CUSTOM, word.trim());
    }

    var keyChar = Character.toLowerCase(key);
    if ((keyChar == ' ' || ALLOWED_CHARS.indexOf(keyChar) != -1) && this.characters.size() < 25) {
      var character = this.characters.get(this.characters.size() - 1);
      character.character = keyChar;

      this.addTerminatorChar();
      character.fill = color(0, 0, 0);
    }

    this.layoutCharacters();
  }
}

class MainMenu extends GameObject {
  public MenuState state = MenuState.OPENING;

  // for the opening clip effect, we have to scale the clipping rect around its centre
  // in order to make this maths easier, we keep the width, height, centre x, centre y
  // top left corner, and top right corner values of the menu in sync here.
  private static final float MENU_WIDTH = 800;
  private static final float MENU_HEIGHT = 500;
  private static final float MENU_X = 640;
  private static final float MENU_Y = 420;
  private static final float MENU_LEFT = MENU_X - (MENU_WIDTH / 2);
  private static final float MENU_TOP = MENU_Y - (MENU_HEIGHT / 2);

  private float currentHeight = 0.0f;

  private Storyboard menuOpenAnimation;
  private Storyboard goToCustomAnimation;
  private Storyboard goToMainAnimation;

  private MainMenuPage1 page1;
  private MainMenuPage2 page2;

  private TitleScene titleScene;

  public MainMenu(TitleScene titleScene) {
    super(MENU_LEFT, MENU_TOP, MENU_WIDTH, MENU_HEIGHT);

    this.titleScene = titleScene;
    this.page1 = new MainMenuPage1(this, 0, 0, MENU_WIDTH, MENU_HEIGHT);
    this.page2 = new MainMenuPage2(this, -MENU_WIDTH, 0, MENU_WIDTH, MENU_HEIGHT);

    this.children.add(this.page1);
    this.children.add(this.page2);

    this.menuOpenAnimation = new Storyboard()
      .add(0.0f, new Animation(0, MENU_HEIGHT, 0.5f, EASE_OUT_CUBIC, (f) -> this.currentHeight = f))
      .then(new Trigger(() -> this.state = MenuState.PAGE1));

    this.goToCustomAnimation = new Storyboard()
      .add(0.0f, new Animation(0, MENU_WIDTH, 0.5f, EASE_OUT_CUBIC, (f) -> this.page1.x = f))
      .add(0.0f, new Animation(-MENU_WIDTH, 0, 0.5f, EASE_OUT_CUBIC, (f) -> this.page2.x = f))
      .then(new Trigger(() -> this.state = MenuState.PAGE2));

    this.goToMainAnimation = new Storyboard()
      .add(0.0f, new Animation(0, -MENU_WIDTH, 0.5f, EASE_OUT_CUBIC, (f) -> this.page2.x = f))
      .add(0.0f, new Animation(MENU_WIDTH, 0, 0.5f, EASE_OUT_CUBIC, (f) -> this.page1.x = f))
      .then(new Trigger(() -> this.state = MenuState.PAGE1));
  }

  Storyboard getOpenAnimation() {
    return this.menuOpenAnimation;
  }

  void goToMain() {
    this.state = MenuState.TRANSITION;
    this.goToMainAnimation.begin(this);
  }

  void goToCustom() {
    this.state = MenuState.TRANSITION;
    this.goToCustomAnimation.begin(this);
  }

  void goToGame(Difficulty difficulty, String word) {
    this.state = MenuState.TRANSITION;
    this.titleScene.goToGame(difficulty, word);
  }

  void drawObject() {
    stroke(0, 0, 0);
    strokeWeight(1);
    fill(255, 255, 255);
    rect(0, ((MENU_HEIGHT - this.currentHeight) / 2), MENU_WIDTH, this.currentHeight);
    clip(0, ((MENU_HEIGHT - this.currentHeight) / 2), MENU_WIDTH, this.currentHeight);
  }
}
