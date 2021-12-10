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
  void seek(double time);
  double getElapsedSeconds();
}

interface AnimationAction {
  void action(float f);
}

interface TriggerAction {
  void action();
}

// 
// the animation timer is used by animations to calculate their current position relative to time
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

  void seek(double time) {
    this._startTime = System.nanoTime() - (long)(time * NS_TO_SEC);
  }

  public double getElapsedSeconds() {
    return (System.nanoTime() - this._startTime) / NS_TO_SEC;
  }
}

//
// the base animation class stores properties and methods common to each animation type
//
abstract class AnimationBase extends GameObject {
  protected boolean isRunning = false;

  private GameObject attachedGameObject = null;
  private AnimationTimer animationTimer;
  protected void setAnimationTimer(AnimationTimer timer) {
    this.animationTimer = timer;
  }

  protected AnimationBase() {
    super(0, 0, 0, 0); // an animation has no width/height/position
    this.skipDraw = true;
    this.animationTimer = new DefaultAnimationTimer();
  }

  // animation types must provide their own duration 
  abstract double getDuration();

  protected void reset() {
    // detach ourselves from our parent
    if (attachedGameObject != null) {
      g_attachedAnimations--;
      attachedGameObject.children.remove(this);
    }

    attachedGameObject = null;
  }

  boolean running() {
    return this.isRunning;
  }

  // starts an animation by attaching this object to a parent
  void begin(GameObject gameObject) {
    this.reset();

    this.isRunning = true;
    this.animationTimer.start();
    this.attachedGameObject = gameObject;
    this.attachedGameObject.children.add(this);
    g_attachedAnimations++;
  }
  
  // stops an animation and detaches it from the parent object
  void stop() {
    this.isRunning = false;
    this.reset();
  }
  
  // seeks an animation to a specific point in time
  void seek(double time) {
    animationTimer.seek(time);
  }

  // get the current animation time
  protected double getElapsedSeconds() {
    return animationTimer.getElapsedSeconds();
  }
  
  // function to be called when an animation finishes
  protected void onCompleted() {
    this.reset();
  }
}

class Animation extends AnimationBase {
  float from;
  float to;
  double duration;

  int loops;
  LoopMode loopMode;
  
  Ease ease;

  // using a lambda makes setting properties every frame significantly simpler
  AnimationAction action;

  private int completedLoops = 0;

  // declare a couple of convenience constructors for short linear animations
  public Animation(float from, float to, double duration, AnimationAction action) {
    this(from, to, duration, LINEAR, action);
  }

  public Animation(float from, float to, double duration, Ease ease, AnimationAction action) {
    this(from, to, duration, 1, LoopMode.RESTART, ease, action);
  }

  public Animation(float from, float to, double duration, int loops, LoopMode loopMode, Ease ease, AnimationAction action) {
    super();

    this.from = from;
    this.to = to;
    this.duration = duration;
    this.ease = ease;
    this.loops = loops;
    this.loopMode = loopMode;
    this.action = action;
  }

  double getDuration() {
    // negative loops run forever.
    if (this.loops < 0) return Double.POSITIVE_INFINITY;

    return this.duration * loops;
  }

  void reset() {
    super.reset();
    this.completedLoops = 0;
  }

  void updateObject(float deltaTime) {
    if (!this.isRunning) return;

    g_activeAnimations += 1;

    // calculate the current animation time relative to the current loop, and clamp it
    // to the maximum loop duration
    double rawElapsedTime = this.getElapsedSeconds() - (completedLoops * duration);
    double elapsedTime = Math.min(rawElapsedTime, this.duration);

    // calculate the current, eased value
    double value = 0.0d;
    if (loopMode == LoopMode.REVERSE && (completedLoops % 2) != 0) {
      value = this.to + (this.from - this.to) * this.ease.ease(elapsedTime / this.duration);
    } else {
      value = this.from + (this.to - this.from) * this.ease.ease(elapsedTime / this.duration);
    }

    // call the action with the current value
    action.action((float)value);

    if (rawElapsedTime >= this.duration) {
      completedLoops++;
      if (loops >= completedLoops) {
        // animation complete
        this.isRunning = false;
        this.onCompleted();
      }
    }
  }
}

//
// An animation trigger is a special animation that doesn't actually *animate* but allows any arbitrary
// event to be run at any point in a storyboard.
//
class Trigger extends AnimationBase {
  private TriggerAction trigger;

  public Trigger(TriggerAction trigger) {
    this.trigger = trigger;
  }

  double getDuration() {
    return 0.01f;
  }

  void updateObject(float deltaTime) {
    if (!this.isRunning) return;

    g_activeAnimations += 1;

    this.isRunning = false;
    this.trigger.action();
    this.onCompleted();
  }
}

//
// An interval is like a trigger, but happens repeatedly at a given frequency, for
// a period of time
//
class Interval extends AnimationBase {
  private double interval;
  private double nextInterval = -1;
  private double duration;
  private TriggerAction trigger;

