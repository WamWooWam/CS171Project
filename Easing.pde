
//
// easing functions, all sourced from https://easings.net/
// these functions take "time" between [0..1] and produce a value that indicates
// the progress of an animation at that time.
//
interface Ease {
  float ease(float t);
}


static Ease LINEAR = (time) -> time;
static Ease ROUND = (time) -> round(time);

static Ease EASE_IN_CUBIC = (time) -> time * time * time;
static Ease EASE_OUT_CUBIC = (time) -> 1 - pow(1 - time, 3);
static Ease EASE_IN_OUT_CUBIC = (time) ->  time < 0.5 ? 4 * time * time * time : 1 - pow(-2 * time + 2, 3) / 2;

static Ease EASE_IN_SINE = (time) -> 1 - cos((time * PI) / 2);
static Ease EASE_OUT_SINE = (time) -> sin((time * PI) / 2);
static Ease EASE_IN_OUT_SINE = (time) -> -(cos(PI * time) - 1) / 2;

static Ease EASE_IN_CIRCLE = (time) -> 1 - sqrt(1 - pow(time, 2));
static Ease EASE_OUT_CIRCLE = (time) -> sqrt(1 - pow(time - 1, 2));
static Ease EASE_IN_OUT_CIRCLE = (time) ->
  time < 0.5
  ? (1 - sqrt(1 - pow(2 * time, 2))) / 2
  : (sqrt(1 - pow(-2 * time + 2, 2)) + 1) / 2;

static Ease EASE_OUT_BOUNCE = (x) -> {
  final float n1 = 7.5625;
  final float d1 = 2.75;

  if (x < 1 / d1) {
    return n1 * x * x;
  } else if (x < 2 / d1) {
    return n1 * (x -= 1.5 / d1) * x + 0.75;
  } else if (x < 2.5 / d1) {
    return n1 * (x -= 2.25 / d1) * x + 0.9375;
  } else {
    return n1 * (x -= 2.625 / d1) * x + 0.984375;
  }
};
