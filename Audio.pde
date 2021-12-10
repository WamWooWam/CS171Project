
import ddf.minim.*;

//
// The audio class acts as a wrapper around Minim and facilitates the loading/playing of
// sound effect cues and background music (bgm)
//
// I use Minim, as introduced in CS171 Topic 6, wrapped in my own implementation
//
class Audio {
  // store our minim object
  private Minim minim = null;

  // bgm and sfx are called by their index
  private final SoundCue[] sfxCues;
  private final MusicTrack[] bgmTracks;

  // keep track of what's now playing to allow cross fading etc.
  private MusicTrack playingTrack;
  private MusicTrack nextTrack;
  private float fadeTime;
  private float fadeDuration;

  // maximum global volume
  private float musicVolume = 0.85f;
  private float soundEffectVolume = 0.90f;

  // minim sometimes doesn't init correctly, and in that case, we must manually disable audio.
  private boolean audioInitialised = false;

  public Audio(Object sketch) {
    // to simplify adding new sound effects and music, we load a list from an external text file
    // sound effects are listed one per line
    String[] soundEffects = loadStrings("sfx/sfx.txt");
    sfxCues = new SoundCue[soundEffects.length];

    // bgm.txt is a comma separated list formatted like:
    // fileName,startSample,loopStartSample,loopEndSample
    String[] backgroundMusic = loadStrings("bgm/bgm.txt");
    bgmTracks = new MusicTrack[backgroundMusic.length];

    try {
      // init minim
      minim = new Minim(sketch);

      // load each sound effect
      for (int i = 0; i < soundEffects.length; i++) {
        sfxCues[i] = new SoundCue(soundEffects[i]);
      }

      // load each music track
      for (int i = 0; i < backgroundMusic.length; i++) {
        bgmTracks[i] = new MusicTrack(i, backgroundMusic[i]);
      }

      // we have audio playback!
      audioInitialised = true;
    }
    catch(Throwable t) {
      // audio init failed for some godforsaken reason
      // i blame linux
    }
  }

  // play a sound effect cue
  void playCue(int cue) {
    if (!audioInitialised) return;
    sfxCues[cue].trigger();
  }

  // play background music
  void playBgm(int track, float fadeTime) {
    if (!audioInitialised) return;

    if (this.playingTrack != null) {
      // if we already have a track, and it's the same track, nwe have nothing to do
      if (this.playingTrack.id == track) return;

      // otherwise, queue up the next track, and store the fade time
      this.nextTrack = this.bgmTracks[track];
      this.fadeDuration = fadeTime;
      this.fadeTime = fadeTime;
    } else {
      // if we don't, immediately start playing this track
      this.playingTrack = this.bgmTracks[track];
      this.playingTrack.play();
    }
  }

  // set the current bgm volume, used for manual fades
  void setVolume(float volume) {
    if (!audioInitialised) return;

    // if we have a track
    if (this.playingTrack != null) {
      // set its volume
      this.playingTrack.setVolume(volume);
    }
  }

  // this update loop handles fades between music tracks
  void update(float deltaTime) {
    if (!audioInitialised) return;

    // if we have a queued track
    if (this.nextTrack != null) {
      // work out our current fade position
      this.fadeTime = max(0, this.fadeTime - deltaTime);

      // if we have very little time left
      if (this.fadeTime < EPSILON) {
        // stop the current track
        this.playingTrack.stop();

        // play the next track
        this.nextTrack.setVolume(1);
        this.nextTrack.play();

        // assign the next track to the current track, reset and return
        this.playingTrack = this.nextTrack;
        this.nextTrack = null;
        this.fadeTime = 0;
        return;
      }

      // otherwise, fade out the currently playing track
      this.playingTrack.setVolume(this.fadeTime / this.fadeDuration);
    }
  }

  // this draws the audio debugger
  void draw(int start) {
    if (!audioInitialised) return;

    if (this.playingTrack != null) {
      text("main_volume: " + this.playingTrack.getVolume(), 16, start + 24);
      text("current_bgm: " + this.playingTrack.id, 16, start + 48);
      text("bgm_pos: " + this.playingTrack.getPosition(), 16, start + 72);
    }

    if (this.nextTrack != null) {
      text("next_bgm: " + this.nextTrack.id, 16, start + 96);
      text("fade_time: " + this.fadeTime, 16, start + 120);
      text("fade_time_total: " + this.fadeDuration, 16, start + 144);
    }
  }

  // this class holds information about a sound effect cue
  private class SoundCue {
    private AudioSample sample;

    public SoundCue(String name) {
      this.sample =  minim.loadSample("sfx/" + name + ".wav");
      this.setVolume(1.0f);
    }

    void trigger() {
      this.sample.trigger();
    }

    // sets the volume of an audio sample.
    // for some reason, minim calls this method deprecated, but doesn't seem to allow
    // any other way to ensure a control exists on an object? maybe i'm blind, but this works
    // so we can ignore these warnings for now. ditto for everywhere else this appears
    void setVolume(float volume) {
      volume = map(volume, 0.0, 1.0, 0.0, soundEffectVolume);
      if (this.sample.hasControl(Controller.VOLUME)) {
        this.sample.setVolume(volume);
      } else if (this.sample.hasControl(Controller.GAIN)) {
        this.sample.setGain(map(volume, 0.0, 1.0, -64, 0));
      }
    }
  }

  // this class holds information about a background music track
  private class MusicTrack {
    int id;

    private AudioPlayer player;
    private boolean shouldLoop;
    private int loopStartMs;
    private int loopEndMs;

    // bgm.txt is a comma separated list formatted like:
    // fileName,startSample,loopStartSample,loopEndSample
    // i didn't end up needing startSample, so this skips over it
    public MusicTrack(int id, String line) {
      this.id = id;

      String[] parts = splitTokens(line, ",");
      this.player = minim.loadFile("bgm/" + parts[0] + ".wav");

      float sampleRate = player.getFormat().getSampleRate() / 1000.0f; // samples/ms
      int loopStart = int(parts[2]);
      int loopEnd = int(parts[3]);

      // minim's loop points work in milliseconds not samples, so we approximate this
      // using the sample rate
      this.loopStartMs = (int)(loopStart / sampleRate);
      this.loopEndMs = (int)(loopEnd / sampleRate);
      this.shouldLoop = loopStartMs != loopEndMs;

      this.setVolume(1.0f);
    }

    float getVolume() {
      if (player.hasControl(Controller.VOLUME)) {
        return player.getVolume();
      } else if (player.hasControl(Controller.GAIN)) {
        return map(player.getGain(), -64, 0, 0, 1);
      }

      return 1;
    }

    int getPosition () {
      return player.position();
    }

    void setVolume(float volume) {
      volume = map(volume, 0.0, 1.0, 0.0, musicVolume);
      if (player.hasControl(Controller.VOLUME)) {
        player.setVolume(volume);
      } else if (player.hasControl(Controller.GAIN)) {
        player.setGain(map(volume, 0.0, 1.0, -64, 0));
      }
    }

    void play() {
      if (shouldLoop) {
        // if you start a song looping, *then* set its loop points, the song will play from 0
        // allowing a proper introduction
        player.loop();
        player.setLoopPoints(loopStartMs, loopEndMs);
      } else {
        player.play();
      }
    }

    void stop() {
      player.pause();
      player.rewind();
      setVolume(1);
      if (shouldLoop) {
        player.setLoopPoints(0, loopEndMs);
      }
    }
  }
}
