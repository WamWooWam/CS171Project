
//
// this class handles the screen after the player either wins or loses. if the player wins,
// they get a cheery animation in which the characters fly over the screen, congratulating them
// on their victory. otherwise, they get an animation that shows the character they were missing
// all before being sent back to the title screen to start the game again.
//

class ResultsScreen extends GameObject {

  private GameScene gameScene;
  private GameSceneData gameState;
  private Rectangle overlayRect;

  // labels for the countdown
  private Text timeBonusLabel;
  private Text mistakeBonusLabel;
  private Text totalScoreLabel;

  // countdown values
  private Text timeBonus;
  private Text mistakeBonus;
  private Text totalScore;

  private int timeBonusValue = 0;
  private int mistakeBonusValue = 0;
  private int totalScoreValue = 0;

  // "new high score" text
  private Text highScoreLabel;

  // "game over" text
  private Text youLose;

  private Storyboard mainAnim;

  // these flags are used to help when skipping the animations
  private boolean animationComplete;
  private boolean scoreTallying = false;
  private float endOfAnim;
  private float endOfTally;

  ResultsScreen(GameScene gameScene, GameSceneData gameState) {
    super(0, 0, width, height);

    this.gameScene = gameScene;
    this.gameState = gameState;

    // an overlay to hide the game behind the screen
    this.overlayRect = new Rectangle(0, 0, width, height);
    this.overlayRect.strokeThickness = 0;
    this.overlayRect.stroke = color(0, 0, 0, 1);
    this.overlayRect.fill = color(0, 0, 0, 1);
    this.children.add(overlayRect);

    // the background particle field
    this.children.add(new Background(0));

    // create and align the labels for bonuses and total score
    this.timeBonusLabel = new Text(400, 320, "TIME BONUS:", g_consolas48, color(0, 0, 0, 1));
    this.timeBonusLabel.x = ((width - (this.timeBonusLabel.w * 2)) / 2) + 48;
    this.mistakeBonusLabel = new Text(400, 368, "MISTAKE BONUS:", g_consolas48, color(0, 0, 0, 1));
    this.mistakeBonusLabel.x = ((width - (this.mistakeBonusLabel.w * 2)) / 2) + 48;
    this.totalScoreLabel = new Text(400, 452, "SCORE:", g_consolas48, color(0, 0, 0, 1));
    this.totalScoreLabel.x = ((width - (this.totalScoreLabel.w * 2)) / 2) + 48;

    this.highScoreLabel = new Text(400, 540, "NEW HIGH SCORE!", g_consolas48, color(0, 0, 0, 1));
    alignHorizontalCentre(this.highScoreLabel, width);

    this.children.add(timeBonusLabel);
    this.children.add(mistakeBonusLabel);
    this.children.add(totalScoreLabel);
    this.children.add(highScoreLabel);

    this.timeBonus = new Text(400, 320, "0", g_consolas48, color(0, 0, 0, 1));
    this.timeBonus.x = width - this.timeBonus.w - 396;
    this.mistakeBonus = new Text(400, 368, "0", g_consolas48, color(0, 0, 0, 1));
    this.mistakeBonus.x = width - this.mistakeBonus.w - 396;
    this.totalScore = new Text(400, 452, "0", g_consolas48, color(0, 0, 0, 1));
    this.totalScore.x = width - this.totalScore.w - 396;

    this.children.add(timeBonus);
    this.children.add(mistakeBonus);
    this.children.add(totalScore);

    // create and align the "game over" text
    this.youLose = new Text(400, -200, "GAME OVER", g_consolas96, color(0, 0, 0, 1));
    alignHorizontalCentre(this.youLose, width);

    this.children.add(youLose);
  }

  void updateObject(float deltaTime) {
    // ensure the bonus tallys are accurate and positioned correctly
    timeBonus.setText("" + timeBonusValue);
    mistakeBonus.setText("" + mistakeBonusValue);
    totalScore.setText("" + totalScoreValue);

    this.timeBonus.x = width - this.timeBonus.w - 396;
    this.mistakeBonus.x = width - this.mistakeBonus.w - 396;
    this.totalScore.x = width - this.totalScore.w - 396;
  }

