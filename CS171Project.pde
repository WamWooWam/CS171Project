
long g_LastFrame = 0;

float measureFont(PFont font) {
  textFont(font);
  return textWidth('W');
}

void setup() {
  size(1280, 720);
  pixelDensity(displayDensity());

  g_audio = new Audio(this);
  //g_audio.playBgm(0);

  // load and measure the font Consolas at bunch of sizes.
  g_consolas24 = createFont("consola.ttf", 24, true);
  g_consolas24CharWidth = measureFont(g_consolas24);
  g_consolas32 = createFont("consola.ttf", 32, true);
  g_consolas32CharWidth = measureFont(g_consolas32);
  g_consolas48 = createFont("consola.ttf", 48, true);
  g_consolas48CharWidth = measureFont(g_consolas48);
  g_consolas56 = createFont("consola.ttf", 56, true);
  g_consolas56CharWidth = measureFont(g_consolas56);
  g_consolas64 = createFont("consola.ttf", 64, true);
  g_consolas64CharWidth = measureFont(g_consolas64);
  g_consolas96 = createFont("consola.ttf", 96, true);
  g_consolas96CharWidth = measureFont(g_consolas96);

  g_easyWords = new WordList("easy");
  g_normalWords = new WordList("normal");
  g_hardWords = new WordList("hard");

  g_mainScene = new MainScene();
  g_mainScene.goToScene(new TitleScene());
  g_LastFrame = System.nanoTime();

  g_saveData = new SaveData();

  frameRate(-1);
}


void draw() {
  g_objectDrawCount = 0;
  g_objectUpdateCount = 0;
  g_activeAnimations = 0;

  float dt = ((float)(System.nanoTime() - g_LastFrame) / NS_TO_SEC);
  g_LastFrame = System.nanoTime();

  g_audio.update(dt);
  g_mainScene.update(dt);

  background(255, 255, 255);

  g_mainScene.draw();

  noClip();
  fill(0, 0, 0);
  textFont(g_consolas24);

  if (DEBUG_FRAME_RATE) {
    text(nf(frameRate, 0, 2) + "FPS", 16, 24);
    text(nf(dt * 1000, 0, 2) + "ms", 16, 48);
  }

  if (DEBUG_OBJECT_COUNT) {
    text("object_draw: " + g_objectDrawCount, 16, 72);
    text("object_update: " + g_objectUpdateCount, 16, 96);
  }

  if (DEBUG_ANIMATION) {
    text("active_animations: " + g_activeAnimations, 16, 120);
    text("attached_animations: " + g_attachedAnimations, 16, 144);
  }

  if (DEBUG_AUDIO) {
    g_audio.draw(144);
  }
}

void keyPressed() {
  g_mainScene.keyPressed();
  if (keyCode == ESC) {
    key = 0; // hack to stop it closing the game
  }
}
