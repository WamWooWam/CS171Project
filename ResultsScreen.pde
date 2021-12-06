
class ResultsScreen extends GameObject {

  private GameScene gameScene;
  private GameSceneData gameState;
  Rectangle overlayRect;

  Text timeBonusLabel;
  Text mistakeBonusLabel;
  Text totalScoreLabel;

  Text highScoreLabel;

  Text timeBonus;
  Text mistakeBonus;
  Text totalScore;

  int timeBonusValue = 0;
  int mistakeBonusValue = 0;
  int totalScoreValue = 0;

  Text youLose;
  Storyboard animation;
  boolean animationStarted;
  boolean animationComplete;
  boolean scoreTallying = false;

  float endOfAnim;
  float endOfTally;

  ResultsScreen(GameScene gameScene, GameSceneData gameState) {
    super(0, 0, width, height);

    this.gameScene = gameScene;
    this.gameState = gameState;

    this.overlayRect = new Rectangle(0, 0, width, height);
    this.overlayRect.strokeThickness = 0;
    this.overlayRect.stroke = color(0, 0, 0, 1);
    this.overlayRect.fill = color(0, 0, 0, 1);
    this.children.add(overlayRect);

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

    this.youLose = new Text(400, -200, "GAME OVER", g_consolas96, color(0, 0, 0, 1));
    alignHorizontalCentre(this.youLose, width);

    this.children.add(youLose);
  }

  void updateObject(float deltaTime) {
    timeBonus.setText("" + timeBonusValue);
    mistakeBonus.setText("" + mistakeBonusValue);
    totalScore.setText("" + totalScoreValue);

    this.timeBonus.x = width - this.timeBonus.w - 396;
    this.mistakeBonus.x = width - this.mistakeBonus.w - 396;
    this.totalScore.x = width - this.totalScore.w - 396;
  }

  void keyPressed() {
    if (scoreTallying) {
      this.animation.seek(endOfTally - 0.1f);
      this.animationComplete = true;
      this.scoreTallying = false;
    } else if (animationComplete) {
      this.exit();
    }
  }

  void exit() {
    this.animation.stop();
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
    timeBonusValue = (int)Math.ceil(gameState.remainingTime) * 100;
    mistakeBonusValue = (int)(MAX_MISTAKES - gameState.mistakes) * 1000;
    return timeBonusValue + mistakeBonusValue;
  }

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
        .add((i * spacing) + 0.5f, new Animation(character.y - 300, 250, 0.5f, EASE_OUT_CUBIC, (f) -> character.y = f));

