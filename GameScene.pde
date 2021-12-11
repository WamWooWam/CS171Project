
import java.util.*;

//
// This file contains the main implementation of the hangman game itself.
//

enum GameState {
  INTRO, PLAYING, WON, LOST, ENDED
}

class GameSceneData {
  String word; // the word in play
  Difficulty difficulty; // the current difficulty

  float totalTime; // the total time the player has
  float remainingTime; // the remaining time the player has

  char[] wordState; // the current state of the word, any character that hasn't been found yet is '\0'
  char[] wordCharacters; // the actual word, as an array
  ArrayList<Character> usedCharacters; // a list of characters that have been played

  int bgm = 2; // the music track to play/playing
  int mistakes = 0; // the current number of mistakes made by the player
  GameState state; // the current game state (i.e. in play, won, lost, etc.)

  public GameSceneData(String word, Difficulty difficulty) {
    this.state = GameState.INTRO;
    this.difficulty = difficulty;

    // if we dont have a word, get one from the list.
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
    this.usedCharacters = new ArrayList<>();

    // copy over any spaces in the word (we dont wanna play these)
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
      // keep track of if the player times out
      remainingTime = max(0, remainingTime - dt);
      if (remainingTime <= 0) {
        state = GameState.LOST;
      }
    }
  }

  void keyPressed(char keyChar) {
    if (state != GameState.PLAYING) return;

    if (g_ctrlPressed && keyCode == RIGHT) {
      remainingTime = max(0, remainingTime - 10);
    }

    keyChar = Character.toLowerCase(keyChar);

    // if the character is invalid or has been played already, continue
    if (ALLOWED_CHARS.indexOf(keyChar) == -1 || this.usedCharacters.contains(keyChar)) return;

    // if the character is in the word, this flag is set, and the loop copies from the word into the current state
    boolean flag = false;
    for (int i = 0; i < word.length(); i++) {
      if (wordCharacters[i] == keyChar) {
        flag = true;
        wordState[i] = keyChar;
      }
    }

    // keep track of used characters
    this.usedCharacters.add(keyChar);

    // if the character was in the word
    if (flag) {
      // checks if the word is complete
      // turns out .equals checks nicely, including order, who knew
      if (Arrays.equals(wordCharacters, wordState)) {
        // you're winner
        state = GameState.WON;
      }
    } else {
      // otherwise, add a mistake
      mistakes = min(mistakes + 1, MAX_MISTAKES);
      if (mistakes == MAX_MISTAKES) {
        state = GameState.LOST;
      }
    }
  }
}

// maxmimum width for a word in play, used for layout
static final int MAX_WORD_WIDTH = 700;

class GameScene extends Scene {
  GameSceneData state; // current game state
  GameTimer timer; // the game timer object

  // countdown text
  Text ready; // ready text
  Text set; // set text
  Text go; // go text
  
  Hangman hangman; // the hangman object
  HangmanCharacter[] characters; // the characters in play
  Storyboard characterAnimation; // the characters' wobble animation

  Text[] usedCharacters; // the characters that have been used

  ResultsScreen resultsScreen; // the results screen

  public GameScene(GameSceneData data) {
    this.state = data;

    // create our timer
    this.timer = new GameTimer(this.state, 0, 16);
    this.children.add(timer);

    // create our hangman
    this.hangman = new Hangman(this.state, 64, 64);
    this.children.add(hangman);

    this.createCharacters();

    // create and align the countdown text
    this.ready = new Text(0, 0, "Ready", g_consolas96, color(0, 0, 0, 1));
    this.set = new Text(0, 0, "Set", g_consolas96, color(0, 0, 0, 1));
    this.go = new Text(0, 0, "Go!", g_consolas96, color(0, 0, 0, 1));

    alignCentre(ready, width, height - 64);
    alignCentre(set, width, height - 64);
    alignCentre(go, width, height - 64);

    this.children.add(ready);
    this.children.add(set);
    this.children.add(go);

    this.createUsedLetters();

    // create and hide the results screen
    this.resultsScreen = new ResultsScreen(this, state);
    this.resultsScreen.setActive(false);
    this.children.add(this.resultsScreen);
  }

  void awakeObject() {
    this.playIntro();
  }

