
long g_LastFrame = 0;

void setup() {
  size(1280, 720);
  pixelDensity(displayDensity());

  g_audio = new Audio(this);
  //g_audio.playBgm(0);

  // load and measure the font Consolas at size 64pt.
  g_consolas32 = loadFont("font/Consolas-32.vlw");

  g_consolas48 = loadFont("font/Consolas-48.vlw");
  textFont(g_consolas48);
  g_consolas48CharWidth = textWidth('W');

  g_consolas56 = loadFont("font/Consolas-56.vlw");
  textFont(g_consolas56);
  g_consolas56CharWidth = textWidth('W');

  g_consolas64 = loadFont("font/Consolas-64.vlw");
  textFont(g_consolas64);
  g_consolas64CharWidth = textWidth('W');

  g_consolas96 = loadFont("font/Consolas-96.vlw");
  textFont(g_consolas96);
  g_consolas96CharWidth = textWidth('W');

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
  float dt = ((float)(System.nanoTime() - g_LastFrame) / NS_TO_SEC);
  g_LastFrame = System.nanoTime();

  g_audio.update(dt);
  g_mainScene.update(dt);

  background(255, 255, 255);

  g_mainScene.draw();

  if (DRAW_AUDIO_DEBUG) {
    g_audio.draw();
  }
}

void keyPressed() {
  g_mainScene.keyPressed();
  if (keyCode == ESC) {
    key = 0; // hack to stop it closing the game
  }
}
