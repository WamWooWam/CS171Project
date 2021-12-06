
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

  PShape square;
  Square[] squares;

  public Background() {
    super(0, 0, width, height);
    // create and initialise 100 squares.
    squares = new Square[100];
    for (int i = 0; i < squares.length; i++) {
      squares[i] = new Square();
    }

    // create the shape used to draw the squares.
    square = createShape();
    square.beginShape();
    square.fill(255, 255, 255);
    square.stroke(192, 192, 192);
    square.strokeWeight(1);
    square.vertex(-25, -25);
    square.vertex(-25, 25);
    square.vertex(25, 25);
    square.vertex(25, -25);
    square.endShape(CLOSE);
    
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
    // run through each square
    for (int i = 0; i < squares.length; i++) {
      Square bgSquare = squares[i];

      // draw it
      pushMatrix();
      translate(bgSquare.x, bgSquare.y);
      rotate(radians(bgSquare.rotation));
      shape(square);
      popMatrix();
    }
  }
}