  boolean onKeyPressed() {
    if (scoreTallying) {
      // skip if the player presses a key
      this.mainAnim.seek(endOfTally - 0.1f);
      this.animationComplete = true;
      this.scoreTallying = false;
    } else if (animationComplete) {
      this.exit();
    }

    return false;
  }

  void exit() {
    // cleanup and return to the title screen
    this.mainAnim.stop();
    var scene = new TitleScene();
    scene.forceOpen();
    g_mainScene.goToScene(scene);
  }

  void cleanup() {
    for (int i = 0; i < this.children.size(); i++) {
      GameObject child = this.children.get(i);
      if (child instanceof AnimationBase) {
        ((AnimationBase)child).stop();
      }
    }
  }

  int calculateScore() {
    // calculates the players time/mistake bonus, and returns the total score
    timeBonusValue = (int)Math.ceil(gameState.remainingTime) * 100;
    mistakeBonusValue = (int)(MAX_MISTAKES - gameState.mistakes) * 1000;
    return timeBonusValue + mistakeBonusValue;
  }

  float winCharacterTargetHeight() {
    return 200;
  }

  float loseCharacterTargetHeight() {
    return (height / 2) + 50;
  }

  // returns a storyboard that moves the individual hangman characters to their proper position
  // in a win condition
  Storyboard createCharacterWinMoveStoryboard() {
    var moveCharacters = new Storyboard();
    var startX = (width - (gameState.word.length() * 48)) / 2;
    var spacing = 1.4f / gameState.word.length();

    // move the characters to the results screen
    for (int i = 0; i < gameState.word.length(); i++) {
      var character = gameScene.characters[i];
      moveCharacters.add((i * spacing) + 0.33f, new Animation(character.x, startX + (i * 48), 0.66f, EASE_IN_OUT_CUBIC, (f) -> character.x = f));

      // this could look better with keyframe animations, but i'm not yet smart enough for that
      moveCharacters.add(i * spacing, new Animation(character.y, character.y - 300, 0.5f, EASE_IN_CUBIC, (f) -> character.y = f))
        .add((i * spacing) + 0.5f, new Animation(character.y - 300, winCharacterTargetHeight(), 0.5f, EASE_OUT_CUBIC, (f) -> character.y = f));

      moveCharacters.add(i * spacing, new Animation(1, 1.25, 1f, EASE_IN_OUT_CUBIC, (f) -> character.scale = f));
    }

    return moveCharacters;
  }

  // returns a storyboard that moves the individual hangman characters to their proper position
  // in a lose condition
  Storyboard createCharacterLoseMoveStoryboard() {
    var moveCharacters = new Storyboard();

    var startX = (width - (gameState.word.length() * 48)) / 2;
    var spacing = 1.4f / gameState.word.length();
    var targetY = loseCharacterTargetHeight();

    // move the characters to the results screen
    for (int i = 0; i < gameState.word.length(); i++) {
      var character = gameScene.characters[i];
      moveCharacters.add((i * spacing), new Animation(character.x, startX + (i * 48), 1f, EASE_IN_OUT_CUBIC, (f) -> character.x = f));
      moveCharacters.add((i * spacing), new Animation(character.y, targetY, 1f, EASE_IN_OUT_CUBIC, (f) -> character.y = f));
      moveCharacters.add((i * spacing), new Animation(1, 1.25, 1f, EASE_IN_OUT_CUBIC, (f) -> character.scale = f));
    }

    return moveCharacters;
  }

  // returns a storyboard that animates the character's scale and rotation to create a fanfare
  Storyboard createCharacterScaleStoryboard() {
    var scaleCharacters = new Storyboard();
    for (int i = 0; i < gameState.word.length(); i++) {
      var character = gameScene.characters[i];

      scaleCharacters.add(0, new Animation(1.25, 2, 0.5f, EASE_IN_OUT_CUBIC, (f) -> character.scale = f))
        .add(0.6f, new Animation(2, 1.25, 0.5f, EASE_IN_OUT_CUBIC, (f) -> character.scale = f));

      scaleCharacters.add(0, new Animation(0, 10, 0.25f, EASE_IN_OUT_CUBIC, (f) -> character.rot = f))
        .add(0.25f, new Animation(10, -10, 0.5f, EASE_IN_OUT_CUBIC, (f) -> character.rot = f))
        .add(0.75f, new Animation(-10, 0, 0.25f, EASE_IN_OUT_CUBIC, (f) -> character.rot = f));
    }

    return scaleCharacters;
  }

