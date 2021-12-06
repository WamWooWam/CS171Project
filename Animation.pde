//
// what *is* an animation anyway? in it's simplest form an animation is changing a property
// from A to B over a period of time, using a function to ease that transition. this class
// aims to simplify the creation of animations by allowing me to declare these fundimental
// properties
//
// this animation system is loosely inspired by the one found in Microsoft's Windows
// Presentation Foundation, documented here:
// https://docs.microsoft.com/en-us/dotnet/desktop/wpf/graphics-multimedia/animation-overview
// otherwise, the implementation code is all mine.
//
import java.util.function.Consumer;

enum LoopMode {
  RESTART, REVERSE
}

//
// the animation timer interface allows parenting of animations to storyboards by allowing the
// storyboard to set the time base itself, this means seeking a storyboard also seeks all connected
// animations
//
interface AnimationTimer {
  void start();
  void seek(float time);
  float getElapsedSeconds();
}

//.
// rather than using the frameCount, the default animation timer uses System.nanoTime, which returns a timestamp
// in nanoseconds. this ensures the animation runs at a constant rate regardless of the actual framerate.
//
// note how _startTime is a long storing nanoseconds, not a float storing seconds, the latter caused an issue where
// animations would start to appear choppy after your computer had been on for a certain period of time (around a week)
// this was caused by floating point precision errors induced by converting such large fixed point numbers into a single
// precision float. 
//
// this implementation may still overflow, but this should only happen after around 280 days of continuous uptime.
//
class DefaultAnimationTimer implements AnimationTimer {
  private long _startTime = 0;

  void start() {
    this._startTime = System.nanoTime();
  }

  void seek(float time) {
    this._startTime = (System.nanoTime() - (long)(time * NS_TO_SEC));
  }

  public float getElapsedSeconds() {
    return (System.nanoTime() - this._startTime) / NS_TO_SEC;
  }
}

abstract class AnimationBase extends GameObject {
  protected boolean _running = false;
  protected Runnable _onCompleted;

  private AnimationTimer _animationTimer;
  protected void setAnimationTimer(AnimationTimer timer) {
    this._animationTimer = timer;
  }

  AnimationBase() {
    super(0, 0, 0, 0);
    _animationTimer = new DefaultAnimationTimer();
  }

  abstract float getDuration();

  void reset() {
    this._onCompleted = null;
  }

  boolean getRunning() {
    return this._running;
  }

  void begin(GameObject gameObject) {
    this.reset();

    this._onCompleted = () -> gameObject.children.remove(this);
    this._running = true;
    this._animationTimer.start();
    gameObject.children.add(this);
  }

  void stop() {
    this._running = false;
    if (this._onCompleted != null) {
      this._onCompleted.run();
    }
  }

  void seek(float time) {
    _animationTimer.seek(time);
  }

  float getElapsedSeconds() {
    return _animationTimer.getElapsedSeconds();
  }
}

class Animation extends AnimationBase {
  float from;
  float to;
  float duration;
  Ease ease;

  int loops;
  LoopMode loopMode;

  // using a consumer and lambda makes setting properties every frame significantly simpler
  Consumer<Float> action;

  private int completedLoops = 0;

  public Animation(float from, float to, float duration, Consumer<Float> action) {
    this(from, to, duration, LINEAR, action);
  }

  public Animation(float from, float to, float duration, Ease ease, Consumer<Float> action) {
    this(from, to, duration, 1, LoopMode.RESTART, ease, action);
  }

  public Animation(float from, float to, float duration, int loops, LoopMode loopMode, Ease ease, Consumer<Float> action) {
    super();

    this.from = from;
    this.to = to;
    this.duration = duration;
    this.ease = ease;
    this.loops = loops;
    this.loopMode = loopMode;
    this.action = action;
  }

  float getDuration() {
    // negative loops run forever.
    if (this.loops < 0) return Float.POSITIVE_INFINITY;

    return this.duration * loops;
  }

  void reset() {
    super.reset();
    this.completedLoops = 0;
  }

  void updateObject(float deltaTime) {
    if (!this._running) return;

    float rawElapsedTime = this.getElapsedSeconds() - (completedLoops * duration);
    float elapsedTime = min(rawElapsedTime, this.duration);

    float value = 0.0f;
    if (loopMode == LoopMode.REVERSE && (completedLoops % 2) != 0) {
      value = this.to + (this.from - this.to) * this.ease.ease(elapsedTime / this.duration);
    } else {
      value = this.from + (this.to - this.from) * this.ease.ease(elapsedTime / this.duration);
    }

    action.accept(value);

    if (rawElapsedTime >= this.duration) {
      completedLoops++;
      if (loops >= completedLoops) {
        // animation complete
        this._running = false;
        if (_onCompleted != null) {
          _onCompleted.run();
        }
      }
    }
  }
}

