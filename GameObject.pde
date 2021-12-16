
import java.awt.geom.Rectangle2D;

// a GameObject is a drawable with a position, bounds, and children. they can be made active or inactive
class GameObject implements Drawable {
  private boolean isActive = true;

  private boolean hasAwoken = false;

  // certain game objects dont need to draw anything, so this optimisation allows them to skip this
  protected boolean skipDraw = false;
  // pausing the game is implemented by skipping the update loop, but continuing to draw
  protected boolean skipUpdate = false;
  protected boolean wasPaused = false;
  // keeps track of if the mouse is inside the current game object
  private boolean wasMouseInBounds = false;

  // intrinsic object properties
  public float x;
  public float y;
  public float w;
  public float h;
  public float rot;
  public float scale;
  public ArrayList<GameObject> children;

  private float originX = 0.5;
  private float originY = 0.5;

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
    return skipUpdate;
  }

  public void setPaused(boolean paused) {
    skipUpdate = paused;
    if (skipUpdate) {
      wasPaused = true;
    }
  }

  // this returns a rectangle containing the bounds of the object
  // which is incredibly useful for calculating intersections
  public Rectangle2D getBounds() {
    return new Rectangle2D.Float(x, y, w, h);
  }

  // allows objects to adjust the origin of their rotation/scale, see further explanation in
  // draw()
  public void setOrigin(float x, float y) {
    originX = x;
    originY = y;
  }

  public GameObject(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.scale = 1;
    this.isActive = true;
    this.children = new ArrayList<>();
    this.fill = color(255, 255, 255, 255);
    this.stroke = color(0, 0, 0, 255);
  }

  final void update(float deltaTime) {
    if (!isActive || skipUpdate) {
      return;
    }

    g_objectUpdateCount++;

    // if this is our first call to update, run the awake function first
    if (!hasAwoken) {
      awakeObject();
      hasAwoken = true;
    }

    // update the object
    updateObject(deltaTime);

    // update children
    for (int i = 0; i < children.size(); i++)
      children.get(i).update(deltaTime);

    // ensure the object knows we aren't paused
    wasPaused = false;
  }

  final void draw() {
    if (!isActive || skipDraw) {
      return;
    }

    g_objectDrawCount++;

    // push a matrix for this object
    pushMatrix();

    // translate to the x,y position of this object (this will be relative to the parent object)
    translate(x, y);

    // we allow objects to transform their rotation and scale from any arbitrary origin they wish,
    // defaulting to the centre of the object, this gives much greater freedom in animation effects
    // origin points are stored as fractions of the object width/height between 0 and 1
    //
    // sourced from: https://gist.github.com/atduskgreg/1516424#file-rotation_around_a_point-pde-L21
    // modified to work with any arbitrary point of origin
    translate(w * originX, h * originY);

    // draw the point of origin
    if (DEBUGGER && DEBUG_OBJECT_BOUNDS) {
      fill(0, 0, 0);
      stroke(0, 0, 0);
      strokeWeight(1);
      square(0, 0, 2);
    }

    // rotation is in degrees for simplicity
    rotate(radians(rot));
    scale(scale);

    // then move back
    translate(-w * originX, -h * originY);

    // draw the object bounds
    if (DEBUGGER && DEBUG_OBJECT_BOUNDS) {
      fill(255, 255, 255, 1);
      rect(0, 0, w, h);
    }

    // assign the object's fill/stroke/strokeWeight
    // processing is stupid and assumes 0 (i.e. rgba(0,0,0,0)) is actually pure black (rgba(0,0,0,1))
    // as such we manually extract and specify the alpha value (this is documented nowhere)
    // source: https://stackoverflow.com/a/49701996
    if (fill != null)
      fill(fill, 0xFF & fill >> 24); 
    if (stroke != null)
      stroke(stroke, 0xFF & stroke >> 24);
    if (strokeThickness != null)
      strokeWeight(strokeThickness);

    // execute the object's own draw function
    drawObject();

    // then draw any children of this object
    for (GameObject child : children)
      child.draw();

    // then restore the transformation matrix to what it was before drawing this object
    popMatrix();
  }

  final void keyPressed() {
    if (!isActive) {
      return;
    }

    // allow this object's keypress handler to skip any child objects
    if (this.onKeyPressed()) return;

    // pass on any keyPress events to child objects
    for (int i = 0; i < children.size(); i++)
      children.get(i).keyPressed();
  }

  // called recursively whenever the mouse is moved
  final void mouseMoved() {
    if (!isActive) {
      return;
    }

    translate(x, y);

    // calculate the position of the object
    var absoluteX = screenX(0, 0);
    var absoluteY = screenY(0, 0);

    // if the mouse is in our bounds
    if ((mouseX > absoluteX && mouseX < absoluteX + w) && (mouseY > absoluteY && mouseY < absoluteY + h)) {
      if (!wasMouseInBounds) {
        this.onMouseEntered();
        this.wasMouseInBounds = true;
      }

      this.onMouseMoved(mouseX - absoluteX, mouseY - absoluteY);
      // pass on any mouse events to child objects
      for (int i = 0; i < children.size(); i++)
        this.children.get(i).mouseMoved();
    } else if (wasMouseInBounds) {
      this.onMouseLeft();
      this.wasMouseInBounds = false;
    }

    translate(-x, -y);
  }

  final void mousePressed() {
    if (!isActive) {
      return;
    }

    translate(x, y);

    // calculate the position of the object
    var absoluteX = screenX(0, 0);
    var absoluteY = screenY(0, 0);

    // if the mouse is in our bounds
    if ((mouseX > absoluteX && mouseX < absoluteX + w) && (mouseY > absoluteY && mouseY < absoluteY + h)) {
      this.onMousePressed(mouseX - absoluteX, mouseY - absoluteY);
      // pass on any mouse events to child objects
      for (int i = 0; i < children.size(); i++)
        this.children.get(i).mousePressed();
    }

    translate(-x, -y);
  }

  final void mouseReleased() {
    if (!isActive) {
      return;
    }

    translate(x, y);

    // calculate the position of the object
    var absoluteX = screenX(0, 0);
    var absoluteY = screenY(0, 0);

    // if the mouse is in our bounds
    if ((mouseX > absoluteX && mouseX < absoluteX + w) && (mouseY > absoluteY && mouseY < absoluteY + h)) {
      this.onMouseReleased(mouseX - absoluteX, mouseY - absoluteY);
      // pass on any mouse events to child objects
      for (int i = 0; i < children.size(); i++)
        this.children.get(i).mouseReleased();
    }

    translate(-x, -y);
  }
  // these are methods to be implemented by the object to update, draw, handle events, etc.

  // awake is called before the first update loop
  protected void awakeObject() {
  }

  // update is called during the update loop and should handle creating/destroying new objects
  // and changing object values
  protected void updateObject(float deltaTime) {
  }

  // draw should be used to draw the object itself
  protected void drawObject() {
  }

  // onKeyPressed allows objects to react to keyboard keys, if `true` is returned from this handler,
  // we skip processing key events for child objects.
  protected boolean onKeyPressed() {
    return false;
  }

  protected void onMouseEntered() {
  }

  // onMouseMoved allows objects to react to mouse movements inside their bounds
  protected void onMouseMoved(float x, float y) {
  }

  protected void onMouseLeft() {
  }

  protected void onMousePressed(float x, float y) {
  }

  protected void onMouseReleased(float x, float y) {
  }
}
