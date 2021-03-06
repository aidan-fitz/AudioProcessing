class BeatListener {

  //  BeatDetect beatDetect;
  FFT fft;
  AudioSource audio;
  ArrayList<NoteListener> listeners;
  LoudestThree three;

  BeatListener(AudioSource src) {
    audio = src;
    //    beatDetect = new BeatDetect(src.bufferSize(), src.sampleRate());
    fft = new FFT(src.bufferSize(), src.sampleRate());
    listeners = new ArrayList<NoteListener>();
    // A0-C8 (piano range)
    for (int i = 0; i < 12; i++) {
      listeners.add(new NoteListener(i));
    }
    three = new LoudestThree();
  }

  // Called each time draw() is called
  void draw() {
    fft.forward(audio.left.toArray(), audio.right.toArray());
    for (int i = 0; i < 12; i++) {
      float amp = 0;
      for (int octave = 36; octave < 96; octave += 12) {
        amp += ampRange(octave + i);
      }
      three.set(i, amp);
     // println(three.get(i)); //here
    }
    three.draw();
  }

  final float SEMITONE = pow(2, 1/12.0);

  float freq(int midi) {
    return 440.0 * pow(SEMITONE, midi - 69);
  }

  float minFreq(int midi) {
    return maxFreq(midi - 1);
  }

  float maxFreq(int midi) {
    return 440.0 * pow(SEMITONE, midi - 69 + 0.5);
  }

  int minBand(int midi) {
    return fft.freqToIndex(minFreq(midi));
  }

  int maxBand(int midi) {
    return fft.freqToIndex(maxFreq(midi));
  }

  float ampRange(int midi) {
    float min = minFreq(midi), max = maxFreq(midi);
    return fft.calcAvg(min, max) / freq(midi);
  }
}

