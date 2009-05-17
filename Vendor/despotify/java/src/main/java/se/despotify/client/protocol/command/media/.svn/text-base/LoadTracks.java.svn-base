package se.despotify.client.protocol.command.media;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.BrowseType;
import se.despotify.client.protocol.PacketType;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.channel.Channel;
import se.despotify.client.protocol.channel.ChannelCallback;
import se.despotify.client.protocol.command.Command;
import se.despotify.domain.Store;
import se.despotify.domain.media.Result;
import se.despotify.domain.media.Track;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.GZIP;
import se.despotify.util.Hex;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.Collection;

/**
 * @since 2009-apr-25 16:28:42
 */
public class LoadTracks extends Command<Boolean> {

  protected static Logger log = LoggerFactory.getLogger(LoadTracks.class);

  private Track[] tracks;
  private Store store;

  public LoadTracks(Store store, Collection<Track> tracks) {
    this(store, tracks.toArray(new Track[tracks.size()]));

  }

  public LoadTracks(Store store, Track... tracks) {
    this.store = store;
    this.tracks = tracks;
  }

  @Override
  public Boolean send(Protocol protocol) throws DespotifyException {

/* Create channel callback */
    ChannelCallback callback = new ChannelCallback();

    /* Send browse request. */

    /* Create channel and buffer. */
    Channel channel = new Channel("Browse-Channel", Channel.Type.TYPE_BROWSE, callback);
    ByteBuffer buffer = ByteBuffer.allocate(2 + 1 + tracks.length * 16); //+ ((type == BrowseType.artist || type == BrowseType.album)?4:0));

//		if(ids.size() > 1 && type != BrowseType.track){
//			throw new IllegalArgumentException("Only BrowserType.track accepts multiple ids.");
//		}

    /* Append channel id and type. */
    buffer.putShort((short) channel.getId());
		buffer.put((byte)BrowseType.track.getValue());

    /* Append (16 byte) ids. */
    for (Track track : tracks) {
      buffer.put(Arrays.copyOfRange(track.getUUID(), 0, 16));
    }

//		/* Append zero. */
//		if(type == BrowseType.artist || type == BrowseType.album){
//			buffer.putInt(0);
//		}

    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.browse, buffer, "load track");


    /* Get data and inflate it. */
    byte[] data = GZIP.inflate(callback.getData("gzipped load track response"));

    if (log.isInfoEnabled()) {
      log.info("load track response, " + data.length + " uncompressed bytes:\n" + Hex.log(data, log));
    }


    /* Cut off that last 0xFF byte... */
    data = Arrays.copyOfRange(data, 0, data.length - 1);
    /* Load XML. */

    String xml = new String(data, Charset.forName("UTF-8"));
    if (log.isDebugEnabled()) {
      log.debug(xml);
    }
    XMLElement root = XML.load(xml);

    // load tracks


    Result.fromXMLElement(root, store);

    return true;


  }
}
