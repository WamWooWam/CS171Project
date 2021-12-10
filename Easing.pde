
//
// easing functions, all sourced from https://easings.net/, then ported to java
//
// in the real world, no motion starts and stops instantly, there is always a period of
// acceleration/deceleration 
//
// these functions take "time" between [0..1] and produce a value that indicates
// the progress of an animation at that time, applying a specific acceleration curve
//

interface Ease {
  double ease(double t);
}

static Ease LINEAR = (time) -> time;
static Ease ROUND = (time) -> Math.round(time);

static Ease EASE_IN_CUBIC = (time) -> time * time * time;
static Ease EASE_OUT_CUBIC = (time) -> 1 - Math.pow(1 - time, 3);
static Ease EASE_IN_OUT_CUBIC = (time) ->  time < 0.5 ? 4 * time * time * time : 1 - Math.pow(-2 * time + 2, 3) / 2;

static Ease EASE_IN_SINE = (time) -> 1 - Math.cos((time * PI) / 2);
static Ease EASE_OUT_SINE = (time) -> Math.sin((time * PI) / 2);
static Ease EASE_IN_OUT_SINE = (time) -> -(Math.cos(PI * time) - 1) / 2;

static Ease EASE_IN_CIRCLE = (time) -> 1 - Math.sqrt(1 - Math.pow(time, 2));
static Ease EASE_OUT_CIRCLE = (time) -> Math.sqrt(1 - Math.pow(time - 1, 2));
static Ease EASE_IN_OUT_CIRCLE = (time) ->
  time < 0.5
  ? (1 - Math.sqrt(1 - Math.pow(2 * time, 2))) / 2
  : (Math.sqrt(1 - Math.pow(-2 * time + 2, 2)) + 1) / 2;

static Ease EASE_OUT_BOUNCE = (time) -> {
  final double n1 = 7.5625;
  final double d1 = 2.75;

  if (time < 1 / d1) {
    return n1 * time * time;
  } else if (time < 2 / d1) {
    return n1 * (time -= 1.5 / d1) * time + 0.75;
  } else if (time < 2.5 / d1) {
    return n1 * (time -= 2.25 / d1) * time + 0.9375;
  } else {
    return n1 * (time -= 2.625 / d1) * time + 0.984375;
  }
};
