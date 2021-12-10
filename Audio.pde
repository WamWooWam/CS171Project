
import ddf.minim.*;

//
// The audio class acts as a wrapper around Minim and facilitates the loading/playing of
// sound effect cues and background music (bgm)
//
class Audio {
  
  // store our minim object
  Minim minim;
  
  // bgm and sfx are called by their index
  AudioSample[] sfxCues;
  BgmInfo[] bgm;

  // keep track of what's now playing to allow cross fading etc.
  BgmInfo playingBgm;
  BgmInfo nextBgm;
  float fadeTime;
  float fadeDuration;

  float maxVolume = 0.85f;

  // minim sometimes doesn't init correctly, and in that case, we must manually disable audio.
  boolean audioInitialised = false;

  public Audio(Object sketch) {
    // load and allocate arrays for sound effects and background music
    String[] soundEffects = loadStrings("sfx/sfx.txt");
    sfxCues = new AudioSample[soundEffects.length];

    String[] backgroundMusic = loadStrings("bgm/bgm.txt");
    bgm = new BgmInfo[backgroundMusic.length];

    try {
      // init minim
      minim = new Minim(sketch);

      // load sfx/bgm
      for (int i = 0; i < soundEffects.length; i++) {
        sfxCues[i] = minim.loadSample("sfx/" + soundEffects[i] + ".wav");
        this.setVolume(sfxCues[i], maxVolume);
      }

      for (int i = 0; i <backgroundMusic.length; i++) {
        String[] parts = splitTokens(backgroundMusic[i], ",");
        bgm[i] = new BgmInfo(i, parts);
      }

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
  void playBgm(int bgm, float fadeTime) {
    if (!audioInitialised) return;

    if (this.playingBgm != null) {
      if (this.playingBgm.id == bgm) return;

      this.nextBgm = this.bgm[bgm];
      this.nextBgm.setVolume(0);
      this.fadeDuration = fadeTime;
      this.fadeTime = fadeTime;
    } else {
      this.playingBgm = this.bgm[bgm];
      this.playingBgm.setVolume(1);
      this.playingBgm.play();
    }
  }

  // set the current bgm volume, used for manual fades
  void setVolume(float volume) {
    if (!audioInitialised) return;

    if (this.playingBgm != null) {
      this.playingBgm.setVolume(volume);
    }
  }

  // this update loop handles fades between music tracks 
  void update(float deltaTime) {
    if (!audioInitialised) return;

    if (this.nextBgm != null) {
      this.fadeTime = max(0, this.fadeTime - deltaTime);
      if (this.fadeTime < EPSILON) {
        this.playingBgm.stop();
        this.playingBgm = this.nextBgm;
        this.playingBgm.setVolume(1);
        this.playingBgm.play();
        this.nextBgm = null;
        this.fadeTime = 0;
        return;
      }
      this.playingBgm.setVolume(this.fadeTime / this.fadeDuration);
    }
  }

  // this draws the audio debugger
  void draw(int start) {
    if (!audioInitialised) return;

    if (this.playingBgm != null) {
      text("main_volume: " + this.playingBgm.getVolume(), 16, start + 24);
      text("current_bgm: " + this.playingBgm.id, 16, start + 48);
      text("bgm_pos: " + this.playingBgm.getPosition(), 16, start + 72);
    }

    if (this.nextBgm != null) {
      text("next_bgm: " + this.nextBgm.id, 16, start + 96);
      text("fade_time: " + this.fadeTime, 16, start + 120);
      text("fade_time_total: " + this.fadeDuration, 16, start + 144);
    }
  }

  // sets the volume of an audio sample.
  // for some reason, minim calls this method deprecated, but doesn't seem to allow
  // any other way to ensure a control exists on an object? maybe i'm blind, but this works
  // so we can ignore these warnings for now.
  private void setVolume(AudioSample sample, float sfxVolume) {
    if (sample.hasControl(Controller.VOLUME)) {
      sample.setVolume(sfxVolume);
    } else if (sample.hasControl(Controller.GAIN)) {
      sample.setGain(map(sfxVolume, 0.0, 1.0, -64, 0));
    }
  }

  // this class holds information about a background music track
  private class BgmInfo {
    
    int id;
    private AudioPlayer player;
    private boolean shouldLoop;
    private int loopStartMs;
    private int loopEndMs;

    // bgm.txt is a comma separated list formatted like:
    // fileName,startSample,loopStartSample,loopEndSample
    // i didn't end up needing startSample, so this skips over it
    public BgmInfo(int id, String[] parts) {
      this.id = id;
      this.player = minim.loadFile("bgm/" + parts[0] + ".wav");

      float sampleRate = player.getFormat().getSampleRate() / 1000.0f; // samples/ms
      int loopStart = int(parts[2]);
      int loopEnd = int(parts[3]);

      // minim's loop points work in milliseconds not samples, so we approximate this
      // using the sample rate
      this.loopStartMs = (int)(loopStart / sampleRate);
      this.loopEndMs = (int)(loopEnd / sampleRate);
      this.shouldLoop = loopStartMs != loopEndMs;
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
      volume = map(volume, 0.0, 1.0, 0.0, maxVolume);
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
