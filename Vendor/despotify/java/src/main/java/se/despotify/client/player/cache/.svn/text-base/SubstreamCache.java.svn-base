package se.despotify.client.player.cache;

import se.despotify.client.protocol.channel.Channel;
import se.despotify.client.protocol.channel.ChannelListener;
import se.despotify.domain.media.Track;

import java.io.File;

public class SubstreamCache extends FileCache {
	public SubstreamCache(){
		super();
	}

	public SubstreamCache(File directory){
		super(directory);
	}
	
	public String hash(Track track, int offset, int length){
		return track.getFiles().get(0) + "/" + track.getFiles().get(0) + "-" + offset + "-" + length;
	}
	
	public void load(final String category, final String hash, final ChannelListener listener){
		/* Load in a separate thread because of piped streams. */
		new Thread(){
			public void run(){
				Channel channel = new Channel(
					"Cached-Substream-Channel", Channel.Type.TYPE_SUBSTREAM, null
				);
				
				listener.channelHeader(channel, null);
				listener.channelData(channel, load(category, hash));
				listener.channelEnd(channel);
			}
		}.start();
	}
}
