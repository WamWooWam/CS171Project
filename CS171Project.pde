import processing.javafx.*;


void setup() {
  // we're playing at 720p
  size(1280, 720, P2D);
  // enable support for high pixel densities
  pixelDensity(displayDensity());
  // uncap the framerate
  frameRate(1000);
  
  smooth(8);

  // set the window title to the game title.
  surface.setTitle("H_ngm_n!");

  // load a basic bitmap version of Consolas to be overwritten with
  // a vector version later for speed
  g_consolas24 = loadFont("font/Consolas-24.vlw");

  // initialise our main scene
  g_mainScene = new MainScene();
  g_lastFrame = System.nanoTime();

  // push the rest of loading off to another thread for performance reasons
  thread("init");
}

// this funciton does the bulk of the loading work off the main thread using processing's
// "thread" function. doing so means the main thread can draw a loading screen while the game
// is loading, so it doesn't appear hung for that time.
void init() {
  // load and measure the font Consolas at bunch of sizes.
  g_consolas24 = createFont("font/consola.ttf", 24, true);
  g_consolas32 = createFont("font/consola.ttf", 32, true);
  g_consolas48 = createFont("font/consola.ttf", 48, true);
  g_consolas56 = createFont("font/consola.ttf", 56, true);
  g_consolas64 = createFont("font/consola.ttf", 64, true);
  g_consolas96 = createFont("font/consola.ttf", 96, true);

  // initialise our audio instance, this loads sound files so can be quite slow
  g_audio = new Audio(this);

  // load our word lists
  g_easyWords = new WordList("easy");
  g_normalWords = new WordList("normal");
  g_hardWords = new WordList("hard");

  // load and init save data
  g_saveData = new SaveData();

  // everything's loaded, switch to the title scene
  g_mainScene.lateInit();
  g_mainScene.goToScene(new TitleScene());
}

void draw() {
  // reset all the debug counters to zero
  g_objectDrawCount = 0;
  g_objectUpdateCount = 0;
  g_activeAnimations = 0;

  // calculate this frame's delta time
  double dt = ((double)(System.nanoTime() - g_lastFrame) / NS_TO_SEC);
  g_lastFrame = System.nanoTime();

  // update our audio instance if it's ready
  if (g_audio != null)
    g_audio.update((float)dt);

  // update the main scene
  g_mainScene.update((float)dt);

  // clear the background
  noClip();
  background(255, 255, 255);

  // draw the main scene
  g_mainScene.draw();

  // keep track of the minimum and maximum frame delta
  g_minFrameTime = Math.min(dt, g_minFrameTime);
  g_maxFrameTime = Math.max(dt, g_maxFrameTime);

  // and an average of the last 60
  g_lastFrameTimes[frameCount % g_lastFrameTimes.length] = (float)dt;
  g_lastFrameRates[frameCount % g_lastFrameRates.length] = frameRate;

  // if the debugger is active
  if (DEBUGGER) {

    // reset the clip and other properties as we've no guarantee of their state now objects have been drawn
    noClip();
    fill(0, 0, 0);
    stroke(0, 0, 0);
    strokeWeight(1);
    textFont(g_consolas24);

    if (DEBUG_FRAME_RATE) {
      float avgFrameTime = 0;
      for (int i = 1; i < g_lastFrameTimes.length; i++) {
        avgFrameTime += g_lastFrameTimes[i];

        if (g_lastFrameTimes[i] > 20)
          stroke(255, 0, 0);
        else
          stroke(0, 0, 0);

        line(i * 4, height - (g_lastFrameTimes[i - 1] * 1000), 4 + (i * 4), height - (g_lastFrameTimes[i] * 1000));
      }
      avgFrameTime /= min(frameCount, g_lastFrameRates.length - 1);

      float avgFrameRate = 0;
      for (int i = 1; i < g_lastFrameRates.length; i++) {
        avgFrameRate += g_lastFrameRates[i];
      }

      avgFrameRate /= min(frameCount, g_lastFrameRates.length - 1);

      // print the current and average FPS
      text(((nf(frameRate, 0, 2) + "FPS, ") + (nf(avgFrameRate, 0, 2) + "FPS")), 16, 24);
      // frame time current,min,max,avg
      text(formatMs(dt) + ", " + formatMs(g_minFrameTime) + ", " + formatMs(g_maxFrameTime) + ", " + formatMs(avgFrameTime), 16, 48);
    }

    // draw the object counters
    if (DEBUG_OBJECT_COUNT) {
      text("object_draw: " + g_objectDrawCount, 16, 72);
      text("object_update: " + g_objectUpdateCount, 16, 96);
    }

    // draw the animation counters
    if (DEBUG_ANIMATION) {
      text("active_animations: " + g_activeAnimations, 16, 120);
      text("attached_animations: " + g_attachedAnimations, 16, 144);
    }

    // draw the audio debugger
    if (DEBUG_AUDIO && g_audio != null) {
      g_audio.draw(144);
    }
  }
}

void keyPressed() {

  // F3
  if (keyCode == 114 || keyCode == 99) {
    DEBUGGER = !DEBUGGER;
    return;
  }

  // F4
  if (keyCode == 115 || keyCode == 100) {
    DEBUG_OBJECT_BOUNDS = !DEBUG_OBJECT_BOUNDS;
    return;
  }

  if (keyCode == ESC) {
    key = 0; // hack to stop escape closing the game
  }

  g_mainScene.keyPressed();
}

void mouseMoved() {
  g_mainScene.mouseMoved();
}

void mouseDragged() {
  g_mainScene.mouseMoved();
}

void mousePressed() {
  g_mainScene.mousePressed();
}

void mouseReleased() {
  g_mainScene.mouseReleased();
}
