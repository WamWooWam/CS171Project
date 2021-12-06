
class MenuButton extends GameObject {

  private Text _label;
  private float _absoluteX;
  private float _absoluteY;
  private float arrowX;

  public boolean isSelected;
  public boolean isMouseSelected;

  private PShape arrow;
  private Animation arrowAnimation;
  private Storyboard pressAnimation;

  public MenuButton(float x, float y, float w, float h, String label) {
    super(x, y, w, h);

    _label = new Text(0, 0, label, g_consolas32);
    this.children.add(_label);

    arrow = createShape(TRIANGLE, 8, 8, 32, h / 2, 8, h - 8);
    arrow.setStrokeWeight(1);
    arrow.setFill(color(255,255,255));
    arrowAnimation = new Animation(-4, 4, 0.25f, -1, LoopMode.REVERSE, EASE_IN_OUT_SINE, (f) -> arrowX = f);

    pressAnimation = new Storyboard();
    pressAnimation.add(0.0f, new Animation(1, 0.95, 0.1f, EASE_IN_CUBIC, (f) -> this.scale = f));
    pressAnimation.add(0.2f, new Animation(0.95, 1.1, 0.15f, EASE_OUT_CUBIC, (f) -> this.scale = f));
    pressAnimation.add(0.5f, new Trigger(() -> this.scale = 1));
  }

  Storyboard getPressAnimation() {
    return pressAnimation;
  }

  void awakeObject() {
    arrowAnimation.begin(this);
  }

  void updateObject(float deltaTime) {
    _label.x = (w - _label.w) / 2;
    _label.y = (h - _label.h - 8) / 2;

    if ((mouseX > _absoluteX && mouseX < _absoluteX + w) && (mouseY > _absoluteY && mouseY < _absoluteY + h)) {
      isMouseSelected = true;
    } else {
      isMouseSelected = false;
    }
  }

  void drawObject() {
    _absoluteX = screenX(0, 0);
    _absoluteY = screenY(0, 0);
    
    stroke(0, 0, 0);
    strokeWeight(1); 
    fill(255, 255, 255);

    if (isSelected) {
      pushMatrix();
      translate(arrowX, 0);
      shape(arrow);

      translate(w - (arrowX * 2), h);
      rotate(PI);
      shape(arrow);
      popMatrix();
    }

    rect(48, 0, w - 96, h);
  }
}
