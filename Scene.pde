
// this is the base class for the game's "scenes". scenes encapsulate the overall
// game state
abstract class Scene extends GameObject {
  public Scene() {
    super(0, 0, width, height);
  }
}

// this scene acts as a container scene for other scenes, enabling the transition between them
class MainScene extends Scene {

  private Scene currentScene;
  private Scene nextScene;
  private boolean isTransitioning;

  void updateObject(float deltaTime) {
    if (nextScene != null) {
      nextScene.update(deltaTime);
    }

    currentScene.update(deltaTime);
  }

  void drawObject() {
    if (nextScene != null) {
      nextScene.draw();
    }

    currentScene.draw();

    if (DRAW_FRAME_RATE) {
      noClip();
      fill(0, 0, 0);
      textFont(g_consolas32);
      text(Float.toString(round(frameRate)) + "FPS", 16, 32);
    }
  }
  
  void goToScene(Scene scene) {
    nextScene = scene;
    if (currentScene != null) {
      if (isTransitioning) return;

      isTransitioning = true;
      Storyboard transitionStoryboard = new Storyboard();
      transitionStoryboard.add(0.0f, new Trigger(() -> nextScene.scale = 0.33f));
      transitionStoryboard.add(0.0f, new Animation(0, height, 0.5f, EASE_OUT_CUBIC, (f) -> currentScene.y = f));
      transitionStoryboard.add(0.0f, new Animation(0.33f, 1f, 1f, EASE_OUT_CUBIC, (f) -> nextScene.scale = f));
      transitionStoryboard.add(1.0f, new Trigger(() -> this.cleanupScenes()));
      transitionStoryboard.begin(this);
    } else {
      currentScene = scene;
      nextScene = null;
    }
  }

  void keyPressed() {
    // we only want to update the active scene
    if (!isTransitioning && currentScene != null) {
      currentScene.keyPressed();
    }
  }

  void cleanupScenes() {
    isTransitioning = false;
    currentScene = nextScene;
    currentScene.scale = 1;
    nextScene = null;
  }
}