  void playIntro() {
    this.characterAnimation.stop();
    
    // count down through "ready", "set", "go", by setting the opacity to 100%, then fading out,
    // playing a sound cue at the same time
    var sb = new Storyboard();
    sb.add(0.0f, new Trigger(() -> g_audio.playBgm(this.state.bgm, 0.5f)))
      .then(1.0f, new Trigger(() -> ready.fill = color(0, 0, 0, 255)))
      .with(new Trigger(() -> g_audio.playCue(5)))
      .then(0.25f, new Animation(255, 0, 0.75f, (f) -> ready.fill = color(0, 0, 0, f)))
      .then(0.25f, new Trigger(() -> set.fill = color(0, 0, 0, 255)))
      .with(new Trigger(() -> g_audio.playCue(5)))
      .then(0.25f, new Animation(255, 0, 0.75f, (f) -> set.fill = color(0, 0, 0, f)))
      .then(0.25f, new Trigger(() -> go.fill = color(0, 0, 0, 255)))
      .with(new Trigger(() -> g_audio.playCue(6)))
      .with(new Trigger(() -> this.state.startPlay()))
      .with(new Trigger(() -> this.characterAnimation.begin(this)))
      .then(0.25f, new Animation(255, 0, 0.5f, (f) -> go.fill = color(0, 0, 0, f)));

    sb.begin(this);
  }

  void updateObject(float deltaTime) {
    if (wasPaused) {
      // if we were paused, replay the intro
      playIntro();
    }

    // update the game state
    this.state.update(deltaTime);

    // reposition the timer
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

    // update the characters from the word state
    for (int i = 0; i < state.word.length(); i++) {
      characters[i].character = state.wordState[i];
    }

    // update the used character view
    for (int i = 0; i < state.usedCharacters.size(); i++) {
      if (state.word.indexOf(state.usedCharacters.get(i)) == -1) {
        var text = this.usedCharacters[i];
        text.setActive(true);
        text.setText("" + state.usedCharacters.get(i));
      }
    }

    // if the player has won
    if (this.state.state == GameState.WON) {
      this.state.state = GameState.ENDED; // end the game

      // show the results screen
      characterAnimation.stop();
      resultsScreen.setActive(true);
      resultsScreen.showWin();
    }

    // if the player has lost
    if (this.state.state == GameState.LOST) {
      this.state.state = GameState.ENDED; // end the game

      // show the results screen
      characterAnimation.stop();
      resultsScreen.setActive(true);
      resultsScreen.showLose();
    }
  }

  boolean onKeyPressed() {
    if (keyCode == ESC && this.state.state == GameState.PLAYING) {
      g_mainScene.togglePause();
      this.state.state = GameState.INTRO;
    }
    
    this.state.keyPressed(key);
    return false;
  }

  // creates and lays out the characters of the word in play
  void createCharacters() {
    characters = new HangmanCharacter[state.word.length()];

    PFont font = g_consolas56;

    textFont(font);
    int characterCount = state.word.length();

    // the character width
    float charWidth = getWidth(g_consolas56);
    // space between each character, calculated as the total remaining space divided by the number of characters, maximum 16px
    float charSpacing = min((MAX_WORD_WIDTH - ((charWidth) * characterCount)) / characterCount, 16);

    // y coordinate to start at
    float startY = (height / 2) - textAscent();
    // x coordinate to start at
    float startX = 540 + (MAX_WORD_WIDTH - ((charWidth + charSpacing) * characterCount)) / 2;

    characterAnimation = new Storyboard();
    for (int i = 0; i < state.word.length(); i++) {
      // create a new character at the start position, plus the character spacing * the current character position
      var character = new HangmanCharacter(startX + ((charWidth + charSpacing) * i), startY, state.wordState[i], font);
      // this causes characters to extend below their visual bounds, which creates for a nice effect on the results screen
      character.setOrigin(0.5f, 1.5f);

      this.children.add(characters[i] = character);

      // animate the letters moving up and down
      characterAnimation.add((i % 2) / 2.0f, new Animation(0, 10, 1f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> character.y = startY + f));
    }
  }

  // creates and randomly positions characters that aren't in play
  void createUsedLetters() {
    usedCharacters = new Text[26];
    for (int i = 0; i < usedCharacters.length; i++) {
      var flag = false;
      var text = new Text(0, 0, "", g_consolas32);

      // this places each character at random until it intersects with the bounds of no others
      // makes uses of java's Rectangle2D class from: https://docs.oracle.com/javase/7/docs/api/java/awt/Rectangle.html
      do {

        // set a random x,y position
        text.x = random(720, 1120);
        text.y = random(400, 620);
        text.h = 32;

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

    for (int i = 0; i < usedCharacters.length; i++) {
      var character = usedCharacters[i];
      characterAnimation.add(i * 0.05f, new Animation(random(-30, -15), random(15, 30), 1f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> character.rot = f));
    }
  }

  // cleans up after the scene
  void cleanup() {
    for (int i = 0; i < this.children.size(); i++) {
      GameObject child = this.children.get(i);
      // if the child is an animation, stop it
      if (child instanceof AnimationBase) {
        ((AnimationBase)child).stop();
      }
    }

    resultsScreen.cleanup();
  }
}
