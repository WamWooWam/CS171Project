
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

    // keep track of and 
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
    
    // push a matrix for this object
    pushMatrix();
    
    // translate to the x,y position of this object (this will be relative to the parent object)
    translate(x, y);
    
    // in order to apply rotations and scaling at the centre coordinate of the object, 
    // we first move the translation matrix to the centre, then apply rotation and scaling
    translate(w / 2, h / 2);
    
    // rotation is in degrees for simplicity 
    rotate(radians(rot));
    scale(scale);
    
    // then move back
    translate(-w / 2, -h / 2);
    
    // draw the object bounds
    if (DEBUGGER && DEBUG_OBJECT_BOUNDS) {
      fill(255, 255, 255, 1);
      stroke(0, 0, 0);
      strokeWeight(1);
      rect(0, 0, w, h);
    }

    // assign the object's fill/stroke/strokeWeight
    if (fill != null)
      fill(fill);
    if (stroke != null)
      stroke(stroke);
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
    // allow this object's keypress handler to skip any child objects
    if (this.onKeyPressed()) return;    
    
    // pass on any keyPress events to child objects
    for (int i = 0; i < children.size(); i++)
      children.get(i).keyPressed();
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
}
