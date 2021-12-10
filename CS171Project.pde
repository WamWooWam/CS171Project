
void setup() {
  // we're playing at 720p  
  size(1280, 720);
  // enable support for high pixel densities
  pixelDensity(displayDensity());
  // uncap the framerate
  frameRate(-1);

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
  g_consolas24CharWidth = measureFont(g_consolas24);
  g_consolas32 = createFont("font/consola.ttf", 32, true);
  g_consolas32CharWidth = measureFont(g_consolas32);
  g_consolas48 = createFont("font/consola.ttf", 48, true);
  g_consolas48CharWidth = measureFont(g_consolas48);
  g_consolas56 = createFont("font/consola.ttf", 56, true);
  g_consolas56CharWidth = measureFont(g_consolas56);
  g_consolas64 = createFont("font/consola.ttf", 64, true);
  g_consolas64CharWidth = measureFont(g_consolas64);
  g_consolas96 = createFont("font/consola.ttf", 96, true);
  g_consolas96CharWidth = measureFont(g_consolas96);  

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

String formatMs(double ms) {
  return nf((float)ms * 1000, 0, 2) + "ms";
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
  background(255, 255, 255);
  
  // draw the main scene
  g_mainScene.draw();

  // if the debugger is active
  if (DEBUGGER) {
    // keep track of the minimum and maximum frame delta
    g_minFrameTime = Math.min(dt, g_minFrameTime);
    g_maxFrameTime = Math.max(dt, g_maxFrameTime);
    
    // and an average of the last 60
    g_lastFrameTimes[frameCount % 60] = dt;
    g_lastFrameRates[frameCount % 60] = frameRate;
  
    // reset the clip as we've no guarantee of its state now objects have been drawn  
    noClip();
    fill(0, 0, 0);
    textFont(g_consolas24);

    if (DEBUG_FRAME_RATE) {
      double avgFrameTime = 0;
      for (int i = 0; i < 60; i++) {
        avgFrameTime += g_lastFrameTimes[i];
      }
      avgFrameTime /= min(frameCount, 60);

      double avgFrameRate = 0;
      for (int i = 0; i < 60; i++) {
        avgFrameRate += g_lastFrameRates[i];
      }
      avgFrameRate /= min(frameCount, 60);

      // print the current and average FPS
      text(((nf(frameRate, 0, 2) + "FPS, ") + (nf((float)avgFrameRate, 0, 2) + "FPS")), 16, 24);
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
  g_mainScene.keyPressed();

  if (keyCode == ESC) {
    key = 0; // hack to stop escape closing the game
  }

  if (keyCode == CONTROL) {
    g_ctrlPressed = true;
  }

  // ctrl-D
  if (g_ctrlPressed && keyCode == 68) {
    DEBUGGER = !DEBUGGER;
  }

  // ctrl-B
  if (g_ctrlPressed && keyCode == 66) {
    DEBUG_OBJECT_BOUNDS = !DEBUG_OBJECT_BOUNDS;
  }
}

void keyReleased() {
  if (keyCode == CONTROL) {
    g_ctrlPressed = false;
  }
}
