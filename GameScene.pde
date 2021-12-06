
import java.util.*;

enum GameState {
  INTRO, PLAYING, WON, LOST, ENDED
}

class GameSceneData {
  String word;
  Difficulty difficulty;

  float totalTime;
  float remainingTime;

  char[] wordState;
  char[] wordCharacters;
  ArrayList<Character> usedCharacters;

  int bgm = 2;
  int mistakes = 0;
  GameState state;

  public GameSceneData(String word, Difficulty difficulty) {
    this.state = GameState.INTRO;
    this.difficulty = difficulty;
    if (word == null) {
      switch(difficulty) {
      case EASY:
        word = g_easyWords.next();
        break;
      case NORMAL:
        word = g_normalWords.next();
        break;
      case HARD:
        word = g_hardWords.next();
        break;
      default:
        throw new IllegalArgumentException("Difficulty is custom and a word was not supplied!");
      }
    }

    // switch the music randomly
    this.bgm = (int)random(2, 6);

    // https://youtu.be/TLVGmvmNitg?t=889
    // println(word);

    this.word = word;
    // this stores the word as it appears on the player's screen
    this.wordState = new char[word.length()];
    // this stores the actual word
    this.wordCharacters = word.toCharArray();
    // this stores the set of characters that have already been played
    this.usedCharacters = new ArrayList<Character>();

    // copy over any spaces in the word (we dont wanna include these)
    for (int i = 0; i < word.length(); i++) {
      if (wordCharacters[i] == ' ') {
        wordState[i] = ' ';
      }
    }

    // the player has 2 minutes
    totalTime = 120.0f;
    remainingTime = totalTime;
  }

  void startPlay() {
    state = GameState.PLAYING;
  }

  void pause() {
  }

  void update(float dt) {
    if (state == GameState.PLAYING) {
      remainingTime = max(0, remainingTime - dt);
      if (remainingTime == 0) {
        state = GameState.LOST;
      }
    }
  }

  void keyPressed(char keyChar) {
    if (state != GameState.PLAYING) return;

    if (keyCode == ESC) {
      g_mainScene.togglePause();
      state = GameState.INTRO;
    }

    keyChar = Character.toLowerCase(keyChar);
    if (ALLOWED_CHARS.indexOf(keyChar) == -1 || this.usedCharacters.contains(keyChar)) return;

    boolean flag = false;
    for (int i = 0; i < word.length(); i++) {
      if (wordCharacters[i] == keyChar) {
        flag = true;
        wordState[i] = keyChar;
      }
    }

    this.usedCharacters.add(keyChar);

    if (!flag) {
      mistakes = min(mistakes + 1, MAX_MISTAKES);
      if (mistakes == MAX_MISTAKES) {
        state = GameState.LOST;
      }
    } else {
      // turns out .equals checks nicely, including order, who knew
      if (Arrays.equals(wordCharacters, wordState)) {
        // you're winner
        state = GameState.WON;
      }
    }
  }
}

static final int MAX_WORD_WIDTH = 700;

class GameScene extends Scene {
  GameSceneData state;
  GameTimer timer;

  Text ready;
  Text set;
  Text go;

  Hangman hangman;
  HangmanCharacter[] characters;
  Storyboard characterAnimation;

  Text[] usedCharacters;

  ResultsScreen resultsScreen;

  public GameScene(GameSceneData data) {
    state = data;
    characters = new HangmanCharacter[state.word.length()];

    this.timer = new GameTimer(this.state, 0, 16);
    this.children.add(timer);

    hangman = new Hangman(this.state, 64, 64);
    this.children.add(hangman);

    PFont font = g_consolas56;
    int characterCount = state.word.length();

    float charWidth = g_consolas56CharWidth;
    float charSpacing = min((MAX_WORD_WIDTH - ((charWidth) * characterCount)) / characterCount, 16);
    float startY = (height - (charWidth * 2)) / 2;
    float startX = 540 + (MAX_WORD_WIDTH - ((charWidth + charSpacing) * characterCount)) / 2;

    characterAnimation = new Storyboard();

    for (int i = 0; i < state.word.length(); i++) {
      var character = new HangmanCharacter(startX + ((charWidth + charSpacing) * i), startY, state.wordState[i], font);
      character.w = charWidth;
      character.h = charWidth * 2;

      this.children.add(characters[i] = character);

      characterAnimation.add((i % 2) / 2.0f, new Animation(0, 10, 1f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> character.y = startY + f));
    }

    ready = new Text(0, 0, "Ready", g_consolas96, color(0, 0, 0, 1));
    set = new Text(0, 0, "Set", g_consolas96, color(0, 0, 0, 1));
    go = new Text(0, 0, "Go!", g_consolas96, color(0, 0, 0, 1));

    alignCentre(ready, width, height - 64);
    alignCentre(set, width, height - 64);
    alignCentre(go, width, height - 64);

    this.children.add(ready);
    this.children.add(set);
    this.children.add(go);

    this.createUsedLetters();

    resultsScreen = new ResultsScreen(this, state);
    resultsScreen.setActive(false);
    this.children.add(resultsScreen);
  }

