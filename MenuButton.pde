
//
// this class reperesents a button used in the main and pause menus
//

class MenuButton extends GameObject {

  private Text label;
  private float arrowX;

  public boolean isEnabled;
  public boolean isSelected;
  public boolean isPressed;

  private PShape arrow;
  private Animation arrowAnimation;
  private Storyboard pressAnimation;
  private Storyboard releaseAnimation;
  private Storyboard restoreAnimation;
  private Storyboard clickAnimation;

  private int index;
  private ButtonContainer parent;

  private Runnable action;

  public MenuButton(float x, float y, float w, float h, String label, Runnable action) {
    super(x, y, w, h);
    this.action = action;
    this.init(label);
  }

  public MenuButton(int index, ButtonContainer parent, float x, float y, float w, float h, String label) {
    super(x, y, w, h);
    this.index = index;
    this.parent = parent;
    this.init(label);
  }

  private void init(String label) {
    this.isEnabled = true;

    // create our label object
    this.label = new Text(0, 0, label, g_consolas32);
    this.children.add(this.label);

    // creates an arrow pointing towards the button
    this.arrow = createShape(TRIANGLE, 8, 8, 32, h / 2, 8, h - 8);
    this.arrow.setStrokeWeight(1);
    this.arrow.setFill(color(255, 255, 255));

    // animates the arrow in and out towards the button
    this.arrowAnimation = new Animation(-4, 4, 0.25f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> arrowX = f);

    // animates the button scale to imitate a pushing motion
    this.pressAnimation = new Storyboard();
    this.pressAnimation.add(0.0f, new Animation(1, 0.95, 0.1f, EASE_IN_CUBIC, (f) -> this.scale = f));

    this.releaseAnimation = new Storyboard();
    this.releaseAnimation.add(0.0f, new Animation(0.95, 1.1f, 0.15f, EASE_OUT_CUBIC, (f) -> this.scale = f));
    this.releaseAnimation.add(0.5f, new Trigger(() -> this.scale = 1));

    this.restoreAnimation = new Storyboard();
    this.restoreAnimation.add(0.0f, new Animation(0.95, 1.0f, 0.15f, EASE_OUT_CUBIC, (f) -> this.scale = f));

    this.clickAnimation = new Storyboard();
    this.clickAnimation.add(0.0f, this.pressAnimation);
    this.clickAnimation.add(0.2f, this.releaseAnimation);
  }

  Storyboard getPressAnimation() {
    return clickAnimation;
  }

  void awakeObject() {
    arrowAnimation.begin(this);
  }

  void updateObject(float deltaTime) {
    alignCentre(label, w, h);
  }

  void drawObject() {
    fill(255, 255, 255);
    if (isEnabled) {
      stroke(0, 0, 0);
      label.fill = color(0, 0, 0);
    } else {
      stroke(192, 192, 192);
      label.fill = color(192, 192, 192);
    }
    strokeWeight(1);

    if (isEnabled && isSelected) {
      // draw the arrows if we're selected
      pushMatrix();
      translate(arrowX, 0);
      shape(arrow);

      translate(w - (arrowX * 2), h);
      rotate(PI);
      shape(arrow);
      popMatrix();
    }

    // draw the outline rectangle
    rect(48, 0, w - 96, h);
  }

  void onMouseEntered() {
    if (!isEnabled) return;

    if (this.parent != null) {
      this.parent.selectedButton = index;
    } else {
      this.isSelected = true;
    }
  }

  void onMouseLeft() {
    if (!isEnabled) return;

    if (this.parent == null) {
      this.isSelected = false;
    }

    if (this.isPressed) {
      this.isPressed = false;
      this.restoreAnimation.begin(this);
    }
  }

  void onMousePressed(float x, float y) {
    if (mouseButton != LEFT) return;
    if (!isEnabled) return;
    this.isPressed = true;
    this.pressAnimation.begin(this);
  }

  void onMouseReleased(float x, float y) {
    if (mouseButton != LEFT) return;
    if (!isEnabled) return;

    if (this.isPressed) {
      this.isPressed = false;
      this.releaseAnimation.begin(this);

      if (this.parent != null) {
        this.parent.activateButton(index);
      } else {
        this.action.run();
      }
    }
  }
}

abstract class ButtonContainer extends GameObject {

  // keep track of the selected button
  int selectedButton = 0;
  // as well as the buttons we're showing
  private ArrayList<MenuButton> buttons;

  private boolean mouseOverrideSelection = false;

  public ButtonContainer(float x, float y, float w, float h) {
    super(x, y, w, h);

    this.buttons = new ArrayList<MenuButton>();
  }

  MenuButton addButton(float x, float y, float w, float h, String label) {
    var button = new MenuButton(this.buttons.size(), this, x, y, w, h, label);
    this.buttons.add(button);
    this.children.add(button);

    return button;
  }

  void awakeObject() {
    for (int i = 0; i < buttons.size(); i++) {
      buttons.get(i).pressAnimation.stop();
      buttons.get(i).releaseAnimation.stop();
      buttons.get(i).restoreAnimation.stop();
      buttons.get(i).clickAnimation.stop();
      buttons.get(i).scale = 1;
    }
  }

  void updateObject(float deltaTime) {
    // update the selected button
    for (int i = 0; i < buttons.size(); i++) {
      buttons.get(i).isSelected = i == selectedButton;
    }
  }

  void onMouseMoved(float x, float y) {
    if (!this.shouldHandleEvents()) return;

    if (!mouseOverrideSelection) {
      for (int i = 0; i < buttons.size(); i++) {
        buttons.get(i).isSelected = false;
      }
    }

    mouseOverrideSelection = true;
  }

  boolean onKeyPressed() {
    if (!this.shouldHandleEvents()) return false;

    if (keyCode == UP) {
      mouseOverrideSelection = false;
      // move the selection up one
      selectedButton = selectedButton - 1;
      if (selectedButton < 0) {
        // wrap around if needed
        selectedButton = buttons.size() - 1;
      }

      g_audio.playCue(0);
    }

    if (keyCode == DOWN) {
      mouseOverrideSelection = false;
      // move the selection down one
      selectedButton = selectedButton + 1;
      if (selectedButton >= buttons.size()) {
        // wrap around if needed
        selectedButton = 0;
      }

      g_audio.playCue(0);
    }

    if ((keyCode == ENTER || keyCode == RETURN) && selectedButton >= 0) {
      buttons.get(selectedButton).getPressAnimation().begin(this);
      activateButton();
      return true;
    }

    return false;
  }

  private void activateButton() {
    if (!this.shouldHandleEvents()) return;
    this.onClick(selectedButton);
  }

  private void activateButton(int idx) {
    if (!this.shouldHandleEvents()) return;
    this.onClick(idx);
  }

  abstract boolean shouldHandleEvents();
  abstract void onClick(int idx);
}
