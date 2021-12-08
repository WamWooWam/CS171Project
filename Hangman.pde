
class Hangman extends GameObject {

  private static final int DRAW_LINE = 0;
  private static final int DRAW_CIRCLE = 1;

  // we encapsulate each line(), circle(), etc. command into a small class so they can be
  // effectively drawn one at a time in a for loop, without a boat load of "if(x < 3) return;"s
  private class DrawCommand {
    private int command;
    private float[] params;
    public DrawCommand(int command, float... params) {
      this.command = command;
      this.params = params;
    }
  }

  private DrawCommand[] drawCommands = {
    new DrawCommand(DRAW_LINE, 0, 592, 568, 592), // floor
    new DrawCommand(DRAW_LINE, 128, 592, 128, 0), // pole
    new DrawCommand(DRAW_LINE, 124, 0, 468, 0), // top bar
    new DrawCommand(DRAW_LINE, 128, 100, 228, 0), // support
    new DrawCommand(DRAW_LINE, 370, 0, 370, 128), // rope
    new DrawCommand(DRAW_CIRCLE, 370, 160, 96), // head
    new DrawCommand(DRAW_LINE, 370, 208, 370, 416), // body
    new DrawCommand(DRAW_LINE, 370, 260, 418, 292), // left arm
    new DrawCommand(DRAW_LINE, 370, 260, 322, 292), // right arm
    new DrawCommand(DRAW_LINE, 370, 416, 434, 512), // left leg
    new DrawCommand(DRAW_LINE, 370, 416, 306, 512), // right leg
    new DrawCommand(DRAW_CIRCLE, 355, 150, 5, 385, 150, 5), // eyes
    new DrawCommand(DRAW_LINE, 350, 185, 395, 175), // mouth
  };

  private GameSceneData state;

  public Hangman(GameSceneData state, float x, float y) {
    super(x, y, 592, 568); // todo: calc width, height
    this.state = state;
  }

  void updateObject(float deltaTime) {
  }

  void drawObject() {
    strokeWeight(8);
    strokeCap(SQUARE);
    fill(255, 255, 255);

    for (int i = 0; i < state.mistakes + 1; i++) {
      DrawCommand command = drawCommands[i];
      if (command.command == DRAW_LINE) {
        for (int j = 0; j < command.params.length / 4; j++) {
          line(command.params[j * 4], command.params[(j * 4) + 1], command.params[(j * 4) + 2], command.params[(j * 4) + 3]);
        }
      }
      if (command.command == DRAW_CIRCLE) {
        for (int j = 0; j < command.params.length / 3; j++) {
          circle(command.params[j * 3], command.params[(j * 3) + 1], command.params[(j * 3) + 2]);
        }
      }
    }
  }

  void centerObject(GameObject obj) {
    obj.x = (width - obj.w) / 2;
    obj.y = (height - (obj.h * 2)) / 2;
  }
}
