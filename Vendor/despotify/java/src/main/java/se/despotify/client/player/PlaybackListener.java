package se.despotify.client.player;

import se.despotify.domain.media.Track;

public interface PlaybackListener {
	public void playbackStarted(Track track);
	public void playbackStopped(Track track);
	public void playbackResumed(Track track);
	public void playbackPosition(Track track, int position);
	public void playbackFinished(Track track);
}
