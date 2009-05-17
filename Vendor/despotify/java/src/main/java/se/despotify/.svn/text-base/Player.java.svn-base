package se.despotify;

import se.despotify.client.player.PlaybackListener;
import se.despotify.domain.media.Track;

public interface Player {

  /**
   * Play a track in a background thread.
   *
   * @param track    A {@link se.despotify.domain.media.Track} object identifying the track to be played.
   * @param listener
   */
  public abstract void play(Track track, PlaybackListener listener);

  /**
   * Start playing or resume current track.
   */
  public  abstract void play();

  /**
   * Pause playback of current track.
   */
  public  abstract void pause();

  /**
   * Stop playback of current track.
   */
  public  abstract void stop();

  /**
   * Get length of current track.
   *
   * @return Length in seconds or -1 if not available.
   */
  public  abstract  int length();

  /**
   * Get playback position of current track.
   *
   * @return Playback position in seconds or -1 if not available.
   */
  public  abstract int position();

  /**
   * Get volume.
   *
   * @return A value from 0.0 to 1.0.
   */
  public  abstract float volume();

  /**
   * Set volume.
   *
   * @param volume A value from 0.0 to 1.0.
   */
  public  abstract  void volume(float volume);
}