      moveCharacters.add(i * spacing, new Animation(1, 1.25, 1f, EASE_IN_OUT_CUBIC, (f) -> character.scale = f));
    }

    return moveCharacters;
  }

  Storyboard createCharacterLoseMoveStoryboard() {
    var moveCharacters = new Storyboard();
    var startX = (width - (gameState.word.length() * 48)) / 2;
    var spacing = 1.4f / gameState.word.length();

    // move the characters to the results screen
    for (int i = 0; i < gameState.word.length(); i++) {
      var character = gameScene.characters[i];
      moveCharacters.add((i * spacing), new Animation(character.x, startX + (i * 48), 1f, EASE_IN_OUT_CUBIC, (f) -> character.x = f));
      moveCharacters.add((i * spacing), new Animation(character.y, (height / 2) + 50, 1f, EASE_IN_OUT_CUBIC, (f) -> character.y = f));
      moveCharacters.add((i * spacing), new Animation(1, 1.25, 1f, EASE_IN_OUT_CUBIC, (f) -> character.scale = f));
    }

    return moveCharacters;
  }

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

  Storyboard createScoreShowStoryboard() {
    var scoreStoryboard = new Storyboard();

    // animate the label and text up while fading in
    scoreStoryboard.add(0.5f, new Animation(timeBonusLabel.y + 16, timeBonusLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> timeBonusLabel.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> timeBonusLabel.fill = color(0, 0, 0, f)))
      .with(new Animation(timeBonus.y + 16, timeBonus.y, 0.34f, EASE_OUT_CUBIC, (f) -> timeBonus.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> timeBonus.fill = color(0, 0, 0, f)))
      .then(new Animation(mistakeBonusLabel.y + 16, mistakeBonusLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> mistakeBonusLabel.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> mistakeBonusLabel.fill = color(0, 0, 0, f)))
      .with(new Animation(mistakeBonus.y + 16, mistakeBonus.y, 0.33, EASE_OUT_CUBIC, (f) -> mistakeBonus.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> mistakeBonus.fill = color(0, 0, 0, f)))
      .then(new Animation(totalScoreLabel.y + 16, totalScoreLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> totalScoreLabel.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> totalScoreLabel.fill = color(0, 0, 0, f)))
      .with(new Animation(totalScore.y + 16, totalScore.y, 0.33, EASE_OUT_CUBIC, (f) -> totalScore.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> totalScore.fill = color(0, 0, 0, f)));

    return scoreStoryboard;
  }

  Storyboard createScoreTallyStoryboard() {
    var totalTime = max(timeBonusValue / 10000.0f, mistakeBonusValue / 10000.0f);

    var scoreTallyStoryboard = new Storyboard()
      .add(0.0f, new Animation(timeBonusValue, 0, timeBonusValue / 10000.0f, LINEAR, (f) -> timeBonusValue = f.intValue()))
      .add(0.0f, new Animation(mistakeBonusValue, 0, mistakeBonusValue / 10000.0f, LINEAR, (f) -> mistakeBonusValue = f.intValue()))
      .add(0.0f, new Animation(0, timeBonusValue + mistakeBonusValue, totalTime, LINEAR, (f) -> totalScoreValue = f.intValue()))
      .add(0.0f, new Interval(0.033f, totalTime, () ->  g_audio.playCue(2)))
      .then(0.05f, new Trigger(() -> g_audio.playCue(3)));

    return scoreTallyStoryboard;
  }

  Storyboard createHighScoreStoryboard() {
    var sb = new Storyboard()
      .add(0.0f, new Animation(highScoreLabel.y + 16, highScoreLabel.y, 0.33, EASE_OUT_CUBIC, (f) -> highScoreLabel.y = f))
      .with(new Animation(1, 255, 0.33, LINEAR, (f) -> highScoreLabel.fill = color(0, 0, 0, f)))
      .with(new Trigger(() -> g_audio.playCue(8)));
    return sb;
  }

  Storyboard createWordRevealAnimation() {
    var sb = new Storyboard();

    int x = 0;
    for (int i = 0; i < gameState.word.length(); i++) {
      var character = gameScene.characters[i];
      var letter = gameState.wordCharacters[i];
      if (gameState.wordState[i] != 0) continue;

      var idx = i;
      sb.add(x * 0.33f, new Animation((height / 2) + 50, (height / 2), 0.33f, EASE_IN_CIRCLE, (f) -> character.y = f))
        .then(new Animation((height / 2), (height / 2) + 50, 0.33f, EASE_OUT_CIRCLE, (f) -> character.y = f))
        .with(new Trigger(() -> g_audio.playCue(7)))
        .with(new Trigger(() -> gameState.wordState[idx] = letter));

      x++;
    }

    return sb;
  }

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
    for (HangmanCharacter character : gameScene.characters) {
      gameScene.children.remove(character);
      this.children.add(character);
    }

    var totalScore = this.calculateScore();
    var highScore = g_saveData.getHighScore(this.gameState.difficulty);
    if (totalScore > highScore) {
      g_saveData.setHighScore(this.gameState.difficulty, totalScore);
    }

    animation = new Storyboard();

    // fade the background to white
    animation.add(0.0f, new Animation(1, 255, 1f, LINEAR, (f) -> overlayRect.fill = color(255, 255, 255, f)));

    // mute music
    animation.add(0.0f, new Animation(1, 0, 0.3f, LINEAR, (f) -> g_audio.setVolume(f)));
    // play the jingle
    animation.after(new Trigger(() -> g_audio.playBgm(0, 0.0f)))
      .then(new Trigger(() -> this.animationStarted = true));

    // move characters into place
    animation.add(0.0f, this.createCharacterWinMoveStoryboard());

    // then scale them
    animation.then(this.createCharacterScaleStoryboard());

    // store the time after this is done
    endOfAnim = animation.getDuration();

    // show and run the score tally
    animation.then(this.createScoreShowStoryboard());
    animation.then(0.5f, this.createScoreTallyStoryboard())
      .with(new Trigger(() -> this.scoreTallying = true))
      .then(new Trigger(() -> this.animationComplete = true));

    endOfTally = animation.getDuration();

    if (totalScore > highScore) {
      animation.then(1f, this.createHighScoreStoryboard());
    }

    animation.then(5.0f, new Trigger(() -> this.exit()));

    // 0.5s after the scale, run an infinite sine loop
    animation.add(endOfAnim + 0.5f, this.createCharacterSineAnimation());
    animation.begin(this);
  }

  void showLose() {
    for (HangmanCharacter character : gameScene.characters) {
      gameScene.children.remove(character);
      this.children.add(character);
    }

    animation = new Storyboard();

    // fade the background to white
    animation.add(0.0f, new Animation(1, 255, 1f, LINEAR, (f) -> overlayRect.fill = color(255, 255, 255, f)));

    // mute music
    animation.add(0.0f, new Animation(1, 0, 0.3f, LINEAR, (f) -> g_audio.setVolume(f)));
    // play the jingle
    animation.after(new Trigger(() -> g_audio.playBgm(1, 0.0f)));

    // move characters into place
    animation.add(0.0f, this.createCharacterLoseMoveStoryboard());
    animation.add(0.0f, new Storyboard()
      .add(0.0f, new Animation(-200, 125, 2.0f, EASE_OUT_BOUNCE, (f) -> youLose.y = f))
      .add(0.0f, new Animation(1, 255, 0.25f, LINEAR, (f) -> youLose.fill = color(0, 0, 0, f))));

    animation.then(this.createWordRevealAnimation());
    animation.then(0.5f, this.createCharacterSineAnimation())
      .with(new Trigger(() -> this.animationComplete = true));

    animation.then(5.0f, new Trigger(() -> this.exit()));

    animation.begin(this);
  }
}
