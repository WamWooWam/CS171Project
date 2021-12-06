// this file contains global variables for the game, as well as some helpful functions used within it
static final float NS_TO_SEC = 1000000000.0f;
static final int MAX_MISTAKES = 10;
static final String ALLOWED_CHARS = "abcdefghijklmnopqrstuvwxyz";

// debugging flags
static final boolean DRAW_OBJECT_BOUNDS = false;
static final boolean DRAW_AUDIO_DEBUG = false;
static final boolean DRAW_FRAME_RATE = true;

MainScene g_mainScene;

Audio g_audio;

WordList g_easyWords;
WordList g_normalWords;
WordList g_hardWords;

// as consolas is a monospaced font, we can assume the same width for all characters.

PFont g_consolas32;
PFont g_consolas48;
float g_consolas48CharWidth;
PFont g_consolas56;
float g_consolas56CharWidth;
PFont g_consolas64;
float g_consolas64CharWidth;
PFont g_consolas96;
float g_consolas96CharWidth;

// java enums are stupid
// based on: https://stackoverflow.com/questions/8157755/how-to-convert-enum-value-to-int
enum Difficulty {
  EASY(0), NORMAL(1), HARD(2), CUSTOM(3);

  private final int value;
  private Difficulty(int value) {
    this.value = value;
  }

  public int getValue() {
    return value;
  }
}

Difficulty getDifficulty(int i) {
  // this is slow, but should be called at most once per game
  // source: https://stackoverflow.com/questions/5878952/cast-int-to-enum-in-java
  return Difficulty.values()[i];
}

SaveData g_saveData;
