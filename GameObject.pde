
import java.awt.geom.Rectangle2D;

// a GameObject is a drawable with a position, bounds, and children. they can be made active or inactive
class GameObject implements Drawable {
  private boolean isActive = true;
  private boolean isPaused = false;

  private boolean hasAwoken = false;
  protected boolean wasPaused = false;

  public float x;
  public float y;
  public float w;
  public float h;
  public float rot;
  public float scale;
  public ArrayList<GameObject> children;

  public Integer fill;
  public Integer stroke;
  public Integer strokeThickness;

  public boolean getActive() {
    return isActive;
  }

  public void setActive(boolean active) {
    isActive = active;
    if (!isActive) {
      hasAwoken = false;
    }
  }

  public boolean getPaused() {
    return isPaused;
  }

  public void setPaused(boolean paused) {
    isPaused = paused;
    if (isPaused) {
      wasPaused = true;
    }
  }

  // this returns a rectangle containing the bounds of the object
  // which is incredibly useful for calculating intersections
  public Rectangle2D getBounds() {
    return new Rectangle2D.Float(x, y, w, h);
  }

  public GameObject(float x, float y, float width, float height) {
    this.x = x;
    this.y = y;
    this.w = width;
    this.h = height;
    this.scale = 1;
    this.isActive = true;
    this.children = new ArrayList<>();
    this.fill = color(255, 255, 255);
    this.stroke = color(0, 0, 0);
  }

  final void update(float deltaTime) {
    if (!isActive || isPaused) {
      return;
    }

    g_objectUpdateCount++;

    if (!hasAwoken) {
      awakeObject();
      hasAwoken = true;
    }

    updateObject(deltaTime);

    for (int i = 0; i < children.size(); i++)
      children.get(i).update(deltaTime);

    wasPaused = false;
  }

  final void draw() {
    if (!isActive) {
      return;
    }

    g_objectDrawCount++;
    
    pushMatrix();
    translate(x, y);

    if (DEBUGGER && DEBUG_OBJECT_BOUNDS) {
      fill(255, 255, 255, 1);
      stroke(0, 0, 0);
      strokeWeight(1);
      rect(0, 0, w, h);
    }

    if (fill != null)
      fill(fill);
    if (stroke != null)
      stroke(stroke);
    if (strokeThickness != null)
      strokeWeight(strokeThickness);

    translate(w / 2, h / 2);
    rotate(radians(rot));
    scale(scale);
    translate(-w / 2, -h / 2);

    drawObject();

    for (GameObject child : children)
      child.draw();

    popMatrix();
  }

  void keyPressed() {
    for (int i = 0; i < children.size(); i++)
      children.get(i).keyPressed();
  }

  void awakeObject() {
  }
  void updateObject(float deltaTime) {
  }
  void drawObject() {
  }
}
