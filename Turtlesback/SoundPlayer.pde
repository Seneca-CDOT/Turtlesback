/**
 * The SoundManager is a static class that is responsible
 * for handling audio loading and playing. Any audio
 * instructions are delegated to this class. In Processing
 * this uses the Minim library, and in Processing.js it
 * uses the HTML5 <audio> element, wrapped by some clever
 * JavaScript written by Daniel Hodgin that emulates an
 * AudioPlayer object so that the code looks the same.
 */
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

static class SoundPlayer {
  private static boolean debug = false;

  static boolean muted = false;
  private static Minim minim;
  private static ArrayList<Object> startPaused = new ArrayList<Object>();
  private static HashMap<Object,AudioPlayer> owners = new HashMap<Object,AudioPlayer>();
  private static HashMap<String,AudioPlayer> audioplayers = new HashMap<String,AudioPlayer>();

  static void init(PApplet sketch) {
    minim = new Minim(sketch);
    reset();
  }

  static void reset() {
    owners = new HashMap<Object,AudioPlayer>();
  }

  static void load(Object identifier, String filename) {
    // We recycle audio players to keep the
    // cpu and memory footprint low.
    AudioPlayer player = audioplayers.get(filename);
    if(player==null) {
      if(debug) { println("loading filename..."); }
      player = minim.loadFile(filename);
      if(player==null && !debug) {
        println("ERROR: could not load file!");
        return;
      }
      if(muted) player.mute();
      audioplayers.put(filename, player); }
    owners.put(identifier, player);
  }

  static void disown(Object identifier) {
    owners.remove(identifier);
  }

  static boolean play(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) { return false; }
    if(startPaused.contains(identifier)) {
      startPaused.remove(identifier);
      return false;
    }
    ap.play();
    return true;
  }

  static boolean loop(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) { return false; }
    if(startPaused.contains(identifier)) {
      startPaused.remove(identifier);
      return false;
    }
    ap.loop();
    return true;
  }

  static boolean pause(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      if(!startPaused.contains(identifier)){
        startPaused.add(identifier);
      }
      return false;
    }
    ap.pause();
    return true;
  }

  static boolean resume(Object identifier, boolean looping){
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) { return false; }
    startPaused.remove(identifier);
    ap.play();
    if(looping) {
      int pos = ap.position();
      ap.loop();
      ap.cue(pos);
    }
    return true;
  }

  static boolean rewind(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) { return false; }
    ap.rewind();
    return true;
  }

  static boolean stop(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) { return false; }
    ap.pause();
    ap.rewind();
    return true;
  }

  static int getPosition(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      if(debug) {
        println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      }
      return -1;
    }
    return ap.position();
  }

  static void mute() {
    muted = !muted;
    for(AudioPlayer ap: audioplayers.values()) {
      if(muted) { ap.mute(); }
      else { ap.unmute(); }
    }
  }
}