  // returns a storyboard that shows the time/mistake/total score text
  Storyboard createScoreShowStoryboard() {
    var scoreStoryboard = new Storyboard();

    // animate the label and text up while fading in
    scoreStoryboard.add(0.5f, new Animation(timeBonusLabel.y + 16, timeBonusLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> timeBonusLabel.y = f))
      .with(new Animation(1, 255, 0.33, (f) -> timeBonusLabel.fill = color(0, 0, 0, f)))
      .with(new Animation(timeBonus.y + 16, timeBonus.y, 0.34f, EASE_OUT_CUBIC, (f) -> timeBonus.y = f))
      .with(new Animation(1, 255, 0.33, (f) -> timeBonus.fill = color(0, 0, 0, f)))
      .then(new Animation(mistakeBonusLabel.y + 16, mistakeBonusLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> mistakeBonusLabel.y = f))
      .with(new Animation(1, 255, 0.33, (f) -> mistakeBonusLabel.fill = color(0, 0, 0, f)))
      .with(new Animation(mistakeBonus.y + 16, mistakeBonus.y, 0.33, EASE_OUT_CUBIC, (f) -> mistakeBonus.y = f))
      .with(new Animation(1, 255, 0.33, (f) -> mistakeBonus.fill = color(0, 0, 0, f)))
      .then(new Animation(totalScoreLabel.y + 16, totalScoreLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> totalScoreLabel.y = f))
      .with(new Animation(1, 255, 0.33, (f) -> totalScoreLabel.fill = color(0, 0, 0, f)))
      .with(new Animation(totalScore.y + 16, totalScore.y, 0.33, EASE_OUT_CUBIC, (f) -> totalScore.y = f))
      .with(new Animation(1, 255, 0.33, (f) -> totalScore.fill = color(0, 0, 0, f)));

    return scoreStoryboard;
  }

  // returns a storyboard that performs the score tally
  Storyboard createScoreTallyStoryboard() {
    var totalTime = max(timeBonusValue / 10000.0f, mistakeBonusValue / 10000.0f);

    var scoreTallyStoryboard = new Storyboard()
      .add(0.0f, new Animation(timeBonusValue, 0, timeBonusValue / 10000.0f, (f) -> timeBonusValue = (int)f))
      .add(0.0f, new Animation(mistakeBonusValue, 0, mistakeBonusValue / 10000.0f, (f) -> mistakeBonusValue  = (int)f))
      .add(0.0f, new Animation(0, timeBonusValue + mistakeBonusValue, totalTime, (f) -> totalScoreValue = (int)f))
      .add(0.0f, new Interval(0.033f, totalTime, () ->  g_audio.playCue(2)))
      .then(0.05f, new Trigger(() -> g_audio.playCue(3)));

    return scoreTallyStoryboard;
  }

  // returns a storyboard that shows the "new high score" text
  Storyboard createHighScoreStoryboard() {
    var sb = new Storyboard()
      .add(0.0f, new Animation(highScoreLabel.y + 16, highScoreLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> highScoreLabel.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> highScoreLabel.fill = color(0, 0, 0, f)))
      .with(new Trigger(() -> g_audio.playCue(8)));
    return sb;
  }

  // returns a storyboard that drops the "you lose" text down from the top of the screen
  Storyboard createYouLoseTextAnimation() {
    return new Storyboard()
      .add(0.0f, new Animation(-200, 200, 2.0f, EASE_OUT_BOUNCE, (f) -> youLose.y = f))
      .add(0.0f, new Animation(1, 255, 0.25f, LINEAR, (f) -> youLose.fill = color(0, 0, 0, f)));
  }