  void awakeObject() {
    this.playIntro();
  }

  void playIntro() {
    this.characterAnimation.stop();

    var sb = new Storyboard();

    sb.add(0.0f, new Trigger(() -> g_audio.playBgm(this.state.bgm, 0.5f)))
      .then(1.0f, new Trigger(() -> ready.fill = color(0, 0, 0, 255)))
      .with(new Trigger(() -> g_audio.playCue(5)))
      .then(0.25f, new Animation(255, 1, 0.75f, LINEAR, (f) -> ready.fill = color(0, 0, 0, f)))
      .then(0.25f, new Trigger(() -> set.fill = color(0, 0, 0, 255)))
      .with(new Trigger(() -> g_audio.playCue(5)))
      .then(0.25f, new Animation(255, 1, 0.75f, LINEAR, (f) -> set.fill = color(0, 0, 0, f)))
      .then(0.25f, new Trigger(() -> go.fill = color(0, 0, 0, 255)))
      .with(new Trigger(() -> g_audio.playCue(6)))
      .with(new Trigger(() -> this.state.startPlay()))
      .with(new Trigger(() -> this.characterAnimation.begin(this)))
      .then(0.25f, new Animation(255, 1, 0.5f, LINEAR, (f) -> go.fill = color(0, 0, 0, f)));

    sb.begin(this);
  }

  void updateObject(float deltaTime) {
    if (wasPaused) {
      playIntro();
    }

    this.state.update(deltaTime);
    this.timer.x = width - this.timer.w - 32;

    // if the player has 30 seconds left or less, warn them
    if (this.state.remainingTime <= 30.0f) {
      this.timer.startBlinking();
    }

    // if the player has 12 seconds left or less, scare the shit out of them
    if (this.state.remainingTime <= 12f && this.state.bgm != 7) {
      this.state.bgm = 7;
      g_audio.playBgm(7, 0.5f);
    }

    for (int i = 0; i < state.usedCharacters.size(); i++) {
      if (state.word.indexOf(state.usedCharacters.get(i))== -1) {
        var text = usedCharacters[i];
        text.setActive(true);
        text.setText("" + state.usedCharacters.get(i));
      }
    }

    for (int i = 0; i < state.word.length(); i++) {
      characters[i].character = state.wordState[i];
    }

    if (this.state.state == GameState.LOST) {
      characterAnimation.stop();
    }

    if (this.state.state == GameState.WON) {
      characterAnimation.stop();
      resultsScreen.setActive(true);
      resultsScreen.showWin();

      this.state.state = GameState.ENDED;
    }

    if (this.state.state == GameState.LOST) {
      characterAnimation.stop();
      resultsScreen.setActive(true);
      resultsScreen.showLose();

      this.state.state = GameState.ENDED;
    }
  }

  void keyPressed() {
    super.keyPressed();
    this.state.keyPressed(key);
  }

  void createUsedLetters() {
    usedCharacters = new Text[26];
    for (int i = 0; i < usedCharacters.length; i++) {
      var flag = false;
      var text = new Text(0, 0, "", g_consolas32);

      // this places each character until it intersects with the bounds of no others
      do {
        text.x = random(720, 1120);
        text.y = random(400, 620);
        text.h = 20;

        flag = false;
        var bounds = text.getBounds();
        for (int j = 0; j < i; j++) {
          var text2 = usedCharacters[j];
          var bounds2 = new Rectangle2D.Float(text2.x - 16, text2.y - 16, text.w + 32, text.h + 32);
          if (bounds2.intersects(bounds)) {
            flag = true;
            break;
          }
        }
      } while (flag);

      usedCharacters[i] = text;
      usedCharacters[i].setActive(false);
      this.children.add(usedCharacters[i]);
    }

    var storyboard = new Storyboard();
    for (int i = 0; i < usedCharacters.length; i++) {
      var character = usedCharacters[i];
      storyboard.add(i * 0.05f, new Animation(random(-30, -15), random(15, 30), 1f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> character.rot = f));
    }

    storyboard.begin(this);
  }

  void cleanup() {
    for (int i = 0; i < this.children.size(); i++) {
      GameObject child = this.children.get(i);
      if (child instanceof AnimationBase) {
        ((AnimationBase)child).stop();
      }
    }

    resultsScreen.cleanup();
  }
}
