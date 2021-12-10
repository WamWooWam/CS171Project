
//
// this class reperesents a button used in the main and pause menus
//

class MenuButton extends GameObject {

  private Text label;
  private float arrowX;

  public boolean isSelected;

  private PShape arrow;
  private Animation arrowAnimation;
  private Storyboard pressAnimation;

  public MenuButton(float x, float y, float w, float h, String label) {
    super(x, y, w, h);

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
    this.pressAnimation.add(0.2f, new Animation(0.95, 1.1, 0.15f, EASE_OUT_CUBIC, (f) -> this.scale = f));
    this.pressAnimation.add(0.5f, new Trigger(() -> this.scale = 1));
  }

  Storyboard getPressAnimation() {
    return pressAnimation;
  }

  void awakeObject() {
    arrowAnimation.begin(this);
  }

  void updateObject(float deltaTime) {
    alignCentre(label, w, h);
  }

  void drawObject() {
    stroke(0, 0, 0);
    strokeWeight(1);
    fill(255, 255, 255);

    if (isSelected) {      
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
}
