package se.despotify.client.protocol.command.media;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.client.protocol.PacketType;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.channel.Channel;
import se.despotify.client.protocol.channel.ChannelCallback;
import se.despotify.client.protocol.command.Command;
import se.despotify.domain.Store;
import se.despotify.domain.media.Result;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.GZIP;
import se.despotify.util.Hex;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.Arrays;

/**
 * @since 2009-apr-25 20:07:48
 */
public class Search extends Command<Result> {

  private static Logger log = LoggerFactory.getLogger(Search.class);

  // result.setQuery(query)

  private Store store;
  private String query;
  private int offset;
  private int maxResults;

  public Search(Store store, String query) {
    this(store, query, 0, -1);
  }

  public Search(Store store, String query, int offset, int maxResults) {
    this.store = store;
    this.query = query;
    this.offset = offset;
    this.maxResults = maxResults;
  }

  public Result send(Protocol protocol) throws DespotifyException {
    /* Create channel callback */
    ChannelCallback callback = new ChannelCallback();

    /* Create channel and buffer. */
    Channel channel = new Channel("Search-Channel", Channel.Type.TYPE_SEARCH, callback);
    ByteBuffer buffer = ByteBuffer.allocate(2 + 4 + 4 + 2 + 1 + query.getBytes().length);

    /* Check offset and limit. */
    if (offset < 0) {
      throw new IllegalArgumentException("Offset needs to be >= 0");
    } else if ((maxResults < 0 && maxResults != -1) || maxResults == 0) {
      throw new IllegalArgumentException("Limit needs to be either -1 for no limit or > 0");
    }

    /* Append channel id, some values, query length and query. */
    buffer.putShort((short) channel.getId());
    buffer.putInt(offset); /* Result offset. */
    buffer.putInt(maxResults); /* Reply limit. */
    buffer.putShort((short) 0x0000);
    buffer.put((byte) query.length());
    buffer.put(query.getBytes());
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.search, buffer, "search");

    /* Get data and inflate it. */
    byte[] data = GZIP.inflate(callback.getData("gzipped search response"));

    if (log.isInfoEnabled()) {
      log.info("received search response packet, " + data.length + " uncompressed bytes:\n" + Hex.log(data, log));
    }


    /* Cut off that last 0xFF byte... */
    data = Arrays.copyOfRange(data, 0, data.length - 1);

    String xml = new String(data, Charset.forName("UTF-8"));
    if (log.isDebugEnabled()) {
      log.debug(xml);
    }
    XMLElement root = XML.load(xml);

    /* Create result from XML. */

    return Result.fromXMLElement(root, store);

  }
}
