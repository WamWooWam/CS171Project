// this file contains global variables for the game, as well as some helpful functions used within it
static final double NS_TO_SEC = 1000000000.0f;
static final int MAX_MISTAKES = 12;
static final String ALLOWED_CHARS = "abcdefghijklmnopqrstuvwxyz";
static final char[] TITLE_CHARS = { 'H', 0, 'n', 'g', 'm', 0, 'n', '!' };

// debugging flags
static boolean DEBUGGER = false;
static boolean DEBUG_OBJECT_BOUNDS = false;
static final boolean DEBUG_FRAME_RATE = true;
static final boolean DEBUG_OBJECT_COUNT = true;
static final boolean DEBUG_AUDIO = true;
static final boolean DEBUG_ANIMATION = true;
static final boolean USE_P2D = true;

// debug counters
int g_objectUpdateCount;
int g_objectDrawCount;
int g_activeAnimations;
int g_attachedAnimations;
int g_mouseEvents;

double g_minFrameTime = Double.POSITIVE_INFINITY;
double g_maxFrameTime = Double.NEGATIVE_INFINITY;
float[] g_lastFrameTimes = new float[120];
float[] g_lastFrameRates = new float[120];

// we keep track of if the ctrl key is pressed so we can enable/disable the debugger on
// ctrl+d
boolean g_ctrlPressed;

// last frame timestamp for dt calculation
long g_lastFrame;

// the main scene
MainScene g_mainScene;

// the audio engine
Audio g_audio;

// current save data
SaveData g_saveData;

// word lists
WordList g_easyWords;
WordList g_normalWords;
WordList g_hardWords;

// as consolas is a monospaced font, we can assume the same width for all characters.
PFont g_consolas24;
PFont g_consolas32;
PFont g_consolas48;
PFont g_consolas56;
PFont g_consolas64;
PFont g_consolas96;

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

// helper function to align an object to the centre of a bounding box on the x axis
void alignHorizontalCentre(GameObject obj, float bounds) {
  obj.x = (bounds - obj.w) / 2;
}

// helper function to align an object to the centre of a bounding box on the y axis
void alignVerticalCentre(GameObject obj, float bounds) {
  obj.y = (bounds - (obj.h)) / 2;
}

// helper function to align an object to the centre of a bounding box on both axis
void alignCentre(GameObject obj, float maxWidth, float maxHeight) {
  alignHorizontalCentre(obj, maxWidth);
  alignVerticalCentre(obj, maxHeight);
}

// helper function measure a font
float getWidth(PFont font) {
  textFont(font);
  return textWidth('W');
}

// helper function to format a string as "X.XXms"
String formatMs(double ms) {
  return nf((float)ms * 1000, 0, 2) + "ms";
}
