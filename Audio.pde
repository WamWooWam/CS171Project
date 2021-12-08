
import ddf.minim.*;

class Audio {
  Minim minim;
  AudioSample[] sfxCues;

  BgmInfo[] bgm;

  BgmInfo playingBgm;
  BgmInfo nextBgm;
  float fadeTime;
  float fadeDuration;

  float maxVolume = 0.85f;

  boolean audioInitialised = false;

  public Audio(Object sketch) {
    String[] soundEffects = loadStrings("sfx/sfx.txt");
    sfxCues = new AudioSample[soundEffects.length];

    String[] backgroundMusic = loadStrings("bgm/bgm.txt");
    bgm = new BgmInfo[backgroundMusic.length];

    try {
      minim = new Minim(sketch);

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

  void playCue(int cue) {
    if (!audioInitialised) return;
    sfxCues[cue].trigger();
  }

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

  void setVolume(float volume) {
    if (!audioInitialised) return;

    if (this.playingBgm != null) {
      this.playingBgm.setVolume(volume);
    }
  }

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

  void draw(int start) {
    if (!audioInitialised) return;

    text("main_volume: " + this.playingBgm.getVolume(), 16, start + 24);

    if (this.playingBgm != null) {
      text("current_bgm: " + this.playingBgm.id, 16, start + 48);
      text("bgm_pos: " + this.playingBgm.getPosition(), 16, start + 72);
    }

    if (this.nextBgm != null) {
      text("next_bgm: " + this.nextBgm.id, 16, start + 96);
      text("fade_time: " + this.fadeTime, 16, start + 120);
      text("fade_time_total: " + this.fadeDuration, 16, start + 144);
    }
  }

  private void setVolume(AudioSample sample, float sfxVolume) {
    if (sample.hasControl(AudioPlayer.VOLUME)) {
      sample.setVolume(sfxVolume);
    } else if (sample.hasControl(AudioPlayer.GAIN)) {
      sample.setGain(map(sfxVolume, 0.0, 1.0, -64, 0));
    }
  }

  private class BgmInfo {
    int id;

    private AudioPlayer player;
    private boolean shouldLoop;
    private int loopStartMs;
    private int loopEndMs;

    public BgmInfo(int id, String[] parts) {
      this.id = id;
      this.player = minim.loadFile("bgm/" + parts[0] + ".wav");

      float sampleRate = player.getFormat().getSampleRate() / 1000.0f; // samples/ms
      int loopStart = int(parts[2]);
      int loopEnd = int(parts[3]);

      this.loopStartMs = (int)(loopStart / sampleRate);
      this.loopEndMs = (int)(loopEnd / sampleRate);
      this.shouldLoop = loopStartMs != loopEndMs;

      println(parts[0] + " loopStart: " + loopStartMs + " loopEnd: " + loopEndMs);
    }

    float getVolume() {
      if (player.hasControl(AudioPlayer.VOLUME)) {
        return player.getVolume();
      } else if (player.hasControl(AudioPlayer.GAIN)) {
        return map(player.getGain(), -64, 0, 0, 1);
      }

      return 1;
    }

    int getPosition () {
      return player.position();
    }

    void setVolume(float volume) {
      volume = map(volume, 0.0, 1.0, 0.0, maxVolume);
      if (player.hasControl(AudioPlayer.VOLUME)) {
        player.setVolume(volume);
      } else if (player.hasControl(AudioPlayer.GAIN)) {
        player.setGain(map(volume, 0.0, 1.0, -64, 0));
      }
    }

    void play() {
      if (shouldLoop) {
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