//
// An animation trigger is a special animation that doesn't actually *animate* but allows any arbitrary
// event to be run at any point in a storyboard.
//
class Trigger extends AnimationBase {
  private Runnable _trigger;

  public Trigger(Runnable trigger) {
    this._trigger = trigger;
  }

  float getDuration() {
    return 0.01f;
  }

  void updateObject(float deltaTime) {
    if (!this._running) return;

    this._running = false;
    this._trigger.run();
    if (_onCompleted != null) {
      _onCompleted.run();
    }
  }
}

//
// An interval is like a trigger, but happens repeatedly at a given frequency, for
// a period of time
//
class Interval extends AnimationBase {
  private float interval;
  private float duration;
  private Runnable trigger;
  
  private float nextInterval = -1;
  public Interval(float interval, float duration, Runnable trigger) {
    this.interval = interval;
    this.duration = duration;
    this.trigger = trigger;
  }

  float getDuration() {
    return duration;
  }

  void reset() {
    super.reset();
    nextInterval = -1;
  }

  void updateObject(float deltaTime) {
    if (!this._running) return;

    float rawElapsedTime = this.getElapsedSeconds();
    if (rawElapsedTime >= this.nextInterval) {
      this.trigger.run();
      this.nextInterval = rawElapsedTime + this.interval;
    }

    if (rawElapsedTime >= this.duration) {
      this._running = false;
      if (_onCompleted != null) {
        _onCompleted.run();
      }
    }
  }
}

//
// A storyboard is a collection of animations which, given a start time, will run together
//

class Storyboard extends AnimationBase {
  private ArrayList<StoryboardEvent> _events = new ArrayList();

  // calculates the duration of the storyboard, taken as the largest animation end time, plus
  // a small value to ensure all animations run to completion
  float getDuration() {
    float duration = 0.0f;
    for (int i = 0; i < _events.size(); i++) {
      StoryboardEvent event = _events.get(i);
      duration = max(duration, event.endTime);
    }

    return duration + 0.01;
  }

  Storyboard add(float startTime, AnimationBase anim) {
    _events.add(new StoryboardEvent(anim, startTime));
    return this;
  }

  Storyboard then(AnimationBase anim) {
    _events.add(new StoryboardEvent(anim, getDuration()));
    return this;
  }

  Storyboard then(float delay, AnimationBase anim) {
    _events.add(new StoryboardEvent(anim, getDuration() + delay));
    return this;
  }

  Storyboard with(AnimationBase anim) {
    _events.add(new StoryboardEvent(anim, _events.get(_events.size() - 1).startTime));
    return this;
  }
  
  Storyboard after(AnimationBase anim) {
    var lastEvent =_events.get(_events.size() - 1);
    _events.add(new StoryboardEvent(anim, lastEvent.endTime));
    return this;
  }
  
  void stop() {
    super.stop();
    for (int i = 0; i < _events.size(); i++) {
      StoryboardEvent event = _events.get(i);
      event.anim.stop();
    }
  }

  void reset() {
    super.reset();
    for (int i = 0; i < _events.size(); i++) {
      StoryboardEvent event = _events.get(i);
      event.triggered = false;
    }
  }

  void updateObject(float deltaTime) {
    if (!this._running) return;

    float elapsedTime = this.getElapsedSeconds();
    for (int i = 0; i < _events.size(); i++) {
      StoryboardEvent event = _events.get(i);
      if (!event.triggered && elapsedTime > event.startTime) {
        event.anim.setAnimationTimer(new StoryboardAnimationTimer(this, event.startTime));
        event.anim.begin(this);
        event.triggered = true;
      }
    }

    if (elapsedTime >= this.getDuration()) {
      // storyboard complete, todo: loops
      this._running = false;
      if (_onCompleted != null) {
        _onCompleted.run();
      }
    }
  }

  private class StoryboardAnimationTimer implements AnimationTimer {
    private Storyboard storyboard;
    private float startTime;

    StoryboardAnimationTimer(Storyboard storyboard, float startTime) {
      this.storyboard = storyboard;
      this.startTime = startTime;
    }

    // animations inside storyboards can't seek or start themselves
    void start() {
    }

    void seek(float time) {
    }

    public float getElapsedSeconds() {
      return storyboard.getElapsedSeconds() - startTime;
    }
  }

  private class StoryboardEvent {
    StoryboardEvent(AnimationBase anim, float startTime) {
      this.anim = anim;
      this.startTime = startTime;
      this.endTime = startTime + anim.getDuration();
      this.triggered = false;
    }

    public AnimationBase anim;
    public float startTime;
    public float endTime;
    public boolean triggered;
  }
}
