
//
// this is the base interface for an object that can be drawn to the screen.
//
// this process is split into two loops, "update" where object positions change
// timers get updated, etc. and "draw" in which visuals are actually drawn to
// the screen
//
interface Drawable {
  void update(float deltaTime);
  void draw();
}