  public Interval(double interval, double duration, TriggerAction trigger) {
    this.interval = interval;
    this.duration = duration;
    this.trigger = trigger;
  }

  double getDuration() {
    return duration;
  }

  void reset() {
    super.reset();
    nextInterval = -1;
  }

  void updateObject(float deltaTime) {
    if (!this.isRunning) return;

    g_activeAnimations += 1;

    // get the current time
    double rawElapsedTime = this.getElapsedSeconds();
    
    // if the current time is greater than the next interval time, run the trigger
    if (rawElapsedTime >= this.nextInterval) {
      this.trigger.action();
      // store our next interval time
      this.nextInterval = rawElapsedTime + this.interval;
    }
    
    // if the total time is greater than our duration
    if (rawElapsedTime >= this.duration) {
      // stop the animation
      this.isRunning = false;
      this.onCompleted();
    }
  }
}

//
// A storyboard is a collection of animations which, given a start time, will run together.
// It is implemented as a sequence of events which start and end at specific times.
//

class Storyboard extends AnimationBase {
  private ArrayList<StoryboardEvent> events = new ArrayList<>();

  // calculates the duration of the storyboard, taken as the largest animation end time, plus
  // a small value to ensure all animations run to completion
  double getDuration() {
    double duration = 0.0f;
    for (int i = 0; i < events.size(); i++) {
      StoryboardEvent event = events.get(i);
      duration = Math.max(duration, event.endTime);
    }

    return duration;
  }

  // add an animation at a specific start time
  Storyboard add(double startTime, AnimationBase anim) {
    events.add(new StoryboardEvent(anim, startTime));
    return this;
  }

  // add an animation at the very end of the storyboard
  Storyboard then(AnimationBase anim) {
    return this.then(0, anim);
  }

  // add an animation at the end of the storyboard + a delay
  Storyboard then(float delay, AnimationBase anim) {
    events.add(new StoryboardEvent(anim, getDuration() + delay));
    return this;
  }

  // add an animation to run concurrently with the previous animation, if any
  Storyboard with(AnimationBase anim) {
    if (events.size() > 0) {
      events.add(new StoryboardEvent(anim, events.get(events.size() - 1).startTime));
    } else {
      events.add(new StoryboardEvent(anim, 0));
    }
    return this;
  }
  
  // add an animation to run after the previously added animation
  // (not always storyboard length)
  Storyboard after(AnimationBase anim) {
    var lastEvent = events.get(events.size() - 1);
    events.add(new StoryboardEvent(anim, lastEvent.endTime));
    return this;
  }

  void seek(double time) {
    super.seek(time);
  }

  void stop() {
    super.stop();
    // stop all children
    for (int i = 0; i < events.size(); i++) {
      StoryboardEvent event = events.get(i);
      event.anim.stop();
    }
  }

  void reset() {
    super.reset();
    // stop reset children
    for (int i = 0; i < events.size(); i++) {
      StoryboardEvent event = events.get(i);
      event.triggered = false;
      event.anim.reset();
    }
  }

  void updateObject(float deltaTime) {
    if (!this.isRunning) return;

    g_activeAnimations += 1;

    // get our total time and run through each event
    double elapsedTime = this.getElapsedSeconds();
    for (int i = 0; i < events.size(); i++) {
      StoryboardEvent event = events.get(i);
      
      // if the event has not been run already, and its starting time is greater than or
      // equal to the current time, start the animation
      if (!event.triggered && elapsedTime >= event.startTime) {
        // set the animations timer to one that is parented to this storyboard
        event.anim.setAnimationTimer(new StoryboardAnimationTimer(this, event.startTime, event.endTime));
        event.anim.begin(this);
        event.triggered = true;
      }
    }

    if (elapsedTime >= (this.getDuration() + 1.0f)) {
      // storyboard complete, todo: loops
      this.isRunning = false;
      this.onCompleted();
    }
  }

  // a storyboard specifies its own animation timer to allow animations to run synchronised, and seeking back and forth
  private class StoryboardAnimationTimer implements AnimationTimer {
    private Storyboard storyboard;
    private double startTime;
    private double endTime;

    StoryboardAnimationTimer(Storyboard storyboard, double startTime, double endTime) {
      this.storyboard = storyboard;
      this.startTime = startTime;
      this.endTime = endTime;
    }

    // animations inside storyboards can't seek or start themselves
    void start() {
    }

    void seek(double time) {
    }

    public double getElapsedSeconds() {
      return Math.max(0, Math.min(storyboard.getElapsedSeconds() - startTime, endTime - startTime));
    }
  }

  // this class stores an event within a storyboard
  private class StoryboardEvent {
    StoryboardEvent(AnimationBase anim, double startTime) {
      this.anim = anim;
      this.startTime = startTime;
      this.endTime = startTime + anim.getDuration();
      this.triggered = false;
    }

    public AnimationBase anim;
    public double startTime;
    public double endTime;
    public boolean triggered;
  }
}