  // returns a storyboard that reveals each missing letter of the word one by one
  Storyboard createWordRevealAnimation() {
    var sb = new Storyboard();
    var targetY = loseCharacterTargetHeight();

    int x = 0;
    for (int i = 0; i < gameState.word.length(); i++) {
      var character = gameScene.characters[i];
      var letter = gameState.wordCharacters[i];
      
      // if the current letter was revealed, skip it
      if (gameState.wordState[i] != 0) continue;
      var idx = i; // "must be effectively final"
      
      // bounce the character up by 50px, play a sound effect and reveal the letter, then move it down
      sb.add(x * 0.33f, new Animation(targetY, targetY - 50, 0.33f, EASE_IN_CIRCLE, (f) -> character.y = f))
        .then(new Animation(targetY - 50, targetY, 0.33f, EASE_OUT_CIRCLE, (f) -> character.y = f))
        .with(new Trigger(() -> g_audio.playCue(7)))
        .with(new Trigger(() -> gameState.wordState[idx] = letter));

      // keep track of the total letters revealed for animation timing
      x++;
    }

    return sb;
  }

  // moves the characters up and down in a wave once they've reached their final positions
  // this is a trigger because it depends on values at a point in an animation
  Trigger createCharacterSineAnimation() {
    return new Trigger(() -> {
      var animation = new Storyboard();
      for (int i = 0; i < gameState.word.length(); i++) {
        var character = gameScene.characters[i];
        animation.add(i * 0.05f, new Animation(character.y, character.y - 40, 1f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> character.y = f));
      }

      animation.begin(this);
    }
    );
  }

  void showWin() {
    // move all the characters to be children of this object, not the game scene
    for (HangmanCharacter character : gameScene.characters) {
      gameScene.children.remove(character);
      this.children.add(character);
    }
    mainAnim = new Storyboard();

    // fade the background to white
    mainAnim.add(0.0f, new Animation(1, 255, 1f, LINEAR, (f) -> overlayRect.fill = color(255, 255, 255, f)));

    // mute music
    mainAnim.add(0.0f, new Animation(1, 0, 0.3f, LINEAR, (f) -> g_audio.setVolume(f)));

    // play the jingle
    mainAnim.after(new Trigger(() -> g_audio.playBgm(0, 0.0f)));

    // move characters into place
    mainAnim.add(0.0f, this.createCharacterWinMoveStoryboard());

    // then scale them
    mainAnim.then(this.createCharacterScaleStoryboard());

    // store the time after this is done
    endOfAnim = (float)mainAnim.getDuration();

    // calculate the high score
    var totalScore = this.calculateScore();

    // show and run the score tally
    mainAnim.then(this.createScoreShowStoryboard());
    mainAnim.then(0.5f, this.createScoreTallyStoryboard())
      .with(new Trigger(() -> this.scoreTallying = true))
      .then(new Trigger(() -> this.animationComplete = true));

    endOfTally = (float)mainAnim.getDuration();

    // get the player's previous high score
    var highScore = g_saveData.getHighScore(this.gameState.difficulty);
    if (totalScore > highScore) {
      // if this is a new high score, save it, and animate in the text
      g_saveData.setHighScore(this.gameState.difficulty, totalScore);
      mainAnim.then(1f, this.createHighScoreStoryboard());
    }

    // after five seconds, leave the game
    mainAnim.then(5.0f, new Trigger(() -> this.exit()));

    // 0.5s after the scale, run an infinite sine loop
    mainAnim.add(endOfAnim + 0.5f, this.createCharacterSineAnimation());
    mainAnim.begin(this);
  }

  void showLose() {
    // move all the characters to be children of this object, not the game scene
    for (HangmanCharacter character : gameScene.characters) {
      gameScene.children.remove(character);
      this.children.add(character);
    }

    mainAnim = new Storyboard();

    // fade the background to white
    mainAnim.add(0.0f, new Animation(1, 255, 1f, LINEAR, (f) -> overlayRect.fill = color(255, 255, 255, f)));

    // mute music
    mainAnim.add(0.0f, new Animation(1, 0, 0.3f, LINEAR, (f) -> g_audio.setVolume(f)));

    // play the jingle
    mainAnim.after(new Trigger(() -> g_audio.playBgm(1, 0.0f)));

    // move characters into place
    mainAnim.add(0.0f, this.createCharacterLoseMoveStoryboard());
    mainAnim.add(0.0f, this.createYouLoseTextAnimation());

    mainAnim.then(this.createWordRevealAnimation());
    mainAnim.then(0.5f, this.createCharacterSineAnimation())
      .with(new Trigger(() -> this.animationComplete = true));

    mainAnim.then(5.0f, new Trigger(() -> this.exit()));

    mainAnim.begin(this);
  }
}
