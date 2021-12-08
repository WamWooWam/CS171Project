
//
// this class handles the drawing of background visuals for the main menu
// the background visuals consist of a bunch of squares floating down the screen from top left to bottom right
//
class Background extends GameObject {

  // this internal class holds data about a particle instance
  class Square {
    float x;
    float y;
    float speed;
    float rotation;

    public Square() {
      this.x = random(-width, width);
      this.y = random(-height, 0);
      this.rotation = random(360);
      this.speed = random(100, 300);
    }
  }

  Square[] squares;

  public Background() {
    super(0, 0, width, height);
    // create and initialise 100 squares.
    squares = new Square[100];
    for (int i = 0; i < squares.length; i++) {
      squares[i] = new Square();
    }
    // simulate running for 5 seconds
    this.updateObject(5);
  }

  void updateObject(float deltaTime) {
    // run through each square
    for (int i = 0; i < squares.length; i++) {
      Square bgSquare = squares[i];

      // increment the square's position and rotation
      bgSquare.x += bgSquare.speed * deltaTime;
      bgSquare.y += bgSquare.speed * deltaTime;
      bgSquare.rotation += bgSquare.speed * deltaTime;

      // if it's off the screen, replace this square with a new one
      if (bgSquare.x > (width + 50) || bgSquare.y > (height + 50)) {
        squares[i] = new Square();
      }
    }
  }

  void drawObject() {
    fill(255, 255, 255);
    stroke(192, 192, 192);
    strokeWeight(1);

    // run through each square
    for (int i = 0; i < squares.length; i++) {
      Square bgSquare = squares[i];

      if (bgSquare.x < -50 || bgSquare.y < -50 || bgSquare.x > (width + 50) || bgSquare.y > (height + 50)) {
        continue;
      }

      // draw it
      pushMatrix();
      translate(bgSquare.x, bgSquare.y);
      rotate(radians(bgSquare.rotation));
      square(-25, -25, 50);
      popMatrix();
    }

    noClip();
  }
}
