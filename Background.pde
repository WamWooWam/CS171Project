
//
// this class handles the drawing of background visuals for the main menu
// the background visuals consist of a bunch of squares floating down the screen from top left to bottom right
//
class Background extends GameObject {
  // this internal class holds data about a particle instance
  private class Particle {
    float x;
    float y;
    float speed;
    float rotation;

    public Particle() {
      // randomly assign properties to this particle
      this.x = random(-width, width);
      this.y = random(-height, 0);
      this.rotation = random(360);
      this.speed = random(100, 300);
    }
  }

  Particle[] squares;

  public Background(float simulateTime) {
    super(0, 0, width, height);

    this.fill = color(255, 255, 255);
    this.stroke = color(192, 192, 192, 255);
    this.strokeThickness = 1;

    // create and initialise 100 squares.
    squares = new Particle[100];
    for (int i = 0; i < squares.length; i++) {
      squares[i] = new Particle();
    }
    // simulate running for 5 seconds
    this.updateObject(simulateTime);
  }

  void updateObject(float deltaTime) {
    // run through each square
    for (int i = 0; i < squares.length; i++) {
      Particle bgSquare = squares[i];

      // increment the square's position and rotation
      bgSquare.x += bgSquare.speed * deltaTime;
      bgSquare.y += bgSquare.speed * deltaTime;
      bgSquare.rotation += bgSquare.speed * deltaTime;

      // if it's off the screen, replace this square with a new one
      if (bgSquare.x > (width + 50) || bgSquare.y > (height + 50)) {
        squares[i] = new Particle();
      }
    }
  }

  void drawObject() {
    // run through each square
    for (int i = 0; i < squares.length; i++) {
      Particle bgSquare = squares[i];

      // if it's off screen for whatever reason, skip drawing it
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
  }
}
