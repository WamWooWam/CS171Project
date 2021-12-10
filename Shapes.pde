
// contains GameObjects that wrap primitive shapes

class Rectangle extends GameObject {

  public Rectangle(float x, float y, float w, float h) {
    super(x, y, w, h);
  }

  void drawObject() {
    rect(0, 0, w, h);
  }
}
