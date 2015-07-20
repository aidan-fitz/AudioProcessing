class BeatListener {

  //  BeatDetect beatDetect;
  FFT fft;
  AudioSource audio;
  ArrayList<NoteListener> listeners;

  BeatListener(AudioSource src) {
    audio = src;
    //    beatDetect = new BeatDetect(src.bufferSize(), src.sampleRate());
    fft = new FFT(src.bufferSize(), src.sampleRate());
    listeners = new ArrayList<NoteListener>();
    // A0-C8 (piano range)
    for (int i = 21; i < 108; i++) {
      listeners.add(new NoteListener(i));
    }
  }

  // Called each time draw() is called
  void draw() {
    //    beatDetect.detect(audio.mix);
    fft.forward(audio.left.toArray(), audio.right.toArray());
    for (NoteListener l : listeners) {
      //      int min = minBand(l.midi), max = maxBand(l.midi);
      //      if (beatDetect.isRange(min, max, (max - min) / 2)) {
      //      float f = freq(l.midi);
      float amp = ampRange(l.midi);
      if (amp >= 0.5) {
        l.notePlayed(amp);
      }
      l.draw();
    }
  }

  final float SEMITONE = pow(2, 1/12.0);

  float freq(int midi) {
    return 440.0 * pow(SEMITONE, midi - 69);
  }

  float minFreq(int midi) {
    return maxFreq(midi - 1);
  }

  float maxFreq(int midi) {
    return 440.0 * pow(SEMITONE, midi - 69) * sqrt(SEMITONE);
  }

  int minBand(int midi) {
    return fft.freqToIndex(minFreq(midi));
  }

  int maxBand(int midi) {
    return fft.freqToIndex(maxFreq(midi));
  }

  float ampRange(int midi) {
    float totAmp = 0.0;
    int min = minBand(midi), max = maxBand(midi), diff = max - min;
    for (int band = min; band <= max; band++) {
      totAmp += fft.getBand(band) / fft.indexToFreq(band);
    }
    return totAmp / diff;
  }
}

